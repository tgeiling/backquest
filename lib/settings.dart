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
                SettingsTile(
                    title: payedUp ? "Mein Abonnement" : 'Backquest abonnieren',
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
        } else if (title == 'Backquest abonnieren') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SubscriptionSettingPage()),
          );
        } else if (title == 'Mein Abonnement') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MySubscriptionPage()),
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
                _buildSubscriptionTile(
                  context,
                  "Jährlich",
                  activeSubscription == "Jährlich",
                  subscriptionStartDate,
                ),
                const SizedBox(height: 10),
                _buildSubscriptionTile(
                  context,
                  "Monatlich",
                  activeSubscription == "Monatlich",
                  subscriptionStartDate,
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
      width: 130,
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
        const Set<String> productIds = {'01', '02'};
        final ProductDetailsResponse response =
            await inAppPurchase.queryProductDetails(productIds);

        if (response.error != null) {
          print('Error querying product details: ${response.error}');
        }

        if (response.productDetails.isEmpty) {
          print('No products found. This could be due to the following reasons:');
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
      if (purchaseDetails.productID == '01' || purchaseDetails.productID == '02') {
        final profilProvider =
            Provider.of<ProfilProvider>(context, listen: false);
        profilProvider.setPayedSubscription(true);
        profilProvider.setSubType(purchaseDetails.productID == '01' ? 'Monatlich' : 'Jährlich');
        profilProvider.setSubStarted(DateTime.now());

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
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
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
        product = products.firstWhere((product) => product.id == '02');
      } else {
        product = products.firstWhere((product) => product.id == '01');
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
        title: Text('AGB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Allgemeine Geschäftsbedingungen (AGB)

1. Geltungsbereich
Diese Allgemeinen Geschäftsbedingungen (AGB) gelten für die Nutzung der mobilen Anwendung "Backpain App" (im Folgenden "App") von ktg-marketing, Timo Geiling, Niederwöllstädter Str. 14, 61184 Karben (im Folgenden "Anbieter"). Mit der Registrierung und Nutzung der App akzeptieren Sie diese AGB.

2. Vertragsgegenstand
Die App bietet Inhalte und Funktionen zur Unterstützung bei Rückenschmerzen. Der Zugriff auf bestimmte Inhalte und Funktionen ist kostenpflichtig und erfolgt im Rahmen eines Abonnementmodells.

3. Registrierung und Benutzerkonto
Die Nutzung der App erfordert die Erstellung eines Benutzerkontos. Bei der Registrierung sind die erforderlichen Daten vollständig und wahrheitsgemäß anzugeben. Der Nutzer ist verpflichtet, die Zugangsdaten geheim zu halten und den Anbieter unverzüglich über einen Missbrauch des Kontos zu informieren.

4. Abonnement und In-App-Käufe
Bestimmte Inhalte und Funktionen der App sind kostenpflichtig und können im Rahmen eines Abonnements oder durch In-App-Käufe freigeschaltet werden. Die Abrechnung erfolgt über den jeweiligen App Store (Apple App Store oder Google Play Store). Die Preise und Abonnementbedingungen sind in der App angegeben. Das Abonnement verlängert sich automatisch, es sei denn, es wird mindestens 24 Stunden vor Ablauf der aktuellen Periode gekündigt.

5. Widerrufsrecht
Nutzer haben das Recht, den Vertrag innerhalb von 14 Tagen ohne Angabe von Gründen zu widerrufen. Um das Widerrufsrecht auszuüben, muss der Nutzer den Anbieter über die Kontaktinformationen in der Impressum-Seite der App informieren. Bei digitalen Inhalten erlischt das Widerrufsrecht, wenn der Nutzer dem Beginn der Ausführung zugestimmt hat.

6. Haftung
Der Anbieter haftet nur für Schäden, die durch Vorsatz oder grobe Fahrlässigkeit verursacht wurden. Für leichte Fahrlässigkeit haftet der Anbieter nur bei der Verletzung wesentlicher Vertragspflichten (Kardinalpflichten). Die Haftung ist auf den vorhersehbaren, typischerweise eintretenden Schaden begrenzt.

7. Datenschutz
Die Erhebung und Verarbeitung personenbezogener Daten erfolgt gemäß der Datenschutzerklärung, die in der App verfügbar ist.

8. Änderungen der AGB
Der Anbieter behält sich das Recht vor, diese AGB jederzeit zu ändern. Die Nutzer werden rechtzeitig über Änderungen informiert. Die weitere Nutzung der App nach Änderung der AGB gilt als Zustimmung.

9. Schlussbestimmungen
Sollte eine Bestimmung dieser AGB unwirksam sein, bleiben die übrigen Bestimmungen davon unberührt. Es gilt das Recht der Bundesrepublik Deutschland. Gerichtsstand ist Karben, sofern der Nutzer Kaufmann ist.

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

1. Verantwortlicher
Verantwortlicher für die Datenverarbeitung im Zusammenhang mit der Nutzung der App "Backpain App" ist:

sktg-marketing  
Timo Geiling  
Niederwöllstädter Str. 14  
61184 Karben  
E-Mail: timo.geiling@outlook.com

2. Erhebung und Verarbeitung personenbezogener Daten
Wir erheben und verarbeiten personenbezogene Daten, wenn Sie die App nutzen, insbesondere bei der Registrierung, bei der Nutzung von In-App-Käufen, und bei der Kommunikation mit uns. Zu den verarbeiteten Daten gehören:

- Vorname und Nachname
- E-Mail-Adresse
- Zahlungsinformationen (über den App Store)
- Nutzungsdaten (z. B. Login-Daten, App-Nutzung)

3. Zweck der Verarbeitung
Die Verarbeitung der Daten erfolgt zu folgenden Zwecken:

- Bereitstellung und Personalisierung der App
- Abwicklung von In-App-Käufen und Abonnements
- Verbesserung der App und Analyse des Nutzerverhaltens
- Kommunikation mit dem Nutzer

4. Rechtsgrundlage
Die Verarbeitung Ihrer Daten erfolgt auf Grundlage Ihrer Einwilligung (Art. 6 Abs. 1 lit. a DSGVO) und zur Erfüllung des Vertrags (Art. 6 Abs. 1 lit. b DSGVO).

5. Weitergabe der Daten
Ihre Daten werden nicht an Dritte weitergegeben, es sei denn, dies ist zur Erfüllung des Vertrags erforderlich (z. B. Zahlungsabwicklung über den App Store), gesetzlich vorgeschrieben, oder Sie haben ausdrücklich zugestimmt.

6. Datenspeicherung
Ihre Daten werden nur so lange gespeichert, wie es für die Erfüllung des Vertrags oder aufgrund gesetzlicher Verpflichtungen erforderlich ist.

7. Rechte der betroffenen Personen
Sie haben das Recht, Auskunft über die von uns gespeicherten personenbezogenen Daten zu erhalten, sowie das Recht auf Berichtigung, Löschung, Einschränkung der Verarbeitung und Datenübertragbarkeit. Zudem können Sie Ihre Einwilligung zur Verarbeitung Ihrer Daten jederzeit widerrufen.

8. Kontakt
Für Fragen zum Datenschutz oder zur Ausübung Ihrer Rechte können Sie uns unter den oben angegebenen Kontaktinformationen erreichen.

9. Änderungen der Datenschutzerklärung
Wir behalten uns das Recht vor, diese Datenschutzerklärung bei Bedarf zu ändern, um sie an geänderte rechtliche Rahmenbedingungen oder neue Funktionen der App anzupassen. Die jeweils aktuelle Version ist in der App verfügbar.

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

