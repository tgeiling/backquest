import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backquest/elements.dart';
import 'package:backquest/services.dart';
import 'package:backquest/stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'auth.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;
  final bool authenticated;

  const SettingsPage({
    Key? key,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
    required this.authenticated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
    bool payedUp = profilProvider.payedSubscription == true ? true : false;

    // Create a list to hold all the settings tiles
    List<Widget> settingsTiles = [
      SettingsTile(
          title: AppLocalizations.of(context)!.adjustGoals,
          icon: Icons.bar_chart),
      SettingsTile(
          title: AppLocalizations.of(context)!.adjustPainAreas,
          icon: Icons.sports_tennis),
      SettingsTile(
          title: AppLocalizations.of(context)!.adjustFitnessLevel,
          icon: Icons.bolt),
      SettingsTile(
          title: AppLocalizations.of(context)!.termsConditions,
          icon: Icons.article),
      SettingsTile(
          title: AppLocalizations.of(context)!.privacyPolicy,
          icon: Icons.privacy_tip),
      SettingsTile(
          title: AppLocalizations.of(context)!.impressum,
          icon: Icons.info_outline),
    ];

    // Conditionally add login or logout based on authentication status
    if (authenticated) {
      settingsTiles.add(SettingsTile(
        title: AppLocalizations.of(context)!.logout,
        icon: Icons.logout,
        onTileTap: setAuthenticated,
      ));

      // Only show delete account option for authenticated users
      settingsTiles.add(SettingsTile(
        title: "Delete Account", // Add to localizations
        icon: Icons.delete_forever,
      ));
    } else {
      settingsTiles.add(LoginTile(
        title: AppLocalizations.of(context)!.login,
        icon: Icons.login,
        setAuthenticated: setAuthenticated,
        setQuestionnairDone: setQuestionnairDone,
      ));
    }

    // Add subscription tile
    settingsTiles.add(SettingsTile(
      title: payedUp
          ? AppLocalizations.of(context)!.mySubscription
          : AppLocalizations.of(context)!.subscribeBackQuest,
      icon: Icons.payments_sharp,
    ));

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            AppLocalizations.of(context)!.settingsTitle,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/settingsbg.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: settingsTiles,
            ).toList(),
          ),
        ]));
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function(bool)? onTileTap;

  const SettingsTile({
    Key? key,
    required this.title,
    required this.icon,
    this.onTileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    final AuthService authService = AuthService();
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        if (title == AppLocalizations.of(context)!.adjustGoals) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GoalSettingPage(
                      initialWeeklyGoal: profilProvider.weeklyGoal,
                    )),
          );
        } else if (title == AppLocalizations.of(context)!.adjustPainAreas) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PainSettingPage(
                      initialSelectedPainAreas: profilProvider.hasPain,
                    )),
          );
        } else if (title == AppLocalizations.of(context)!.adjustFitnessLevel) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FitnessSettingPage(
                      initialFitnessLevel: profilProvider.fitnessLevel,
                    )),
          );
        } else if (title == AppLocalizations.of(context)!.termsConditions) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AGB(),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.privacyPolicy) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Datasecurity(),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.impressum) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Impressum(),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.logout) {
          authService.logout();
          onTileTap?.call(false);
          Navigator.pop(context);
        } else if (title == "Delete Account") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeleteAccountPage(
                setAuthenticated: onTileTap ?? ((_) {}),
              ),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.mySubscription ||
            title == AppLocalizations.of(context)!.subscribeBackQuest) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SubscriptionSettingPage()),
          );
        } else if (title == AppLocalizations.of(context)!.contact) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Kontakt()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailView(title: title)),
          );
        }
      },
    );
  }
}

class LoginTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;

  const LoginTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                setAuthenticated: setAuthenticated,
                setQuestionnairDone: setQuestionnairDone,
              ),
            ));
      },
    );
  }
}

class DetailView extends StatelessWidget {
  final String title;

  const DetailView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.informationFor(title)),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.informationFor(title)),
      ),
    );
  }
}

class GoalSettingPage extends StatefulWidget {
  final int initialWeeklyGoal;

  const GoalSettingPage({
    Key? key,
    this.initialWeeklyGoal = 3,
  }) : super(key: key);

  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  late int weeklyGoal;

  @override
  void initState() {
    super.initState();
    weeklyGoal = widget.initialWeeklyGoal;
  }

  bool isGoalSelected(int goal) {
    return weeklyGoal == goal;
  }

  Widget goalTile(int goal) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isGoalSelected(goal)
            ? const Color(0xFF59c977)
            : Colors.grey
                .withOpacity(0.3), // Background color based on selection
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isGoalSelected(goal)
                ? const Color(0xFF48a160)
                : Colors.transparent,
            offset: const Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.weeklyGoalLabel(goal.toString()),
          style: TextStyle(
            color: isGoalSelected(goal)
                ? Colors.white
                : Colors.grey[400], // White text for better contrast
          ),
        ),
        onTap: () {
          setState(() {
            weeklyGoal = goal;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    return Stack(children: <Widget>[
      Image.asset(
        "assets/settingsbg.PNG",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white, // Sets the color of the back arrow to white
          ),
          title: Text(
            AppLocalizations.of(context)!.adjustGoals,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppLocalizations.of(context)!.weeklyGoalPrompt,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (int i = 1; i <= 12; i++) goalTile(i),
          ],
        ),
        floatingActionButton: PressableButton(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            profilProvider.setWeeklyGoal(weeklyGoal);
            getAuthToken().then((token) {
              if (token != null) {
                updateProfile(
                  token: token,
                  weeklyGoal: weeklyGoal,
                ).then((success) {
                  if (success) {
                    print("Profile updated successfully.");
                  } else {
                    print("Failed to update profile.");
                  }
                });
              } else {
                print("No auth token available.");
              }
            });
            Navigator.of(context).pop();
          },
        ),
      )
    ]);
  }
}

class FitnessSettingPage extends StatefulWidget {
  final int initialFitnessLevel;

  const FitnessSettingPage({
    Key? key,
    this.initialFitnessLevel = 0,
  }) : super(key: key);

  @override
  _FitnessSettingPageState createState() => _FitnessSettingPageState();
}

class _FitnessSettingPageState extends State<FitnessSettingPage> {
  late int fitnessLevel;

  @override
  void initState() {
    super.initState();
    fitnessLevel = widget.initialFitnessLevel;
  }

  bool isGoalSelected(int goal) {
    return fitnessLevel == goal;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options2 = [
      AppLocalizations.of(context)!.frequencyRarely,
      AppLocalizations.of(context)!.frequencyMultipleMonthly,
      AppLocalizations.of(context)!.frequencyWeekly,
      AppLocalizations.of(context)!.frequencyMultipleWeekly,
      AppLocalizations.of(context)!.frequencyDaily,
    ];

    Widget goalTile(int index) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isGoalSelected(index)
              ? const Color(0xFF59c977)
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: isGoalSelected(index)
                  ? const Color(0xFF48a160)
                  : Colors.transparent,
              offset: const Offset(0, 5),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            options2[index],
            style: TextStyle(
              color: isGoalSelected(index) ? Colors.white : Colors.grey[400],
            ),
          ),
          onTap: () {
            setState(() {
              fitnessLevel = index;
            });
          },
        ),
      );
    }

    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    return Stack(children: <Widget>[
      Image.asset(
        "assets/settingsbg.PNG",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            AppLocalizations.of(context)!.setFitnessLevel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppLocalizations.of(context)!.currentFitnessLevelQuestion,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...List.generate(
              options2.length,
              (index) => goalTile(index),
            ),
          ],
        ),
        floatingActionButton: PressableButton(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            profilProvider.setFitnessLevel(fitnessLevel);
            getAuthToken().then((token) {
              if (token != null) {
                updateProfile(
                  token: token,
                  fitnessLevel: fitnessLevel,
                ).then((success) {
                  if (success) {
                    print("Profile updated successfully.");
                  } else {
                    print("Failed to update profile.");
                  }
                });
              } else {
                print("No auth token available.");
              }
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    ]);
  }
}

class PainSettingPage extends StatefulWidget {
  final List<int> initialSelectedPainAreas;

  const PainSettingPage({Key? key, required this.initialSelectedPainAreas})
      : super(key: key);

  @override
  _PainSettingPageState createState() => _PainSettingPageState();
}

class _PainSettingPageState extends State<PainSettingPage> {
  late Map<int, bool> painAreas;

  @override
  void initState() {
    super.initState();
    painAreas = {};
    // Initialize all pain areas as false
    for (var areaKey in List<int>.generate(10, (index) => index)) {
      painAreas[areaKey] = false;
    }
    // Set the initial state for the pain areas that are selected
    for (var area in widget.initialSelectedPainAreas) {
      if (painAreas.containsKey(area)) {
        painAreas[area] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> allPainAreas = {
      0: AppLocalizations.of(context)!.lowerBack,
      1: AppLocalizations.of(context)!.upperBack,
      2: AppLocalizations.of(context)!.neck,
      3: AppLocalizations.of(context)!.knee,
      4: AppLocalizations.of(context)!.wrists,
      5: AppLocalizations.of(context)!.feet,
      6: AppLocalizations.of(context)!.ankle,
      7: AppLocalizations.of(context)!.hip,
      8: AppLocalizations.of(context)!.jaw,
      9: AppLocalizations.of(context)!.shoulder,
    };

    Widget painAreaTile(int areaKey) {
      return CheckboxListTile(
        title: Text(
          allPainAreas[areaKey]!,
          style: const TextStyle(color: Colors.white),
        ),
        side: const BorderSide(
          width: 1.0,
          color: Colors.white,
        ),
        value: painAreas[areaKey],
        onChanged: (bool? value) {
          setState(() {
            painAreas[areaKey] = value!;
          });
        },
        hoverColor: Colors.white,
        checkColor: Colors.white,
        activeColor: Colors.green,
      );
    }

    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    return Stack(children: <Widget>[
      Image.asset(
        "assets/settingsbg.PNG",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white, // Sets the color of the back arrow to white
          ),
          title: Text(
            AppLocalizations.of(context)!.editPainAreasTitle,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              AppLocalizations.of(context)!.selectPainAreasPrompt,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...allPainAreas.keys.map((key) => painAreaTile(key)).toList(),
          ],
        ),
        floatingActionButton: PressableButton(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            List<int> selectedPainAreas = painAreas.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();

            profilProvider.setHasPain(selectedPainAreas);

            getAuthToken().then((token) {
              if (token != null) {
                updateProfile(
                  token: token,
                  painAreas: selectedPainAreas,
                ).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .profileUpdateSuccess)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.profileUpdateError)));
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.authTokenUnavailable)));
              }
            });
            Navigator.of(context).pop();
          },
        ),
      )
    ]);
  }
}

class SubscriptionSettingPage extends StatefulWidget {
  const SubscriptionSettingPage({Key? key}) : super(key: key);

  @override
  _SubscriptionSettingPageState createState() =>
      _SubscriptionSettingPageState();
}

class _SubscriptionSettingPageState extends State<SubscriptionSettingPage> {
  String? selectedSubscription;

  bool isSubscriptionSelected(String subscription) {
    return selectedSubscription == subscription;
  }

  Widget subscriptionOption(String type, String displayText) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubscription = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSubscriptionSelected(type)
              ? const Color(0xFF59c977)
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: isSubscriptionSelected(type)
                  ? const Color(0xFF48a160)
                  : Colors.transparent,
              offset: const Offset(0, 5),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            displayText,
            style: TextStyle(
                color: isSubscriptionSelected(type)
                    ? Colors.white
                    : Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/settingsbg.PNG",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(AppLocalizations.of(context)!.chooseSubscription,
                style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              subscriptionOption(
                  AppLocalizations.of(context)!.yearlySubscription,
                  AppLocalizations.of(context)!.yearly),
              subscriptionOption(
                  AppLocalizations.of(context)!.monthlySubscription,
                  AppLocalizations.of(context)!.monthly),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (selectedSubscription != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSettingPage(
                          subscriptionType: selectedSubscription!),
                    ));
              } else {
                // Show a message to select a subscription
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .selectSubscriptionWarning),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.check, color: Colors.white),
          ),
        )
      ],
    );
  }
}

class PaymentSettingPage extends StatefulWidget {
  final String subscriptionType;

  const PaymentSettingPage({Key? key, required this.subscriptionType})
      : super(key: key);

  @override
  _PaymentSettingPageState createState() => _PaymentSettingPageState();
}

class _PaymentSettingPageState extends State<PaymentSettingPage> {
  String? selectedPaymentMethod;
  late InAppPurchase inAppPurchase;
  bool available = true;
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Server URL for receipt validation
  final String _validationUrl = 'http://34.116.240.55:3000/validate-receipt';

  @override
  void initState() {
    super.initState();
    inAppPurchase = InAppPurchase.instance;

    // Set up purchase stream listener early
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        print('Purchase stream error: $error');
      },
    );

    initializeInAppPurchase();

    // Set default payment method
    selectedPaymentMethod = AppLocalizations.of(context)!.inAppPurchase;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Initialize the in-app purchase system
  Future<void> initializeInAppPurchase() async {
    try {
      final bool isAvailable = await inAppPurchase.isAvailable();
      setState(() {
        available = isAvailable;
      });

      if (available) {
        // Define product IDs: 0001 for yearly, 0002 for monthly
        const Set<String> productIds = {'0001', '0002'};
        final ProductDetailsResponse response =
            await inAppPurchase.queryProductDetails(productIds);

        if (response.error != null) {
          print('Error querying product details: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          print(
              'No products found. This could be due to the following reasons:');
          print(
              '1. Products are not properly configured in App Store/Play Console');
          print(
              '2. The app\'s package name/bundle ID doesn\'t match the one in the store');
          print('3. The app was not properly signed');
        } else {
          setState(() {
            products = response.productDetails;
          });

          // Log product details for debugging
          for (var product in products) {
            print(
                'Found product: ${product.id}, ${product.title}, ${product.price}');
          }
        }
      } else {
        print('In-App Purchase is not available on this device.');

        // Show a notification to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.inAppPurchaseNotAvailable),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('An error occurred during in-app purchase initialization: $e');
    }
  }

  // Handle purchase updates
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      _processPurchaseUpdate(purchaseDetails);
    }

    setState(() {
      purchases = purchaseDetailsList;
    });
  }

  // Process individual purchase update
  Future<void> _processPurchaseUpdate(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Show loading indicator
      _showLoadingDialog(AppLocalizations.of(context)!.buyNow);
    } else {
      // Close loading dialog if it's open
      Navigator.of(context, rootNavigator: true).popUntil((route) {
        return route.isFirst || route.settings.name != 'loading_dialog';
      });

      if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error case
        _handlePurchaseError(purchaseDetails.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Validate and process successful purchase
        await _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        print('Purchase cancelled by user');
      }

      // Complete the purchase to prevent duplicate updates
      if (purchaseDetails.pendingCompletePurchase) {
        await inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // Show loading dialog
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: 'loading_dialog'),
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Handle purchase errors
  void _handlePurchaseError(dynamic error) {
    if (error != null) {
      // Extract information from error object regardless of its type
      final errorMessage = error.toString();
      print('Purchase Error: $errorMessage');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Verify purchase with server
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.productID == '0001' ||
          purchaseDetails.productID == '0002') {
        // First update local state
        final profilProvider =
            Provider.of<ProfilProvider>(context, listen: false);

        // Now send validation request to server
        Map<String, dynamic> validationData = {
          'platform': Platform.isIOS ? 'apple' : 'google',
          'username': '', // Get username if you have it stored
          'isSubscription': true,
        };

        // Add platform-specific validation data
        if (Platform.isIOS) {
          validationData['receiptData'] =
              purchaseDetails.verificationData.serverVerificationData;
        } else {
          // For Android
          if (purchaseDetails is GooglePlayPurchaseDetails) {
            validationData['packageName'] =
                'com.backquest.app'; // Your app's package name
            validationData['productId'] = purchaseDetails.productID;
            validationData['purchaseToken'] =
                purchaseDetails.billingClientPurchase.purchaseToken;
          }
        }

        // Send validation request to server
        final response = await http.post(
          Uri.parse(_validationUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(validationData),
        );

        print(
            'Server validation response: ${response.statusCode} ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['valid'] == true) {
            // Update local subscription status regardless
            profilProvider.setPayedSubscription(true);

            // 0002 is monthly, 0001 is yearly
            profilProvider.setSubType(purchaseDetails.productID == '0002'
                ? AppLocalizations.of(context)!.monthlySubscription
                : AppLocalizations.of(context)!.yearlySubscription);
            profilProvider.setSubStarted(DateTime.now());

            // Store receipt data
            profilProvider.setReceiptData(
                purchaseDetails.verificationData.serverVerificationData);

            // Show success message
            QuickAlert.show(
              backgroundColor: Colors.grey.shade900,
              textColor: Colors.white,
              context: context,
              type: QuickAlertType.success,
              title: AppLocalizations.of(context)!.paymentSuccessTitle,
              text: AppLocalizations.of(context)!.paymentSuccessMessage,
            );
          } else {
            // Purchase validated as invalid by our server
            _showInvalidPurchaseAlert(
                responseData['error'] ?? 'Validation failed');
          }
        } else {
          // Server error
          print('Server error during validation: ${response.body}');
          // Still update local state, just log the server error
          profilProvider.setPayedSubscription(true);
          profilProvider.setSubType(purchaseDetails.productID == '0002'
              ? AppLocalizations.of(context)!.monthlySubscription
              : AppLocalizations.of(context)!.yearlySubscription);
          profilProvider.setSubStarted(DateTime.now());
          profilProvider.setReceiptData(
              purchaseDetails.verificationData.serverVerificationData);

          QuickAlert.show(
            backgroundColor: Colors.grey.shade900,
            textColor: Colors.white,
            context: context,
            type: QuickAlertType.success,
            title: AppLocalizations.of(context)!.paymentSuccessTitle,
            text: AppLocalizations.of(context)!.paymentSuccessMessage +
                "\n" +
                "Note: Server validation pending.",
          );
        }
      }
    } catch (e) {
      print('Error verifying purchase: $e');

      // Show error alert
      QuickAlert.show(
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        context: context,
        type: QuickAlertType.error,
        title: "Verification Error",
        text:
            "There was an error verifying your purchase. Please contact support if the issue persists.",
      );
    }
  }

  // Show invalid purchase alert
  void _showInvalidPurchaseAlert(String message) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade900,
      textColor: Colors.white,
      context: context,
      type: QuickAlertType.error,
      title: "Purchase Validation Failed",
      text: message,
    );
  }

  bool isMethodSelected(String method) {
    return selectedPaymentMethod == method;
  }

  // Purchase a product
  void _purchaseProduct(ProductDetails productDetails) {
    try {
      print('Initiating purchase for: ${productDetails.id}');

      // Configure purchase parameters
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null, // Can be used for user identification
      );

      // Start the purchase flow - always use non-consumable for subscriptions
      if (Platform.isIOS) {
        inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // On Android, we need to determine if it's a subscription
        final bool isSubscription =
            productDetails.id == '0001' || productDetails.id == '0002';

        if (isSubscription) {
          inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        } else {
          inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
        }
      }
    } catch (e) {
      print('Error purchasing product: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating purchase: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle payment
  void handlePayment() async {
    if (!available) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.green,
          title: Text(AppLocalizations.of(context)!.errorTitle),
          content:
              Text(AppLocalizations.of(context)!.inAppPurchaseNotAvailable),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
      return;
    }

    ProductDetails? product;
    try {
      // Select the product based on subscription type
      if (widget.subscriptionType ==
          AppLocalizations.of(context)!.yearlySubscription) {
        // 0001 is for yearly subscription
        product = products.firstWhere((product) => product.id == '0001');
      } else {
        // 0002 is for monthly subscription
        product = products.firstWhere((product) => product.id == '0002');
      }
    } catch (e) {
      product = null;
    }

    if (product != null) {
      _purchaseProduct(product);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.errorTitle),
          content: Text(AppLocalizations.of(context)!.subscriptionNotAvailable),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
    }
  }

  Widget methodTile(String method) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isMethodSelected(method)
            ? const Color(0xFF59c977)
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isMethodSelected(method)
                ? const Color(0xFF48a160)
                : Colors.transparent,
            offset: const Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          method,
          style: TextStyle(
              color:
                  isMethodSelected(method) ? Colors.white : Colors.grey[400]),
        ),
        onTap: () {
          setState(() {
            selectedPaymentMethod = method;
          });
        },
      ),
    );
  }

  Widget typeTile(String subType) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF59c977),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF48a160),
            offset: Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        subType == AppLocalizations.of(context)!.yearlySubscription
            ? AppLocalizations.of(context)!.yearly
            : AppLocalizations.of(context)!.monthly,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/settingsbg.PNG",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              AppLocalizations.of(context)!
                  .paymentMethodFor(widget.subscriptionType),
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              typeTile(widget.subscriptionType),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    methodTile(AppLocalizations.of(context)!.inAppPurchase),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: handlePayment,
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}

class AGB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.agb),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.agbContent,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class Datasecurity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dataPrivacy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.dataPrivacyContent,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class Impressum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.impressum),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.impressumContent,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class Kontakt extends StatelessWidget {
  final String email = 'info@backquest.online';
  final String appleSubscriptionUrl =
      'https://support.apple.com/en-us/HT202039';

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      print('Could not launch email client');
    }
  }

  void _launchAppleSubscription() async {
    if (await canLaunch(appleSubscriptionUrl)) {
      await launch(appleSubscriptionUrl);
    } else {
      print('Could not launch Apple subscription URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contact),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contact,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _launchEmail,
              child: Text(
                email,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.changeSubscription,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _launchAppleSubscription,
              child: Text(
                AppLocalizations.of(context)!.appleSubscriptionManagement,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteAccountPage extends StatefulWidget {
  final Function(bool) setAuthenticated;

  const DeleteAccountPage({
    Key? key,
    required this.setAuthenticated,
  }) : super(key: key);

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  bool _confirmDelete = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _requestAccountDeletion() async {
    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar("Please enter your password");
      return;
    }

    if (!_confirmDelete) {
      _showErrorSnackBar("Please confirm account deletion");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = await getAuthToken();
      if (token == null) {
        _showErrorSnackBar("Authentication error. Please login again.");
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://34.116.240.55:3000/requestDeletion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': _passwordController.text,
          'reason': _reasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Account deletion request successful
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Request Submitted",
          text:
              "Your account deletion request has been submitted. You will receive a confirmation email shortly.",
          onConfirmBtnTap: () {
            // Log the user out
            final AuthService authService = AuthService();
            authService.logout();
            widget.setAuthenticated(false);

            // Navigate back to the main screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      } else {
        // Handle various error responses
        final Map<String, dynamic> responseData = json.decode(response.body);
        _showErrorSnackBar(
            responseData['message'] ?? "Failed to submit deletion request");
      }
    } catch (e) {
      _showErrorSnackBar("Network error: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.asset(
        "assets/settingsbg.PNG",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            "Delete Account",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "Warning: Account deletion is permanent. All your data, including progress and subscription information, will be permanently removed.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Reason for Leaving (Optional)",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile(
                title: const Text(
                  "I understand this action is permanent and cannot be undone",
                  style: TextStyle(color: Colors.white),
                ),
                value: _confirmDelete,
                onChanged: (value) {
                  setState(() {
                    _confirmDelete = value ?? false;
                  });
                },
                activeColor: Colors.red,
                checkColor: Colors.white,
              ),
              const SizedBox(height: 24.0),
              PressableButton(
                onPressed: _isSubmitting ? null : _requestAccountDeletion,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.red,
                shadowColor: Colors.red.shade900,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Request Account Deletion",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
