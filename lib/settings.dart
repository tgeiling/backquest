import 'dart:convert';

import 'package:backquest/elements.dart';
import 'package:backquest/services.dart';
import 'package:backquest/stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'auth.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;

  const SettingsPage({
    Key? key,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
    bool payedUp = profilProvider.payedSubscription == true ? true : false;

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
              tiles: [
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
                LoginTile(
                  title: AppLocalizations.of(context)!.login,
                  icon: Icons.login,
                  setAuthenticated: setAuthenticated,
                  setQuestionnairDone: setQuestionnairDone,
                ),
                SettingsTile(
                  title: AppLocalizations.of(context)!.logout,
                  icon: Icons.logout,
                  onTileTap: setAuthenticated,
                ),
                SettingsTile(
                    title: payedUp
                        ? AppLocalizations.of(context)!.mySubscription
                        : AppLocalizations.of(context)!.subscribeBackQuest,
                    icon: Icons.payments_sharp),
              ],
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
        } else if (title == AppLocalizations.of(context)!.mySubscription) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MySubscriptionPage()),
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

class MySubscriptionPage extends StatelessWidget {
  const MySubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    final String? activeSubscription = profilProvider.subType;
    final DateTime? subscriptionStartDate = profilProvider.subStarted;

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
              AppLocalizations.of(context)!.mySubscriptionTitle,
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.activeSubscription,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                if (activeSubscription == "Jährlich" ||
                    activeSubscription == "Monatlich")
                  _buildSubscriptionTile(
                    context,
                    activeSubscription!,
                    true, // Since it's the active subscription
                    subscriptionStartDate,
                  ),
                if (activeSubscription == null)
                  Text(
                    AppLocalizations.of(context)!.noActiveSubscription,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionTile(BuildContext context, String subType,
      bool isActive, DateTime? startDate) {
    final formattedDate = startDate != null
        ? DateFormat('dd. MMMM yyyy', AppLocalizations.of(context)!.locale)
            .format(startDate)
        : AppLocalizations.of(context)!.dateUnavailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF59c977) : Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isActive ? const Color(0xFF48a160) : Colors.transparent,
            offset: const Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subType == 'Jährlich'
                ? AppLocalizations.of(context)!.yearlySubscription
                : AppLocalizations.of(context)!.monthlySubscription,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          if (isActive && startDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                '${AppLocalizations.of(context)!.startedOn} $formattedDate',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          if (isActive)
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 20,
              ),
            ),
        ],
      ),
    );
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

  Widget subscriptionOption(String type, String price) {
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
          title: Text('$type: $price',
              style: TextStyle(
                  color: isSubscriptionSelected(type)
                      ? Colors.white
                      : Colors.grey[400],
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
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
            title: const Text('Choose Your Subscription',
                style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              subscriptionOption('Jährlich', '€49.99/Jahr'),
              subscriptionOption('Monatlich', '€5.99/Monat'),
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

  @override
  void initState() {
    super.initState();
    inAppPurchase = InAppPurchase.instance;
    initializeInAppPurchase();
  }

  // Initialize the in-app purchase system
  Future<void> initializeInAppPurchase() async {
    try {
      final bool isAvailable = await inAppPurchase.isAvailable();
      setState(() {
        available = isAvailable;
      });

      if (available) {
        const Set<String> productIds = {'03', '04'};
        final ProductDetailsResponse response =
            await inAppPurchase.queryProductDetails(productIds);

        print("##################################");
        print(response);
        print("##################################");

        if (response.error != null) {
          print('Error querying product details: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          print(
              'No products found. This could be due to the following reasons:');
        } else {
          products = response.productDetails;
        }
      } else {
        print('In-App Purchase is not available on this device.');
      }
    } catch (e) {
      print('An error occurred during in-app purchase initialization: $e');
    }
  }

  // Handle purchase updates
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyPurchase(purchaseDetails);
        if (purchaseDetails.pendingCompletePurchase) {
          inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Purchase Error: ${purchaseDetails.error}');
      }
    }

    setState(() {
      purchases = purchaseDetailsList;
    });
  }

  // Verify purchase
  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.productID == '03' ||
          purchaseDetails.productID == '04') {
        final profilProvider =
            Provider.of<ProfilProvider>(context, listen: false);
        profilProvider.setPayedSubscription(true);
        profilProvider.setSubType(
            purchaseDetails.productID == '03' ? 'Monatlich' : 'Jährlich');
        profilProvider.setSubStarted(DateTime.now());

        profilProvider.setReceiptData(
            purchaseDetails.verificationData.serverVerificationData);

        QuickAlert.show(
          backgroundColor: Colors.grey.shade900,
          textColor: Colors.white,
          context: context,
          type: QuickAlertType.success,
          title: 'Zahlung Erfolgreich',
          text: 'Danke, dass Sie BackQuest abonniert haben!',
        );
      }
    } catch (e) {
      print('Error verifying purchase: $e');
    }
  }

  bool isMethodSelected(String method) {
    return selectedPaymentMethod == method;
  }

  // Purchase a product
  void _purchaseProduct(ProductDetails productDetails) {
    try {
      print(productDetails);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      print(purchaseParam);
      inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error purchasing product: $e');
    }
  }

  // Handle payment
  void handlePayment() async {
    if (!available) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.green,
          title: const Text('Error'),
          content: const Text('In-App Purchases are not available.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    ProductDetails? product;
    try {
      if (widget.subscriptionType == 'Jährlich') {
        product = products.firstWhere((product) => product.id == '04');
      } else {
        product = products.firstWhere((product) => product.id == '03');
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
          title: const Text('Error'),
          content: const Text('Selected subscription type is not available.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
        subType == 'Jährlich'
            ? "Jährlich: \n 49,99 € \n Jahr"
            : "Monatlich: \n 5,99 € \n Monat",
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
              'Payment Method for ${widget.subscriptionType}',
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
                    methodTile('In-App Purchase'),
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
