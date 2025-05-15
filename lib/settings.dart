import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'auth.dart';
import 'provider.dart';
import 'services.dart'; // Import the services.dart for API calls
import 'payment_service.dart'; // Import the payment service
import 'video.dart';
import 'offline.dart'; // Import the offline page
import 'downloadmanager.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) setAuthenticated;
  final Function isAuthenticated;

  const SettingsPage({
    Key? key,
    required this.setAuthenticated,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    bool payedUp = profileProvider.payedSubscription == true;

    // Create a list to hold all the settings tiles
    List<Widget> settingsTiles = [
      SettingsTile(
        title: AppLocalizations.of(context)!.adjustGoals,
        icon: Icons.bar_chart,
      ),
      SettingsTile(
        title: AppLocalizations.of(context)!.adjustPainAreas,
        icon: Icons.sports_tennis,
      ),
      SettingsTile(
        title: AppLocalizations.of(context)!.adjustFitnessLevel,
        icon: Icons.bolt,
      ),
      SettingsTile(
        title: AppLocalizations.of(context)!.termsConditions,
        icon: Icons.article,
      ),
      SettingsTile(
        title: AppLocalizations.of(context)!.privacyPolicy,
        icon: Icons.privacy_tip,
      ),
      SettingsTile(
        title: AppLocalizations.of(context)!.impressum,
        icon: Icons.info_outline,
      ),
    ];

    // Conditionally add login or logout based on authentication status
    if (isAuthenticated()) {
      settingsTiles.add(
        SettingsTile(
          title: AppLocalizations.of(context)!.logout,
          icon: Icons.logout,
          onTileTap: setAuthenticated,
        ),
      );

      // Only show delete account option for authenticated users
      settingsTiles.add(
        SettingsTile(
          title: "Delete Account",
          icon: Icons.delete_forever,
          onTileTap: setAuthenticated,
        ),
      );
    } else {
      settingsTiles.add(
        LoginTile(
          title: AppLocalizations.of(context)!.login,
          icon: Icons.login,
          setAuthenticated: setAuthenticated,
        ),
      );
    }

    // Add subscription tile
    settingsTiles.add(
      SettingsTile(
        title:
            payedUp
                ? AppLocalizations.of(context)!.mySubscription
                : AppLocalizations.of(context)!.subscribeBackQuest,
        icon: Icons.payments_sharp,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/settingsbg.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView(
            children:
                ListTile.divideTiles(
                  context: context,
                  tiles: settingsTiles,
                ).toList(),
          ),
        ],
      ),
    );
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
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        if (title == AppLocalizations.of(context)!.adjustGoals) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GoalSettingPage(
                    initialWeeklyGoal: profileProvider.weeklyGoalTarget,
                  ),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.adjustPainAreas) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PainSettingPage(
                    initialSelectedPainAreas: profileProvider.painAreas,
                  ),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.adjustFitnessLevel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FitnessSettingPage(
                    initialFitnessLevel: profileProvider.fitnessLevel,
                  ),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.termsConditions) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AGB()),
          );
        } else if (title == AppLocalizations.of(context)!.privacyPolicy) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Datasecurity()),
          );
        } else if (title == AppLocalizations.of(context)!.impressum) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Impressum()),
          );
        } else if (title == AppLocalizations.of(context)!.logout) {
          // Using the services.dart logout functionality
          AuthService().logout();
          onTileTap?.call(false);
          Navigator.pop(context);
        } else if (title == "Delete Account") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DeleteAccountPage(
                    setAuthenticated: onTileTap ?? ((_) {}),
                  ),
            ),
          );
        } else if (title == AppLocalizations.of(context)!.mySubscription ||
            title == AppLocalizations.of(context)!.subscribeBackQuest) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionSettingPage(),
            ),
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

  const LoginTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.setAuthenticated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => LoginScreen(setAuthenticated: setAuthenticated),
          ),
        );
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

  const GoalSettingPage({Key? key, this.initialWeeklyGoal = 3})
    : super(key: key);

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
        color:
            isGoalSelected(goal)
                ? const Color(0xFF59c977)
                : Colors.grey.withOpacity(
                  0.3,
                ), // Background color based on selection
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:
                isGoalSelected(goal)
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
            color:
                isGoalSelected(goal)
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
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

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
            child: const Icon(Icons.check, color: Colors.white, size: 24),
            onPressed: () {
              profileProvider.setWeeklyGoalTarget(weeklyGoal);
              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    weeklyGoalTarget: weeklyGoal,
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
      ],
    );
  }
}

class FitnessSettingPage extends StatefulWidget {
  final int initialFitnessLevel;

  const FitnessSettingPage({Key? key, this.initialFitnessLevel = 0})
    : super(key: key);

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
          color:
              isGoalSelected(index)
                  ? const Color(0xFF59c977)
                  : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color:
                  isGoalSelected(index)
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

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

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
            iconTheme: const IconThemeData(color: Colors.white),
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
              ...List.generate(options2.length, (index) => goalTile(index)),
            ],
          ),
          floatingActionButton: PressableButton(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
            onPressed: () {
              profileProvider.setFitnessLevel(fitnessLevel);
              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(token: token, fitnessLevel: fitnessLevel).then((
                    success,
                  ) {
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
      ],
    );
  }
}

class PainSettingPage extends StatefulWidget {
  final Map<String, int> initialSelectedPainAreas;

  const PainSettingPage({Key? key, required this.initialSelectedPainAreas})
    : super(key: key);

  @override
  _PainSettingPageState createState() => _PainSettingPageState();
}

class _PainSettingPageState extends State<PainSettingPage> {
  late Map<String, bool> painAreas;

  @override
  void initState() {
    super.initState();
    painAreas = {};

    // Initialize all pain areas as false
    final Map<String, String> allPainAreasMap = {
      "lower_back": "Lower Back",
      "upper_back": "Upper Back",
      "neck": "Neck",
      "knee": "Knee",
      "wrists": "Wrists",
      "feet": "Feet",
      "ankle": "Ankle",
      "hip": "Hip",
      "jaw": "Jaw",
      "shoulder": "Shoulder",
    };

    // Set all pain areas to false initially
    for (var key in allPainAreasMap.keys) {
      painAreas[key] = false;
    }

    // Set the initial state for the pain areas that are selected
    for (var entry in widget.initialSelectedPainAreas.entries) {
      painAreas[entry.key] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> allPainAreas = {
      "lower_back": AppLocalizations.of(context)!.lowerBack,
      "upper_back": AppLocalizations.of(context)!.upperBack,
      "neck": AppLocalizations.of(context)!.neck,
      "knee": AppLocalizations.of(context)!.knee,
      "wrists": AppLocalizations.of(context)!.wrists,
      "feet": AppLocalizations.of(context)!.feet,
      "ankle": AppLocalizations.of(context)!.ankle,
      "hip": AppLocalizations.of(context)!.hip,
      "jaw": AppLocalizations.of(context)!.jaw,
      "shoulder": AppLocalizations.of(context)!.shoulder,
    };

    Widget painAreaTile(String areaKey) {
      return CheckboxListTile(
        title: Text(
          allPainAreas[areaKey]!,
          style: const TextStyle(color: Colors.white),
        ),
        side: const BorderSide(width: 1.0, color: Colors.white),
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

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

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
            child: const Icon(Icons.check, color: Colors.white, size: 24),
            onPressed: () {
              // Convert selected areas to a Map<String, int> with pain level 5 as default
              Map<String, int> selectedPainAreas = {};
              for (var entry in painAreas.entries) {
                if (entry.value) {
                  // If the area is already in the profile's painAreas, keep the pain level
                  // Otherwise, set a default pain level of 5
                  selectedPainAreas[entry.key] =
                      profileProvider.painAreas[entry.key] ?? 5;
                }
              }

              // Update pain areas in the provider
              for (var area in selectedPainAreas.entries) {
                profileProvider.updatePainArea(area.key, area.value);
              }

              // Remove pain areas that are no longer selected
              List<String> areasToRemove = [];
              for (var area in profileProvider.painAreas.keys) {
                if (!selectedPainAreas.containsKey(area)) {
                  areasToRemove.add(area);
                }
              }

              for (var area in areasToRemove) {
                profileProvider.removePainArea(area);
              }

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    painAreas: selectedPainAreas,
                  ).then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.profileUpdateSuccess,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.profileUpdateError,
                          ),
                        ),
                      );
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.authTokenUnavailable,
                      ),
                    ),
                  );
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

// We need a placeholder for this since it's mentioned in the code
class PressableButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsets padding;

  const PressableButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 8,
        intensity: 0.65,
        color: const Color(0xFF59c977),
      ),
      padding: padding,
      child: child,
      onPressed: onPressed,
    );
  }
}

// Placeholder classes for screens referenced in the code
class AGB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.termsConditions),
      ),
      body: Center(child: Text("Terms and Conditions")),
    );
  }
}

class Datasecurity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.privacyPolicy)),
      body: Center(child: Text("Privacy Policy")),
    );
  }
}

class Impressum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.impressum)),
      body: Center(child: Text("Impressum")),
    );
  }
}

class Kontakt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.contact)),
      body: Center(child: Text("Contact Information")),
    );
  }
}

class DeleteAccountPage extends StatelessWidget {
  final Function(bool) setAuthenticated;

  const DeleteAccountPage({Key? key, required this.setAuthenticated})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delete Account")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Are you sure you want to delete your account?"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Call API to delete account
                    getAuthToken().then((token) {
                      if (token != null) {
                        // Call deleteAccount API when implemented
                        // For now, just logout
                        AuthService().logout();
                        setAuthenticated(false);
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    });
                  },
                  child: Text("Delete"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionSettingPage extends StatelessWidget {
  const SubscriptionSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final bool isPaid = profileProvider.payedSubscription == true;
    final String? subType = profileProvider.subType;
    final String? subStarted = profileProvider.subStarted;

    // Get screen size for responsive layouts
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 380;

    return Stack(
      children: <Widget>[
        // Background image with responsive fit
        SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: Image.asset("assets/settingsbg.PNG", fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppLocalizations.of(context)!.mySubscription,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          constraints.maxWidth * 0.05, // Responsive padding
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subscription status card
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              isPaid
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Active Subscription',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Type: ${subType ?? "Premium"}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (subStarted != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Started: $subStarted',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Your premium features are currently active.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  )
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'No Active Subscription',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Upgrade to premium to unlock all features!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                        ),

                        SizedBox(
                          height: constraints.maxHeight * 0.04,
                        ), // Responsive spacing
                        // Subscription options (placeholder for now)
                        if (!isPaid) ...[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Available Plans',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),

                          // Monthly subscription option
                          _buildResponsiveSubscriptionTile(
                            context,
                            title: 'Monthly',
                            description: 'Full access to all premium features',
                            price: '€9.99/month',
                            onTap: () {
                              // Create payment service and start purchase
                              final paymentService = PaymentService(
                                profileProvider: profileProvider,
                              );

                              // Just start the purchase process - don't show success yet or pop the screen
                              paymentService.purchaseSubscription(
                                PaymentService.monthlySubscriptionId,
                                context,
                              );
                              // The purchase result will be handled by the purchase stream listener
                            },
                          ),

                          SizedBox(height: constraints.maxHeight * 0.02),

                          // Annual subscription option
                          _buildResponsiveSubscriptionTile(
                            context,
                            title: 'Annual (Best Value)',
                            description: 'Full access to all premium features',
                            price: '€69.99/year',
                            isBestValue: true,
                            onTap: () {
                              // Create payment service and start purchase
                              final paymentService = PaymentService(
                                profileProvider: profileProvider,
                              );

                              // Just start the purchase process - don't show success yet or pop the screen
                              paymentService.purchaseSubscription(
                                PaymentService.yearlySubscriptionId,
                                context,
                              );
                              // The purchase result will be handled by the purchase stream listener
                            },
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),

                          // Restore purchases button
                          Center(
                            child: TextButton(
                              onPressed: () {
                                final paymentService = PaymentService(
                                  profileProvider: profileProvider,
                                );
                                paymentService.restorePurchases(context);
                              },
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Restore Previous Purchases',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Management options for paid users
                        if (isPaid) ...[
                          SizedBox(height: constraints.maxHeight * 0.04),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade800,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16 : 24,
                                  vertical: isSmallScreen ? 8 : 12,
                                ),
                              ),
                              onPressed: () {
                                // Show a confirmation dialog first
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          'Cancel Subscription?',
                                        ),
                                        content: const Text(
                                          'Are you sure you want to cancel your subscription? You will still have access until the end of your current billing period.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('NO'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                              ); // Close dialog

                                              // Create payment service and cancel
                                              final paymentService =
                                                  PaymentService(
                                                    profileProvider:
                                                        profileProvider,
                                                  );
                                              paymentService
                                                  .cancelSubscription(context)
                                                  .then((success) {
                                                    if (success) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Subscription canceled successfully',
                                                          ),
                                                        ),
                                                      );
                                                      // Force refresh the UI
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('YES, CANCEL'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Cancel Subscription'),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build responsive subscription tiles
  Widget _buildResponsiveSubscriptionTile(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    bool isBestValue = false,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 350;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                isBestValue
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border:
                isBestValue
                    ? Border.all(color: Colors.blue.shade400, width: 2)
                    : null,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(isNarrow ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isNarrow ? 16 : 18,
                            ),
                          ),
                        ),
                      ),
                      if (isBestValue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'BEST VALUE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isNarrow ? 13 : 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isNarrow ? 16 : 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isNarrow ? 12 : 16,
                          vertical: isNarrow ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'SUBSCRIBE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SubscriptionOptionTile extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final bool isBestValue;
  final VoidCallback onTap;

  const SubscriptionOptionTile({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    this.isBestValue = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isBestValue
                  ? const Color(0xFF59c977).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              isBestValue
                  ? Border.all(color: const Color(0xFF59c977), width: 2)
                  : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF59c977),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'SAVE 40%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
