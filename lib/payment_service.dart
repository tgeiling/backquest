import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase_storekit/src/store_kit_wrappers/sk_payment_queue_delegate_wrapper.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'provider.dart';
import 'services.dart';

class PaymentService {
  final String baseUrl = 'http://34.116.240.55:3000';
  final ProfileProvider profileProvider;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isInitialized = false;
  final Set<String> _kProductIds = <String>{'0001', '0002'};

  // Maps product IDs to more descriptive names
  static const String yearlySubscriptionId = '0001';
  static const String monthlySubscriptionId = '0002';

  // Receipt cache keys
  static const String _kActiveReceiptKey = 'active_receipt';
  static const String _kReceiptValidUntilKey = 'receipt_valid_until';
  static const String _kSubscriptionTypeKey = 'subscription_type';
  static const String _kLastServerValidationKey = 'last_server_validation';

  PaymentService({required this.profileProvider});

  /// Initialize payment service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up IAP
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('In-app purchases not available');
      _isInitialized = true;
      return;
    }

    // Configure for each platform
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(
        IOSPaymentQueueDelegate() as SKPaymentQueueDelegateWrapper?,
      );
    }

    // Set up subscription listener
    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        print('IAP Stream error: $error');
      },
    );

    // Load products
    await _loadProducts();

    // Check for existing receipt and validate
    await _validateStoredReceipt();

    _isInitialized = true;
    print('Payment service initialized');
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_kProductIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      print('Products loaded: ${_products.length}');
      for (final product in _products) {
        print('Product: ${product.id} - ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('Failed to load products: $e');
    }
  }

  /// Validate stored receipt on app start
  Future<void> _validateStoredReceipt() async {
    final prefs = await SharedPreferences.getInstance();
    final String? receipt = prefs.getString(_kActiveReceiptKey);
    final String? validUntilStr = prefs.getString(_kReceiptValidUntilKey);
    final String? subType = prefs.getString(_kSubscriptionTypeKey);

    if (receipt == null || validUntilStr == null || subType == null) {
      print('No stored receipt found');

      // Make sure subscription state is consistent with stored data
      if (profileProvider.payedSubscription == true) {
        profileProvider.setSubscription(
          isPaid: false,
          type: null,
          started: null,
          receipt: null,
        );
      }

      return;
    }

    final DateTime validUntil = DateTime.parse(validUntilStr);
    final bool isValid = validUntil.isAfter(DateTime.now());

    print('Stored receipt valid until: $validUntil, is valid: $isValid');

    // Update subscription state based on stored receipt
    profileProvider.setSubscription(
      isPaid: isValid,
      type: isValid ? subType : null,
      started: isValid ? prefs.getString('subscription_started') : null,
      receipt: isValid ? receipt : null,
    );

    // If we have a connection, attempt to validate with server
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none && isValid) {
      // Only validate with server if we haven't done so recently (e.g., within the last day)
      final int? lastValidation = prefs.getInt(_kLastServerValidationKey);
      final bool shouldValidate =
          lastValidation == null ||
          DateTime.now()
                  .difference(
                    DateTime.fromMillisecondsSinceEpoch(lastValidation),
                  )
                  .inDays >=
              1;

      if (shouldValidate) {
        // Try server validation
        await _validateReceiptWithServer(receipt, subType);
      }
    }
  }

  /// Validate receipt with server
  Future<bool> _validateReceiptWithServer(
    String receipt,
    String subscriptionType,
  ) async {
    try {
      // Get auth token
      final String? token = await getAuthToken();
      if (token == null) {
        print('No auth token available for server validation');
        return false;
      }

      // Call server API to validate receipt
      final response = await http.post(
        Uri.parse('${baseUrl}/validate_receipt'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receipt': receipt,
          'subscription_type': subscriptionType,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isValid = data['is_valid'] ?? false;
        final String? validUntil = data['valid_until'];

        if (isValid && validUntil != null) {
          // Update stored receipt validity
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(_kReceiptValidUntilKey, validUntil);
          prefs.setInt(
            _kLastServerValidationKey,
            DateTime.now().millisecondsSinceEpoch,
          );

          // Parse expiry date from server
          final DateTime expiryDate = DateTime.parse(validUntil);
          print('Server validates receipt until: $expiryDate');

          return true;
        }

        // If server says receipt is invalid, clear local state
        if (!isValid) {
          await _clearStoredReceipt();
          profileProvider.setSubscription(
            isPaid: false,
            type: null,
            started: null,
            receipt: null,
          );
        }
      }

      return false;
    } catch (e) {
      print('Server validation error: $e');
      return false;
    }
  }

  /// Clear stored receipt data
  Future<void> _clearStoredReceipt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveReceiptKey);
    await prefs.remove(_kReceiptValidUntilKey);
    await prefs.remove(_kSubscriptionTypeKey);
    print('Cleared stored receipt data');
  }

  /// Store a valid receipt
  Future<void> _storeValidReceipt(
    String receipt,
    String subscriptionType,
    DateTime validUntil,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveReceiptKey, receipt);
    await prefs.setString(_kReceiptValidUntilKey, validUntil.toIso8601String());
    await prefs.setString(_kSubscriptionTypeKey, subscriptionType);
    await prefs.setString(
      'subscription_started',
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    await prefs.setInt(
      _kLastServerValidationKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    print('Stored valid receipt for $subscriptionType until $validUntil');
  }

  /// Calculate subscription expiry date
  DateTime _calculateExpiryDate(String subscriptionType) {
    final now = DateTime.now();
    if (subscriptionType == 'yearly') {
      return now.add(const Duration(days: 365));
    } else {
      return now.add(const Duration(days: 31));
    }
  }

  /// Listen to purchase updates
  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading UI
        print('Purchase pending');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Show error UI
          print('Purchase error: ${purchaseDetails.error?.message}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Process successful or restored purchase
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          } else {
            print('Purchase verification failed');
            // Show error UI
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          print('Purchase cancelled');
        }

        // Complete the purchase regardless of outcome
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Verify the purchase with the platform's store
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Determine subscription type
      String subscriptionType;
      if (purchaseDetails.productID == yearlySubscriptionId) {
        subscriptionType = 'yearly';
      } else if (purchaseDetails.productID == monthlySubscriptionId) {
        subscriptionType = 'monthly';
      } else {
        print('Unknown product ID: ${purchaseDetails.productID}');
        return false;
      }

      // Create appropriate receipt format based on platform
      String receipt;

      if (Platform.isAndroid) {
        // For Google Play, create a structured receipt with required fields
        if (purchaseDetails is GooglePlayPurchaseDetails) {
          // Safe access to Google Play specific details
          final Map<String, dynamic> receiptData = {
            'packageName':
                'com.backquest.app', // Replace with your actual package name
            'productId': purchaseDetails.productID,
            'purchaseToken':
                purchaseDetails.billingClientPurchase.purchaseToken,
          };
          receipt = jsonEncode(receiptData);
        } else {
          // Fallback for unexpected type
          print(
            'Warning: Expected GooglePlayPurchaseDetails but got ${purchaseDetails.runtimeType}',
          );
          receipt = purchaseDetails.verificationData.serverVerificationData;
        }
      } else {
        // For iOS, use the server verification data directly
        receipt = purchaseDetails.verificationData.serverVerificationData;
      }

      // Calculate expiry date (will be updated with server validation)
      final DateTime expiryDate = _calculateExpiryDate(subscriptionType);

      // Store receipt data for offline validation
      await _storeValidReceipt(receipt, subscriptionType, expiryDate);

      return true;
    } catch (e) {
      print('Error verifying purchase: $e');
      return false;
    }
  }

  /// Deliver the purchased product
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Determine subscription type
    String subscriptionType;
    if (purchaseDetails.productID == yearlySubscriptionId) {
      subscriptionType = 'yearly';
    } else {
      subscriptionType = 'monthly';
    }

    // Record the subscription in the provider
    await _recordSubscription(
      purchaseDetails.productID,
      purchaseDetails.verificationData.serverVerificationData,
      subscriptionType,
    );

    print('Product delivered: ${purchaseDetails.productID}');
  }

  /// Record successful subscription in provider and sync with server
  Future<void> _recordSubscription(
    String subscriptionId,
    String receipt,
    String subType,
  ) async {
    try {
      // Record current date as start date
      final String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // For Android, need to format the receipt properly
      String formattedReceipt = receipt;
      if (Platform.isAndroid) {
        try {
          // Check if it's already JSON
          jsonDecode(receipt);
        } catch (e) {
          // If not valid JSON, create a structured receipt
          final Map<String, dynamic> receiptData = {
            'packageName':
                'com.backquest.app', // Replace with your package name
            'productId': subscriptionId,
            'purchaseToken':
                receipt, // Use verification data as token in fallback
          };
          formattedReceipt = jsonEncode(receiptData);
        }
      }

      // Update provider
      profileProvider.setSubscription(
        isPaid: true,
        type: subType,
        started: startDate,
        receipt: formattedReceipt,
      );

      // Sync with server if we have a token
      String? token = await getAuthToken();
      if (token != null) {
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}/record_subscription'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'subscription_id': subscriptionId,
              'receipt': formattedReceipt,
              'subscription_type': subType,
              'started_at': startDate,
              'platform': Platform.isIOS ? 'ios' : 'android',
            }),
          );

          if (response.statusCode == 200) {
            print('Subscription recorded with server');

            // Optionally update expiry date based on server response
            final data = jsonDecode(response.body);
            if (data['valid_until'] != null) {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString(_kReceiptValidUntilKey, data['valid_until']);
            }
          } else {
            print(
              'Failed to record subscription with server: ${response.statusCode}',
            );
          }
        } catch (e) {
          print('Error syncing subscription with server: $e');
        }
      }
    } catch (e) {
      print('Error recording subscription: $e');
    }
  }

  /// Start the subscription purchase flow
  Future<bool> purchaseSubscription(
    String subscriptionId,
    BuildContext context,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Find the product
      ProductDetails? product;
      try {
        product = _products.firstWhere((prod) => prod.id == subscriptionId);
      } catch (e) {
        // Handle case where product is not found
        product = null;
        print('Product not found: $e');
      }

      if (product == null) {
        // Hide loading dialog
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found. Please try again later.'),
            ),
          );
        }
        return false;
      }

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      // Start purchase
      bool purchaseStarted;

      // For Android, we need to use subscriptions APIs
      if (Platform.isAndroid) {
        purchaseStarted = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        // For iOS and other platforms
        purchaseStarted = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      }

      // Hide loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        if (!purchaseStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to start purchase process. Please try again.',
              ),
            ),
          );
        }
      }

      return purchaseStarted;
    } catch (e) {
      // Hide loading dialog if still showing
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing purchase: $e')),
        );
      }
      print('Purchase error: $e');
      return false;
    }
  }

  /// Show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(BuildContext context) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // This is a placeholder for actual cancellation logic
      // In a real app, this would integrate with the app store's APIs

      // For iOS, you would typically redirect to App Store subscription management
      if (Platform.isIOS) {
        await _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
            .showPriceConsentIfNeeded();
        // Open subscription management
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.presentCodeRedemptionSheet();
      }

      // For Android, redirect to Google Play subscription management
      // Note: This can't be done programmatically; you'd need to tell the user how to cancel

      // Clear local receipt data
      await _clearStoredReceipt();

      // Update provider to reflect cancellation
      profileProvider.setSubscription(
        isPaid: false,
        type: null,
        started: null,
        receipt: null,
      );

      // Sync with server if we have a token
      String? token = await getAuthToken();
      if (token != null) {
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}/cancel_subscription'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode != 200) {
            print(
              'Failed to notify server about cancellation: ${response.statusCode}',
            );
          }
        } catch (e) {
          print('Error notifying server about cancellation: $e');
        }
      }

      // Hide loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      return true;
    } catch (e) {
      // Hide loading dialog if still showing
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling subscription: $e')),
        );
      }
      print('Cancellation error: $e');
      return false;
    }
  }

  /// Verify existing subscription status
  Future<bool> verifySubscription() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Check local storage first
      final prefs = await SharedPreferences.getInstance();
      final String? validUntilStr = prefs.getString(_kReceiptValidUntilKey);

      if (validUntilStr != null) {
        final DateTime validUntil = DateTime.parse(validUntilStr);
        final bool isValid = validUntil.isAfter(DateTime.now());

        if (isValid) {
          // Local validation says subscription is active
          final String? subType = prefs.getString(_kSubscriptionTypeKey);
          final String? receipt = prefs.getString(_kActiveReceiptKey);
          final String? startDate = prefs.getString('subscription_started');

          // Update provider
          profileProvider.setSubscription(
            isPaid: true,
            type: subType,
            started: startDate,
            receipt: receipt,
          );

          return true;
        }
      }

      // If we have a token and connectivity, attempt to get the latest status from the server
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity != ConnectivityResult.none) {
        String? token = await getAuthToken();
        if (token != null) {
          try {
            final response = await http.get(
              Uri.parse('${baseUrl}/subscription_status'),
              headers: {'Authorization': 'Bearer $token'},
            );

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              final bool isPaid = data['is_paid'] ?? false;

              if (isPaid) {
                // Update provider and local storage
                profileProvider.setSubscription(
                  isPaid: true,
                  type: data['subscription_type'],
                  started: data['started_at'],
                  receipt: data['receipt'],
                );

                if (data['valid_until'] != null) {
                  await _storeValidReceipt(
                    data['receipt'],
                    data['subscription_type'],
                    DateTime.parse(data['valid_until']),
                  );
                }

                return true;
              }
            }
          } catch (e) {
            print('Error verifying subscription with server: $e');
          }
        }
      }

      // No valid subscription found
      profileProvider.setSubscription(
        isPaid: false,
        type: null,
        started: null,
        receipt: null,
      );

      return false;
    } catch (e) {
      print('Verification error: $e');
      return false;
    }
  }

  /// Call this method to restore purchased subscriptions
  Future<bool> restorePurchases(BuildContext context) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Request to restore purchases
      await _inAppPurchase.restorePurchases();

      // We'll just wait a bit for the purchase stream to process any restored purchases
      await Future.delayed(const Duration(seconds: 2));

      // Re-verify subscription status
      final bool hasActiveSubscription = await verifySubscription();

      // Hide loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        if (hasActiveSubscription) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your subscription has been restored!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No previous subscriptions found.')),
          );
        }
      }

      return hasActiveSubscription;
    } catch (e) {
      // Hide loading dialog if still showing
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring purchases: $e')),
        );
      }
      print('Restore error: $e');
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _subscription.cancel();
  }
}

/// iOS-specific payment queue delegate
class IOSPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
