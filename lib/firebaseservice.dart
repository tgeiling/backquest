import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'services.dart';

// Define a global key for navigator to use in the background handler
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Class to store and manage pending notifications
class PendingNotification {
  static Map<String, dynamic>? _pendingData;
  static bool _isProcessing = false;

  static void set(Map<String, dynamic> data) {
    print('Storing pending notification: $data');
    _pendingData = data;
  }

  static Map<String, dynamic>? get() {
    return _pendingData;
  }

  static void clear() {
    print('Clearing pending notification');
    _pendingData = null;
    _isProcessing = false;
  }

  static bool hasData() {
    return _pendingData != null;
  }

  static bool get isProcessing => _isProcessing;

  static void setProcessing(bool value) {
    _isProcessing = value;
  }
}

// Configure the notification channel for Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'battle_requests_channel',
  'Battle Requests',
  description: 'Notifications for new battle requests',
  importance: Importance.high,
);

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Define the background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');

  // Store the message data for processing when the app opens
  if (message.data['type'] == 'battle_request' ||
      message.data['type'] == 'friend_request') {
    // We can't directly use PendingNotification here since this runs in a separate isolate
    // Instead, we'll rely on the onMessageOpenedApp handler
  }
}

class FirebaseService {
  static FirebaseMessaging? _firebaseMessaging;
  static bool _isInitialized = false;

  // Initialize Firebase and configure notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User notification settings: ${settings.authorizationStatus}');

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configure local notifications for Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Configure iOS foreground presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Initialize local notifications
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(jsonDecode(response.payload ?? '{}'));
      },
    );

    // Setup foreground message handling
    _setupForegroundMessageHandling();

    // Setup notification open handling
    _setupNotificationOpenHandling();

    // Get token and register with server
    String? token = await _firebaseMessaging!.getToken();
    print("FCM token: $token");
    if (token != null) {
      await _registerDeviceToken(token);
    }

    // Listen for token refreshes
    _firebaseMessaging!.onTokenRefresh.listen((String newToken) {
      print("FCM token refreshed: $newToken");
      _registerDeviceToken(newToken);
    });

    // Check for initial notification that opened the app
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from terminated state via notification");
      print("Initial message data: ${initialMessage.data}");

      // Store for processing after app is fully initialized
      PendingNotification.set(initialMessage.data);
    }

    _isInitialized = true;
    print("Firebase service initialized successfully");
  }

  // Setup foreground message handling
  static void _setupForegroundMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      print("Foreground message received: ${message.data}");

      // Check for notification type
      final notificationType = message.data['type'];

      // If the message contains a notification and we're on Android, display a local notification
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }

      // Update request counts for battle requests or friend requests
      if (notificationType == 'battle_request' ||
          notificationType == 'friend_request') {
        // Try to find the BattleRequestsButton and refresh counts
        _tryUpdateBattleRequestsCount();

        // Show a notification snackbar if a context is available
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notification?.body ?? 'New notification received'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  final battleRequestsState =
                      BattleRequestsButton.globalKey.currentState;
                  if (battleRequestsState != null) {
                    battleRequestsState.showRequestsDialog();
                  }
                },
              ),
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  // Setup notification open handling
  static void _setupNotificationOpenHandling() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background via notification');
      print('Notification data: ${message.data}');

      final notificationType = message.data['type'];
      if (notificationType == 'battle_request' ||
          notificationType == 'friend_request') {
        // Store the notification data for processing after app is fully initialized
        if (!PendingNotification.isProcessing) {
          PendingNotification.set(message.data);

          // Try to process it immediately if context is available
          final context = navigatorKey.currentContext;
          if (context != null) {
            print(
              'Context available, trying to process notification immediately',
            );
            processPendingNotification(context);
          } else {
            print(
              'Context not available, notification will be processed when app is ready',
            );
          }
        }
      }
    });
  }

  // Process a pending notification
  static Future<void> processPendingNotification(BuildContext context) async {
    if (!PendingNotification.hasData() || PendingNotification.isProcessing) {
      return;
    }

    print('Processing pending notification');
    PendingNotification.setProcessing(true);

    final data = PendingNotification.get()!;
    final notificationType = data['type'];

    if (notificationType == 'battle_request' ||
        notificationType == 'friend_request') {
      print('Navigating to home page from notification');

      // Navigate to home page first
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (route) => false,
      );

      // Wait for UI to settle
      await Future.delayed(Duration(milliseconds: 800));

      // Try to update battle requests count
      await _retryUpdateBattleRequestsCount(maxRetries: 3);

      // Clear the pending notification
      PendingNotification.clear();
    }
  }

  // Try to update battle requests count immediately
  static void _tryUpdateBattleRequestsCount() {
    final battleRequestsState = BattleRequestsButton.globalKey.currentState;
    if (battleRequestsState != null) {
      print('Found BattleRequestsButton, updating counts');
      battleRequestsState.fetchRequestCounts();
    } else {
      print('BattleRequestsButton not found for immediate update');
    }
  }

  // Retry updating battle requests count with multiple attempts
  static Future<bool> _retryUpdateBattleRequestsCount({
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      print('Attempt ${i + 1} to update battle requests count');

      final battleRequestsState = BattleRequestsButton.globalKey.currentState;
      if (battleRequestsState != null) {
        print('Successfully found BattleRequestsButton on attempt ${i + 1}');
        battleRequestsState.fetchRequestCounts();
        return true;
      }

      // Wait before next attempt
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }

    print('Failed to find BattleRequestsButton after $maxRetries attempts');
    return false;
  }

  // Handle notification tap from local notifications
  static void _handleNotificationTap(Map<String, dynamic> data) {
    print('Local notification tapped: $data');

    if (data['type'] == 'battle_request' || data['type'] == 'friend_request') {
      // Store for processing when context is available
      PendingNotification.set(data);

      // Try to process immediately if context is available
      final context = navigatorKey.currentContext;
      if (context != null) {
        processPendingNotification(context);
      }
    }
  }

  // Register device token with your server
  static Future<void> _registerDeviceToken(String token) async {
    try {
      final authToken = await getAuthToken();
      if (authToken != null) {
        final response = await http.post(
          Uri.parse('http://34.40.38.12:3000/registerDeviceToken'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({'deviceToken': token}),
        );

        if (response.statusCode == 200) {
          print('Device token registered successfully with server');

          // Save token locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fcm_token', token);
        } else {
          print('Failed to register device token: ${response.body}');
        }
      } else {
        print('Cannot register device token: Auth token is null');
      }
    } catch (e) {
      print('Error registering device token: $e');
    }
  }

  // Check if there are pending notifications
  static bool hasPendingNotifications() {
    return PendingNotification.hasData();
  }

  // Process any pending notifications on app start
  static void checkAndProcessPendingNotifications(BuildContext context) {
    if (PendingNotification.hasData() && !PendingNotification.isProcessing) {
      print('Found pending notifications on app start');
      processPendingNotification(context);
    }
  }
}
