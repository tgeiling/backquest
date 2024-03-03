import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'elements.dart';

class SettingsPage extends StatelessWidget {
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
            SettingsTile(title: 'Medizinprodukt', icon: Icons.medical_services),
            SettingsTile(title: 'Hilfe-Center', icon: Icons.help),
            SettingsTile(title: 'Gebrauchsanweisung', icon: Icons.description),
            SettingsTile(title: 'AGB', icon: Icons.article),
            SettingsTile(
                title: 'Datenschutzerklärung', icon: Icons.privacy_tip),
            SettingsTile(title: 'Impressum', icon: Icons.info_outline),
          ],
        ).toList(),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const SettingsTile({Key? key, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (title == 'Ziele anpassen') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoalSettingPage()),
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
  final int initialMonthlyGoal;

  const GoalSettingPage({
    Key? key,
    this.initialWeeklyGoal = 3,
    this.initialMonthlyGoal = 12,
  }) : super(key: key);

  @override
  _GoalSettingPageState createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  late int weeklyGoal;
  late int monthlyGoal;

  @override
  void initState() {
    super.initState();
    weeklyGoal = widget.initialWeeklyGoal;
    monthlyGoal = widget.initialMonthlyGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setze deine Ziele'),
      ),
      body: Center(
        child: Container(
          height: 240,
          child: GreyContainer(
            padding: EdgeInsets.symmetric(horizontal: 16.0), // Optional padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // This will center the column's children vertically
              children: <Widget>[
                Text('Wöchentliche Übungen Ziele:'),
                NumberPicker(
                  value: weeklyGoal,
                  minValue: 0,
                  maxValue: 20,
                  onChanged: (value) => setState(() => weeklyGoal = value),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
