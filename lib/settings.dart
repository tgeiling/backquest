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
          title: const Text("Einstellungen",
              style: TextStyle(color: Colors.white)),
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
                const SettingsTile(
                    title: 'Ziele anpassen', icon: Icons.bar_chart),
                const SettingsTile(
                    title: 'Schmerzen anpassen', icon: Icons.sports_tennis),
                const SettingsTile(
                    title: 'Fitnesslevel anpassen', icon: Icons.bolt),
                const SettingsTile(title: 'AGB', icon: Icons.article),
                const SettingsTile(
                    title: 'Datenschutzerklärung', icon: Icons.privacy_tip),
                const SettingsTile(
                    title: 'Impressum', icon: Icons.info_outline),
                LoginTile(
                  title: 'Login',
                  icon: Icons.login,
                  setAuthenticated: setAuthenticated,
                  setQuestionnairDone: setQuestionnairDone,
                ),
                SettingsTile(
                  title: 'Logout',
                  icon: Icons.logout,
                  onTileTap: setAuthenticated,
                ),
                /* SettingsTile(
                    title: payedUp ? "Mein Abonnement" : 'Backquest abonnieren',
                    icon: Icons.payments_sharp), */
                const SettingsTile(title: 'Kontakt', icon: Icons.contact_mail),
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
        if (title == 'Ziele anpassen') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GoalSettingPage(
                      initialWeeklyGoal: profilProvider.weeklyGoal,
                    )),
          );
        } else if (title == 'Schmerzen anpassen') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PainSettingPage(
                      initialSelectedPainAreas: profilProvider.hasPain,
                    )),
          );
        } else if (title == 'Fitnesslevel anpassen') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FitnessSettingPage(
                      initialFitnessLevel: profilProvider.fitnessLevel,
                    )),
          );
        } else if (title == 'AGB') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AGB(),
            ),
          );
        } else if (title == 'Datenschutzerklärung') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Datasecurity(),
            ),
          );
        } else if (title == 'Impressum') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Impressum(),
            ),
          );
        } else if (title == 'Logout') {
          authService.logout();
          onTileTap?.call(false);
          Navigator.pop(context);
        } /* else if (title == 'Backquest abonnieren') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SubscriptionSettingPage()),
          );
        } */
        else if (title == 'Mein Abonnement') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MySubscriptionPage()),
          );
        } else if (title == 'Kontakt') {
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
        title: Text(title),
      ),
      body: Center(
        child: Text('Information for $title'),
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
          '$goal Einheiten',
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
          title: const Text('Setze deine Ziele',
              style: TextStyle(color: Colors.white)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Wöchentliche Übungen Ziele:',
                  style: Theme.of(context).textTheme.titleLarge),
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
  final String initialFitnessLevel;

  const FitnessSettingPage({
    Key? key,
    this.initialFitnessLevel =
        'Einmal pro Woche', // Default value adjusted to string
  }) : super(key: key);

  @override
  _FitnessSettingPageState createState() => _FitnessSettingPageState();
}

class _FitnessSettingPageState extends State<FitnessSettingPage> {
  late String fitnessLevel;

  @override
  void initState() {
    super.initState();
    fitnessLevel = widget.initialFitnessLevel;
  }

  bool isGoalSelected(String goal) {
    return fitnessLevel == goal;
  }

  Widget goalTile(String goal) {
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
        title: Text(goal,
            style: TextStyle(
                color: isGoalSelected(goal) ? Colors.white : Colors.grey[400])),
        onTap: () {
          setState(() {
            fitnessLevel = goal;
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
          title: const Text('Setze deine Fitnesslevel',
              style: TextStyle(color: Colors.white)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Welches Fitnesslevel hast du jetzt ?',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            ...options2.map((option) => goalTile(option)).toList(),
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
      )
    ]);
  }
}

// The list of fitness level options
final List<String> options2 = [
  'Nicht so oft',
  'Mehrmals im Monat',
  'Einmal pro Woche',
  'Mehrmals pro Woche',
  'Täglich',
];

class PainSettingPage extends StatefulWidget {
  final List<String> initialSelectedPainAreas;

  const PainSettingPage({Key? key, required this.initialSelectedPainAreas})
      : super(key: key);

  @override
  _PainSettingPageState createState() => _PainSettingPageState();
}

class _PainSettingPageState extends State<PainSettingPage> {
  late Map<String, bool> painAreas;

  static final Map<String, bool> allPainAreas = {
    'Unterer Rücken': false,
    'Oberer Rücken': false,
    'Nacken': false,
    'Knie': false,
    'Hand gelenke': false,
    'Füße': false,
    'Sprung gelenk': false,
    'Hüfte': false,
    'Kiefer': false,
    'Schulter': false,
  };

  @override
  void initState() {
    super.initState();
    painAreas = Map<String, bool>.from(allPainAreas);
    // Set the initial state for the pain areas that are selected
    for (var area in widget.initialSelectedPainAreas) {
      if (painAreas.containsKey(area)) {
        painAreas[area] = true;
      }
    }
  }

  Widget painAreaTile(String area) {
    return CheckboxListTile(
      title: Text(
        area,
        style: const TextStyle(color: Colors.white),
      ),
      side: BorderSide(
        width: 1.0,
        color: Colors.white,
      ),
      value: painAreas[area],
      onChanged: (bool? value) {
        setState(() {
          painAreas[area] = value!;
        });
      },
      hoverColor: Colors.white,
      checkColor: Colors.white,
      activeColor: Colors.green,
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
          title: const Text('Setze deine Ziele',
              style: TextStyle(color: Colors.white)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              child: Text('Wähle die Bereiche, in denen du Schmerzen hast.',
                  style: Theme.of(context).textTheme.titleLarge),
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
            profilProvider.setHasPain(painAreas.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList());
            getAuthToken().then((token) {
              if (token != null) {
                updateProfile(
                  token: token,
                  painAreas: painAreas.entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .toList(),
                ).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Profil erfolgreich aktualisiert.")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("Fehler beim Aktualisieren des Profils.")));
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Kein Authentifizierungstoken verfügbar.")));
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
            title: const Text(
              'Dein Abonnement',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Aktives Abonnement",
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
                  const Text(
                    "Kein aktives Abonnement",
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
        ? DateFormat('dd. MMMM yyyy', 'de_DE').format(startDate)
        : 'Datum nicht verfügbar';

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
                ? "Jährlich: \n 49,99 € \n Jahr"
                : "Monatlich: \n 5,99 € \n Monat",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          if (isActive && startDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Begonnen am: $formattedDate',
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

/* class SubscriptionSettingPage extends StatefulWidget {
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
 */
class AGB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AGB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
AGB BackQuest 1

Allgemeine Geschäftsbedingungen

1. Allgemeines und Geltungsbereich 1.1 Die BackQuest GbR, entwickelt und betreibt die Webseite www.backquest.online (im Folgenden "Website") sowie die mobile Anwendung "BackQuest App" (im Folgenden "App"). BackQuest bietet registrierten Nutzern angeleitete Fitnessübungen zur Prävention von Rückenschmerzen, zur Verbesserung der Beweglichkeit sowie zur Entspannung (im folgenden Kurse genannt) über die App an. Als "Nutzer" gelten alle natürlichen Personen, die die Website, die App und/oder die darin angebotenen Kurse nutzen. 1.2 Diese vorliegenden Allgemeinen Geschäftsbedingungen (im Folgenden "AGB") in ihrer zum Zeitpunkt des Vertragsschlusses gültigen Fassung gelten für das gesamte Leistungsangebot des Anbieters. 1.3 Abweichende oder ergänzende Geschäftsbedingungen des Nutzers werden nicht Vertragsbestandteil, es sei denn, der Anbieter stimmt ihrer Geltung ausdrücklich in Textform zu. Diese AGB gelten auch dann, wenn der Anbieter Leistungen vorbehaltlos ausführt, obwohl entgegenstehende oder von diesen AGB abweichende Bedingungen des Nutzers bekannt sind, es sei denn, der Anbieter hat zuvor seine Zustimmung in Textform erteilt.
2. Gesundheitszustand des Nutzers 2.1 Die Nutzung der Coachings setzt einen stabilen gesundheitlichen Allgemeinzustand voraus. Der Nutzer sichert zu, diese Voraussetzung zu erfüllen. 2.2 Die Angebote von BackQuest sowie die Kurse dienen nicht als ärztliche Beratung oder medizinische Untersuchung und ersetzen keinesfalls den Besuch eines Arztes. Das Ziel der App besteht darin, das Bewusstsein für Gesundheitsthemen zu schärfen und die Nutzer zu mehr Bewegung und Entspannung zu motivieren. 2.3 Nutzer, die medizinische oder therapeutische Diagnosen oder Behandlungen benötigen oder erhalten haben, sowie Schwangere müssen vor der Nutzung der Kurse Rücksprache mit ihrem Arzt oder Therapeuten halten. 2.4 Die Nutzung der Kurse erfolgt auf eigenes Risiko. Sollte der Nutzer während oder nach der Anwendung der Kurse Schmerzen oder Unwohlsein verspüren, sollte er den Kurs umgehend abbrechen und es wird dringend empfohlen einen Arzt aufzusuchen.

AGB BackQuest 2

3. BackQuest Angebote 3.1 Die Kurse des Anbieters werden mithilfe einer interaktiven, softwarebasierten Anwendung zur online-gestützten Prävention von Rückenschmerzen angeboten. Die App bietet dazu individuell zusammengestellte Videos an, die die Nutzer in einer vorgegebenen Reihenfolge absolvieren können. Zusätzlich können die Nutzer die beigefügten textbasierten Informationen lesen, um mehr zu den wissenschaftlichen Hintergründen des Trainings zu erfahren. 3.2 Der Anbieter entwickelt die Software und deren Inhalte kontinuierlich weiter. Dabei können neue Funktionen eingeführt, bestehende Funktionen durch neue ersetzt oder ohne Ersatz entfernt werden.
4. Registrierung und Nutzung 4.1 Die Nutzungsmöglichkeit der App erfolgt mit der Installation. Die derzeit vorliegende Betaversion kann von allen Nutzer kostenlos genutzt werden. 4.2 Die Nutzung erfordert die Erstellung eines Nutzerkontos. Ein solches Nutzerkonto darf nicht an Dritte übertragen werden. Der Anbieter behält sich das Recht vor, die bei der Registrierung angegebenen Daten durch geeignete Maßnahmen zu überprüfen. 4.3 Durch die Bestätigung der Registrierung seitens des Anbieters kommt zwischen dem Anbieter und dem Nutzer ein Vertrag über die Nutzung des Leistungsangebots zustande. 4.4 Die Registrierung erfordert, dass der Nutzer entweder 18 Jahre alt ist oder die ausdrückliche Einwilligung des/der Erziehungsberechtigten vorliegt.
5. Widerrufsbelehrung 5.1 Nutzer, die Verbraucher im Sinne von § 13 BGB sind, haben ein gesetzlich vorgeschriebenes Widerrufsrecht. 5.2 Ein Verbraucher ist jede natürliche Person, die ein Rechtsgeschäft zu Zwecken abschließt, die weder ihrer gewerblichen noch ihrer selbstständigen beruflichen Tätigkeit zugerechnet werden können (§ 13 BGB).

AGB BackQuest 3

6. Widerrufsrecht 6.1 Soweit ein BackQuest Produkt gegen Entgelt erworben wurde, steht dem Nutzer ein Widerrufsrecht zu. Sie haben das Recht, binnen vierzehn Tagen ohne Angabe von Gründen diesen Vertrag zu widerrufen. Die Widerrufsfrist beträgt vierzehn Tage ab dem Tag des Vertragsabschlusses. Um Ihr Widerrufsrecht auszuüben, müssen Sie uns mittels einer eindeutigen Erklärung (z.B. ein mit der Post versandter Brief, Telefax oder E-Mail) über Ihren Entschluss, diesen Vertrag zu widerrufen, informieren. Sie können dafür das beigefügte Muster-Widerrufsformular verwenden, das jedoch nicht vorgeschrieben ist. 6.2 Zur Wahrung der Widerrufsfrist genügt es, dass Sie die Mitteilung über die Ausübung des Widerrufsrechts vor Ablauf der Widerrufsfrist absenden. 6.3 Ihr Widerrufsrecht erlischt vorzeitig, wenn wir die Dienstleistung vollständig erbracht und mit der Ausführung der Dienstleistung erst begonnen haben, nachdem Sie als Verbraucher dazu Ihre ausdrückliche Zustimmung gegeben und gleichzeitig Ihre Kenntnis davon bestätigt haben, dass Sie Ihr Widerrufsrecht bei vollständiger Vertragserfüllung durch uns verlieren. 6.4 Folgen des Widerrufs: Wenn Sie diesen Vertrag widerrufen, haben wir Ihnen alle Zahlungen, die wir von Ihnen erhalten haben, unverzüglich und spätestens binnen vierzehn Tagen ab dem Tag zurückzuzahlen, an dem die Mitteilung über Ihren Widerruf dieses Vertrages bei uns eingegangen ist. Für diese Rückzahlung verwenden wir dasselbe Zahlungsmittel, das Sie bei der ursprünglichen Transaktion eingesetzt haben, es sei denn, mit Ihnen wurde ausdrücklich etwas anderes vereinbart; in keinem Fall werden Ihnen wegen dieser Rückzahlung Entgelte berechnet. Haben Sie verlangt, dass die Dienstleistungen während der Widerrufsfrist beginnen sollen, so haben Sie uns einen angemessenen Betrag zu zahlen, der dem Anteil der bis zum Zeitpunkt, zu dem Sie uns von der Ausübung des Widerrufsrechts hinsichtlich dieses Vertrages unterrichten, bereits erbrachten Dienstleistungen im Vergleich zum Gesamtumfang der im Vertrag vorgesehenen Dienstleistungen entspricht. Falls unsere Leistungen bisher unentgeltlich waren, haben Sie keinen Anspruch auf Rückerstattung.

AGB BackQuest 4

6.5 Muster-Widerrufsformular (Wenn Sie den Vertrag widerrufen möchten, füllen Sie bitte dieses Formular aus und senden Sie es zurück.) BackQuest GbR, Gärtnerweg 62, 60322 Frankfurt, hallo@backquest.online Hiermit widerrufe(n) ich/wir () den von mir/uns () abgeschlossenen Vertrag über den Kauf der folgenden Waren: () / die Erbringung der folgenden Dienstleistung: () Bestellt am ______________() / erhalten am ______________() Name des/der Verbraucher(s) ______________ Anschrift des/der Verbraucher(s) _______________ (nur bei Mitteilung auf Papier) Datum _______________ (*) Unzutreffendes streichen. Als Online-Unternehmen ist der Anbieter dazu verpflichtet, den Kunden als Verbraucher auf die Plattform zur Online-Streitbeilegung (OS-Plattform) der Europäischen Kommission hinzuweisen. Diese OS-Plattform ist über den folgenden Link erreichbar: Online Dispute Resolution | European Commission . Der Anbieter nimmt jedoch nicht an einem Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teil. Der Anbieter speichert den Vertragstext nicht.
7. Vertragslaufzeit und Kündigung 7.1 Die Laufzeit einer Mitgliedschaft beginnt mit dem Vertragsabschluss. 7.2 Die Bestimmungen und der Vertrag zwischen dem Nutzer und der BackQuest GbR gelten auf unbestimmte Zeit, soweit sie nicht vom Nutzer oder der BackQuest GbR gekündigt werden. 7.3 Nach Beendigung der Mitgliedschaft können keine Inhalte in der App mehr abgerufen werden. Die vom Nutzer eingegebenen Daten bleiben jedoch in seinem Nutzerprofil gespeichert. 7.4 Das Recht zur außerordentlichen Kündigung aus wichtigem Grund bleibt unberührt.

AGB BackQuest 5

8. Sperrung des Zugangs 8.1 Der Anbieter behält sich das Recht vor, den Zugang des Nutzers zu sperren, wenn ein begründeter Verdacht auf eine missbräuchliche Nutzung oder eine wesentliche Vertragsverletzung besteht. Der Nutzer ist unverzüglich anzuhören. Sollte sich der Verdacht als unbegründet erweisen, wird die Sperrung aufgehoben und die Laufzeit der Mitgliedschaft um den Zeitraum der Sperrung verlängert. Andernfalls ist der Anbieter berechtigt, das Vertragsverhältnis außerordentlich zu kündigen. 8.2 Wenn der Vertrag durch eine außerordentliche Kündigung vor Ablauf der Mindestvertragslaufzeit endet, bleibt der Nutzer verpflichtet, die vollständige Gegenleistung bis zum Zeitpunkt der möglichen ordentlichen Kündigung zu erbringen.
9. Pflichten des Nutzers 9.1 Der Nutzer ist selbst dafür verantwortlich, die erforderlichen Hard- und Softwareeinrichtungen sowie das erforderliche Netzwerk und Datenvolumen für die Nutzung der Webseite, der App und der Kurse bereitzustellen. 9.2 Der Nutzer hat die Kurse und Hinweise anleitungsgemäß auszuführen. 9.3 Falls der Nutzer Coachings oder Hinweise nicht eindeutig versteht, kann er vor der Ausführung der Kurse oder des Hinweises den Anbieter kontaktieren, um etwaige Fragen und Unklarheiten zu klären. 9.4 Der Nutzer wird erneut ausdrücklich darauf hingewiesen, die Gesundheitshinweise in Abschnitt 2 dieser Bestimmungen zu beachten. Die Nichtbeachtung der Gesundheitshinweise kann zu Verletzungs- und Gesundheitsrisiken führen. Dies betrifft insbesondere Nutzer mit Vorerkrankungen, Schwangere sowie Nutzer, die unter Nahrungsmittelunverträglichkeiten oder Allergien leiden. 9.5 Der Nutzer ist verpflichtet, seine Zugangsdaten, insbesondere das gewählte Passwort, geheim zu halten und Maßnahmen zu ergreifen, um den Zugang durch Dritte zu verhindern. Der Nutzer muss den Anbieter unverzüglich informieren, wenn Anhaltspunkte dafür bestehen, dass die Zugangsdaten unberechtigt verwendet werden können. Der Nutzer haftet für jeglichen Missbrauch.

AGB BackQuest 6

10. Urheberrechtsschutz 10.1 Die Inhalte der Kurse und Wissenstexte, wie Videos, Audiodateien, Bilder, Texte und Software, sind urheberrechtlich geschützt. Ihre Nutzung unterliegt den geltenden Urheberrechten. Die Nutzungs- und Verwertungsrechte an den Kursinhalte und Wissenstexte liegen ausschließlich beim Anbieter im Verhältnis zum Nutzer. 10.2 Eine Speicherung oder Archivierung der bereitgestellten Inhalte außerhalb der Website oder der App ist nicht gestattet. 10.3 Eine Weitergabe oder das Anbieten der Kursinhalte an Dritte ist ebenfalls nicht gestattet. 10.4 Eine gewerbliche Vervielfältigung der urheberrechtlich geschützten Inhalte oder eine gewerbliche Weitergabe an Dritte ist unzulässig und wird rechtlich verfolgt. 10.5 Es ist dem Nutzer untersagt, Urheberrechtsvermerke, Markenzeichen und andere Rechtsvorbehalte aus heruntergeladenen Inhalten zu entfernen.
11. Verfügbarkeit 11.1 Das digitale Leistungsangebot des Anbieters steht in der Regel 24 Stunden am Tag an sieben Tagen in der Woche zur Verfügung. Ausgenommen davon sind Zeiten, in denen Datensicherungsarbeiten oder Systemwartungs- und Programmpflegearbeiten am System oder der Datenbank durchgeführt werden. Der Anbieter wird bestrebt sein, daraus resultierende Störungen so gering wie möglich zu halten. 11.2 Der Anbieter hat keinen Einfluss auf Störungen, die sich aus Umständen ergeben, die nicht von ihm zu vertreten sind, insbesondere aufgrund von höherer Gewalt. Über geplante Einschränkungen der Verfügbarkeit des Leistungsangebots wird der Nutzer rechtzeitig per E-Mail informiert.
12. Haftung 12.1 Der körperliche Zustand jedes Nutzers ist unterschiedlich, und die Gesundheit hängt von vielen individuellen Faktoren ab. Der Erfolg der Kurse hängt ebenfalls von zahlreichen Einflussfaktoren ab, auf die der Anbieter keinen Einfluss hat. Daher kann keine Gewähr für den Erfolg eines Coachings übernommen werden. 12.2 Der Anbieter übernimmt keine Haftung oder Garantie für die Funktionsweise und Verfügbarkeit der Kursinhalte. Eine Haftung ist insbesondere dann ausgeschlossen, wenn der Nutzer falsche oder unvollständige Angaben gemacht hat.

AGB BackQuest 7

12.3 Der Anbieter haftet nicht für gesundheitliche Schäden, die dem Nutzer aufgrund unsachgemäßer Ausführung der Kursinhalte und/oder aufgrund erkannter oder unerkannter Vorerkrankungen entstehen. 12.4 Der Anbieter haftet nicht für Schäden, die dem Nutzer durch Nichtverfügbarkeit oder technische Störungen des Dienstes entstehen. Eine mögliche Minderung der gezahlten Mitgliedsgebühr bleibt davon unberührt. 12.5 Der Anbieter schließt jegliche Haftung für fahrlässige Pflichtverletzungen aus, sofern es sich nicht um Schäden handelt, die aus der Verletzung des Lebens, des Körpers oder der Gesundheit resultieren oder um Garantien handelt. 12.6 Der Anbieter übernimmt keine Haftung für externe Links und digitale Inhalte von Dritten, sofern sie sich diese Inhalte nicht zu eigen macht. Bei Setzen eines externen Links wird der Inhalt geprüft. Es erfolgt jedoch keine fortlaufende Überwachung der fremden Informationen. Sobald die BackQuest GbR Kenntnis von rechtswidrigen Inhalten oder rechtswidrigen Tätigkeiten in externen Links erhält, wird der jeweilige Link, der auf diese Inhalte verweist, unverzüglich entfernt. 12.7 Eine Haftung gemäß dem Produkthaftungsgesetz bleibt unberührt.
13. Nutzerdaten und Geheimhaltung 13.1 Der Nutzer wird darauf hingewiesen, dass der Anbieter personenbezogene Bestands- und Nutzungsdaten im Rahmen des Vertragsverhältnisses in maschinenlesbarer Form erhebt, verarbeitet und nutzt. Alle personenbezogenen Daten werden vertraulich behandelt. Weitere Informationen finden sich in unser Datenschutzerklärung. 13.2 Die Vertragsparteien verpflichten sich, vertrauliche Informationen, die ihnen im Rahmen der Vertragsdurchführung bekannt werden, vertraulich zu behandeln.
14. Änderungen dieser AGB 14.1 Der Anbieter behält sich das Recht vor, diese Allgemeinen Geschäftsbedingungen jederzeit mit sofortiger Wirkung für die Zukunft zu ändern. 14.2 Eine beabsichtigte Änderung wird dem Nutzer per E-Mail an die zuletzt vom Nutzer angegebene E-Mail-Adresse mitgeteilt. Die Änderung wird wirksam, wenn der Nutzer ihr nicht innerhalb von zwei Wochen nach Absenden der E-Mail widerspricht. Für die Einhaltung der Zwei-Wochen-Frist ist das rechtzeitige Absenden des Widerspruchs maßgebend. 14.3 Wenn der Nutzer innerhalb der Zwei-Wochen-Frist der Änderung widerspricht, ist der Anbieter berechtigt, das Vertragsverhältnis fristlos zu beenden.

AGB BackQuest 8

15. Schlussbestimmungen 15.1 Leistungsort ist Frankfurt (Deutschland). Der Vertrag unterliegt deutschem Recht. 15.2 Sollten einzelne Bestimmungen dieser AGB einschließlich dieser Bestimmung ganz oder teilweise unwirksam sein oder werden, bleibt die Wirksamkeit der übrigen Regelungen hiervon unberührt. Anstelle der unwirksamen oder fehlenden Bestimmungen treten die jeweiligen gesetzlichen Regelungen. (Stand: 06.02.2024)
---

sktg-marketing
Timo Geiling  
Niederwöllstädter Str. 14  
61184 Karben  
Kontakt: timo.geiling@outlook.com
            ''',
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
        title: Text('Datenschutzerklärung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Datenschutzerklärung 

BackQuest 1

Datenschutzerklärung für die Nutzung der BackQuest App Mit der vorliegenden Datenschutzerklärung der BackQuest GbR möchten wir Sie als Anwender unserer BackQuest App umfassend über informieren, wie wir personenbezogene Daten verarbeiten. Der Schutz Ihrer Privatsphäre ist für uns von höchster Bedeutung, weshalb das Einhalten der gesetzlichen Vorschriften zum Datenschutz für uns selbstverständlich ist. Diese Datenschutzerklärung gilt nicht für die Datenverarbeitung auf unser Website. Die dafür vorgesehene Datenschutzerklärung finden Sie jederzeit einsehbar unter: https://backquest.online/privacy-policy/
Kontaktdaten des Verantwortlichen Wenn Sie Fragen oder Anregungen zu diesen Informationen hast oder sich wegen der Geltendmachung deiner Rechte an uns wenden möchtest, richte Dich gerne an BackQuest GbR Gärtnerweg 62 60322 Frankfurt, Deutschland
Datenschutzbeauftragter Bei Fragen zu unseren Datenschutzmaßnahmen oder der Verarbeitung Ihrer Daten erreichen Sie unseren Datenschutzbeauftragten unter: datenschutz@backquest.online
Verarbeitung personenbezogene Daten Personenbezogene Daten sind alle Informationen über eine bestimmte oder bestimmbare Person. Mit Nutzung der BackQuest App werden folgende personenbezogene Daten verarbeitet:
• E-Mail-Adresse/ Benutzername
• Geschlecht und Alter
• Größe und Gewicht
• Aktivitätslevel
• Sportliche Vorerfahrung und sportliche Ziele
• Trainingsdaten (Absolvierte Übungen, Feedback zu Übungen) Nach Zustimmung werden während der Appnutzung werden zudem von verschiedene Aspekte anonymisierte Nutzungsdaten erhoben. Die nachfolgende Analyse der Nutzungsdaten erfolgt ausschließlich in anonymisierter Form.

Datenschutzerklärung BackQuest 2

Zweck der Verarbeitung Wir verarbeiten Ihre personenbezogenen Daten grundsätzlich nur, soweit dies für die Durchführung des Präventionstrainings notwendig ist. Alle erhobenen Daten dienen dazu (1) unseren Nutzern ein möglichst gutes Trainingserlebnis zu ermöglichen, (2) auf Ihre Bedürfnisse eingehen zu können und (3) die dauerhafte technische Funktionsfähigkeit zu gewährleisten.
Rechtsgrundlagen der Datenverarbeitung Wir verarbeiten personenbezogene Daten nur unter Beachtung der Datenschutzverordnungen (DSGVO und BDSG). Die Datenverarbeitung findet nur nach ausdrücklicher Erlaubnis (§ 25 Abs. 1 TTDSG oder Art. 6 Abs. 1 Buchst. a DSGVO) statt. Die Verarbeitung der Daten dient der Erfüllung vertraglicher Maßnahmen (Art. 6 Abs. 1 Buchst. b DSGVO), einer rechtlichen Verpflichtung (Art. 6 Abs. 1 Buchst. c DSGVO) oder in Verbindung der jeweiligen spezialgesetzlichen Vorschrift (Art. 6 Abs. 1 Buchst. d, e oder f DSGVO).
Speicherdauer und Löschung von Daten Sofern es sich nicht den anderen Inhalten dieser Datenschutzerklärung ergibt, speichern wir ihre Daten nur so lange wie nötig. Wir löschen Ihre personenbezogenen Daten, sobald sie nicht mehr für den jeweiligen Zweck benötigt werden, es sei denn, es bestehen gesetzliche Aufbewahrungspflichten. Die endgültige Löschung erfolgt nach Ablauf der entsprechenden Aufbewahrungsfristen. Wenn Sie möchten, dass wir Ihre Daten löschen, können Sie uns jederzeit eine E-Mail an datenschutz@backquest.online senden.

Datenschutzerklärung BackQuest 3

Datenempfänger Personenbezogene Daten, die im Zusammenhang mit der Nutzung der BackQuest App verarbeitet werden, werden grundsätzlich nicht an Dritte weitergegeben, es sei denn, dies ist für den bestimmten Zweck erforderlich. Wir gewährleisten angemessene Sicherheitsmaßnahmen, um unbefugten Zugriff, Weitergabe, Veränderung oder Vernichtung der Daten zu verhindern. Bei der Verarbeitung deiner Daten arbeiten wir mit den folgenden Dienstleistern zusammen, die Zugriff auf deine Daten haben. OVH Cloud Wir speichern und verarbeiten Ihre personenbezogenen Daten mit Gesundheitsbezug ausschließlich mithilfe des Cloud-Dienstes bzw. der Cloud Infrastruktur von OVH (OVH SAS-Gruppe, 2, Rue Kellermann, 59100 Roubaix, Frankreich; nachfolgend: „OVH”), zur Bereitstellung von IT-Leistungen und zur sicheren Speicherung bzw. zum sicheren Austausch digitaler Inhalte und Informationen. Dabei werden alle Daten ausschließlich in Deutschland verarbeitet. Weitergehende Informationen von OVH zum Thema Datenschutz finden Sie unter: https://www.ovhcloud.com/de/personal-data-protection/ Google Firebase Wir nutzen Google Firebase (ein Dienst der Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Irland), um beispielsweise Push Notifications zu senden. Ein Tracking über Firebase erfolgt dabei nicht. Ebenfalls werden Weitere Informationen finden Sie unter: https://firebase.google.com/support/privacy?hl=de
Datenverarbeitung zur Verbesserung der Nutzerfreundlichkeit BackQuest veranstaltet regelmäßig Erhebungen zur Nutzungszufriedenheit. Falls Sie dazu eingewilligt haben, erhalten Sie im Rahmen dessen Einladungen zu Fragebögen, Einzel- sowie Gruppeninterviews. Hier können Sie uns freiwillig von ihren Erfahrungen mit Nutzung der App berichten und an der Weiterentwicklung der App mitwirken. Im Rahmen der Erhebungen zur Nutzungszufriedenheit arbeiten wir mit folgenden Dienstleistern zusammen: Strato Webmail Wir nutzen Strato Webmail, (ein Dienst der STRATO AG (Otto-Ostrowski-Straße 7, 10249 Berlin) als E-Mail-Hosting Provider zur Kommunikation. Im Zuge der Nutzung werden Kontaktdaten (wie z.B. E-Mail-Adresse), Online Identifier (wie z.B. die IP Adresse) und die Inhalte der Nachricht vom Dienstleister verarbeitet. Weitere Informationen finden Sie unter: https://www.strato.de/datenschutz/

Datenschutzerklärung BackQuest 4

Condens Wir nutzen Condens des Anbieters Condens Insights GmbH (Brienner Str. 41, 80333 München) zur Analyse von Daten rund um die Nutzerfreundlichkeit. Mit Ihrer Zustimmung werden Ihre Erfahrungen mit der Appnutzung und ihre Hinweise zur Weiterentwicklung unserer App in anonymisierter Form verarbeitet, strukturiert und visualisiert. Diese werden jedoch lediglich mit allgemeinen Informationen zu demografischen Profilen in Verbindung gebracht. Weitere Informationen zum Anbieter findest du unter: https://condens.io/gdpr/ Brevo (ehemals SendinBlue) Wir verwenden den Dienst Brevo (ehemals Sendinblue) des Anbieters Sendinblue GmbH (Köpenicker Straße 127, 10179 Berlin, Deutschland) um unseren Newsletter zu versenden sowie beispielsweise die Öffnungs- und Klickraten zu messen. Sofern Sie Zustimmen an unseren Nutzerbefragungen teilzunehmen, leiten wir insbesondere Ihre E-Mailadresse an Brevo weiter. Außerdem werden die Termine sowie die Online-Meetings der Nutzerbefragungen über die Meeting Funktion des Anbieters abgewickelt. Weitere Informationen zum Anbieter findest du unter: https://www.brevo.com/de/datenschutz-uebersicht/
Ihre Rechte Als betroffene Person haben Sie verschiedene Rechte in Bezug auf Ihre personenbezogenen Daten. Sie haben das Recht, Auskunft über die Sie betreffenden Daten zu erhalten (Art. 15 DSGVO und § 34 BDSG) und können sich jederzeit an uns wenden, um dieses Recht nach (Art. 16 DSGVO) auszuüben. Wenn Sie eine Auskunftsanfrage stellen, die nicht schriftlich erfolgt, können wir Nachweise verlangen, um sicherzustellen, dass es sich bei Ihnen um die betreffende Person handelt. Des Weiteren haben Sie das Recht auf Berichtigung oder Löschung Ihrer Daten (Art. 17 DSGVO und § 35 BDSG) sowie auf Einschränkung der Verarbeitung (Art. 18 DSGVO), soweit dies gesetzlich zulässig ist. Sie haben das Recht, der Verarbeitung Ihrer personenbezogenen Daten unter den gesetzlichen Voraussetzungen zu widersprechen. Sie können Ihre einmal erteilte Einwilligung in die Verarbeitung Ihrer Daten jederzeit widerrufen (Art. 7 Abs. 3 DSGVO). Darüber hinaus haben Sie nach Art. 20 DSGVO das Recht auf Datenübertragbarkeit gemäß den datenschutzrechtlichen Bestimmungen.

Datenschutzerklärung BackQuest 5

Beschwerderecht bei einer Aufsichtsbehörde Falls Sie Bedenken oder Beschwerden bezüglich der Verarbeitung Ihrer personenbezogenen Daten haben, können Sie sich nach Maßgabe des Art. 77 DSGVO an eine Aufsichtsbehörde für den Datenschutz wenden.
Änderung dieser Datenschutzhinweise Diese Datenschutzhinweise können bei Änderungen der Datenverarbeitung oder anderen Anlässen aktualisiert werden. Die aktuelle Fassung finden Sie jederzeit auf unserer Website. Wir hoffen, dass diese Informationen Ihnen ein besseres Verständnis darüber vermitteln, wie wir Ihre Daten schützen und nutzen. Bei Fragen stehen wir Ihnen jederzeit zur Verfügung. Stand: 20.02.2024
            ''',
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
        title: Text('Impressum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Impressum

Anbieter:

sktg-marketing  
Timo Geiling  
Niederwöllstädter Str. 14  
61184 Karben  

Kontakt:

Telefon: 0176 32141106  
E-Mail: timo.geiling@outlook.com

Umsatzsteuer:

Umsatzsteuer-Identifikationsnummer gemäß §27 a Umsatzsteuergesetz: DE368663332

Steuernummer:

1682063158
            ''',
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
      // Handle the case where the email client can't be launched
      print('Could not launch email client');
    }
  }

  void _launchAppleSubscription() async {
    if (await canLaunch(appleSubscriptionUrl)) {
      await launch(appleSubscriptionUrl);
    } else {
      // Handle the case where the URL can't be launched
      print('Could not launch Apple subscription URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontakt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kontakt',
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
              'Abonnement ändern:',
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
                'Apple Subscription Management',
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
