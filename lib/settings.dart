import 'package:backquest/elements.dart';
import 'package:backquest/services.dart';
import 'package:backquest/stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) setAuthenticated;

  const SettingsPage({Key? key, required this.setAuthenticated})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            SettingsTile(title: 'Ziele anpassen', icon: Icons.bar_chart),
            SettingsTile(
                title: 'Schmerzen anpassen', icon: Icons.sports_tennis),
            SettingsTile(title: 'Fitnesslevel anpassen', icon: Icons.bolt),
            SettingsTile(title: 'AGB', icon: Icons.article),
            SettingsTile(
                title: 'Datenschutzerklärung', icon: Icons.privacy_tip),
            SettingsTile(title: 'Impressum', icon: Icons.info_outline),
            SettingsTile(
              title: 'Logout',
              icon: Icons.logout,
              onTileTap: setAuthenticated,
            ),
          ],
        ).toList(),
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
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    final AuthService _authService = AuthService();
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
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
        } else if (title == 'Logout') {
          _authService.logout();
          onTileTap?.call(false);
          Navigator.pop(context);
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
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isGoalSelected(goal)
            ? LinearGradient(
                colors: [
                  Color.fromRGBO(97, 184, 115, 1),
                  Color.fromRGBO(0, 59, 46, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isGoalSelected(goal) ? null : Colors.grey[850],
      ),
      child: ListTile(
        title: Text('$goal Tage',
            style: TextStyle(
                color: isGoalSelected(goal) ? Colors.white : Colors.grey[400])),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Setze deine Ziele'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Wöchentliche Übungen Ziele:',
                style: Theme.of(context).textTheme.headline6),
          ),
          for (int i = 2; i <= 12; i++) goalTile(i),
        ],
      ),
      floatingActionButton: PressableButton(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Icon(
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
    );
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
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isGoalSelected(goal)
            ? LinearGradient(
                colors: [
                  Color.fromRGBO(97, 184, 115, 1),
                  Color.fromRGBO(0, 59, 46, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isGoalSelected(goal) ? null : Colors.grey[850],
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Setze deine Fitnessziele'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Wie oft möchtest du trainieren?',
                style: Theme.of(context).textTheme.headline6),
          ),
          ...options2.map((option) => goalTile(option)).toList(),
        ],
      ),
      floatingActionButton: PressableButton(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Icon(
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
    );
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
    'Linke Schulter': false,
    'Rechte Schulter': false,
    'Linker Arm': false,
    'Rechter Arm': false,
    'Nacken': false,
    'Hüfte': false,
    'Linkes Knie': false,
    'Rechtes Knie': false,
  };

  @override
  void initState() {
    super.initState();
    painAreas = Map<String, bool>.from(allPainAreas);
    // Set the initial state for the pain areas that are selected
    widget.initialSelectedPainAreas.forEach((area) {
      if (painAreas.containsKey(area)) {
        painAreas[area] = true;
      }
    });
  }

  Widget painAreaTile(String area) {
    return CheckboxListTile(
      title: Text(area),
      value: painAreas[area],
      onChanged: (bool? value) {
        setState(() {
          painAreas[area] = value!;
        });
      },
      secondary: Icon(Icons.healing),
      checkColor: Colors.white,
      activeColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Schmerzbereiche festlegen'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Wähle die Bereiche, in denen du Schmerzen hast.',
                style: Theme.of(context).textTheme.headline6),
          ),
          ...allPainAreas.keys.map((key) => painAreaTile(key)).toList(),
        ],
      ),
      floatingActionButton: PressableButton(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Icon(
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Profil erfolgreich aktualisiert.")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Fehler beim Aktualisieren des Profils.")));
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Kein Authentifizierungstoken verfügbar.")));
            }
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
