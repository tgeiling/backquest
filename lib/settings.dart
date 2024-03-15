import 'package:flutter/material.dart';

import 'elements.dart';
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
            SettingsTile(title: 'Ziele anpassen', icon: Icons.settings),
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
  final Function(bool)? onTileTap; // Optional callback

  const SettingsTile({
    Key? key,
    required this.title,
    required this.icon,
    this.onTileTap, // Include it here and make it optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (title == 'Ziele anpassen') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoalSettingPage()),
          );
        }
        if (title == 'Logout') {
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
                  Color.fromRGBO(97, 184, 115, 1), // Adjust start color here
                  Color.fromRGBO(0, 59, 46, 1), // Adjust end color here
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isGoalSelected(goal)
            ? null
            : Colors.grey[850], // Non-selected tile color
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
          for (int i = 2; i <= 5; i++) goalTile(i),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          // TODO: Implement save functionality
          Navigator.of(context).pop(weeklyGoal);
        },
      ),
    );
  }
}
