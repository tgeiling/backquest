import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:numberpicker/numberpicker.dart';

import 'elements.dart';

class ProfilProvider extends ChangeNotifier {
  int _completedLevels = 0;
  int _level = 0; // Add this line
  int _exp = 0; // Add this line

  int get completedLevels => _completedLevels;
  int get level => _level; // Add this getter
  int get exp => _exp; // Add this getter

  Future<void> loadInitialData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int completedLevels = prefs.getInt('completedLevels') ?? 0;
    setCompletedLevels(
        completedLevels); // Use your existing method to set the initial state
  }

  void setCompletedLevels(int levels) {
    _completedLevels = levels;
    notifyListeners();
  }

  void setLevel(int newLevel) {
    // Add this method
    _level = newLevel;
    notifyListeners();
  }

  void setExp(int newExp) {
    // Add this method
    _exp = newExp;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key})
      : super(
          key: key,
        );

  @override
  ProfilPageState createState() => ProfilPageState();
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilProvider(),
      child: ProfilPage(),
    );
  }
}

class ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 56.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ProfilProvider>(
                  builder: (context, provider, child) {
                    return _buildRowWithImageAndText(
                        context, provider.level, provider.exp);
                  },
                ),
                SizedBox(height: 39.0),
                Text(
                  "Ziele",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Align items to both ends
                  children: [
                    Text(
                      "Monat",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      "2/4", // Your desired text on the right
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                SizedBox(height: 6.0),
                Container(
                  height: 8.0,
                  color: Colors.orange[50],
                  child: LinearProgressIndicator(
                    value: 0.47, // Your progress value
                    backgroundColor: Colors
                        .orange[50], // Background color of the progress bar
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.cyan, // Color of the progress indicator
                    ),
                  ),
                ),
                SizedBox(height: 23.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Align items to both ends
                  children: [
                    Text(
                      "Woche",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      "3/4", // Replace "3/4" with the dynamic progress text you need
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                SizedBox(height: 6.0),
                Container(
                  height: 8.0,
                  color: Colors.orange[50],
                  child: LinearProgressIndicator(
                    value: 0.78, // Your progress value for "Woche"
                    backgroundColor: Colors
                        .orange[50], // Background color of the progress bar
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.cyan, // Color of the progress indicator
                    ),
                  ),
                ),
                SizedBox(height: 39.0),
                Text(
                  "Statistiken",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 14.0),
                Consumer<ProfilProvider>(
                  builder: (context, provider, child) {
                    return _buildRowWithColumns(
                        context, provider.completedLevels);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowWithImageAndText(BuildContext context, int level, int exp) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(left: 30),
            height: 105.0, // Adjust the size as needed
            width: 105.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(
                      0.5), // Adjust the color and opacity as needed
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0,
                      3), // Adjust the x and y offset to change the shadow position
                ),
              ],
              image: DecorationImage(
                image: AssetImage('assets/timo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 11.0, right: 100),
                  child: Text(
                    "Benjamin",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10.0),
                PressableButton(
                  onPressed: () => _showGoalSettingDialog(context),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                  child: Center(
                      child: Text("Ziele",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGoalSettingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => GoalSettingDialog(),
    );
  }

  Widget _buildRowWithColumns(BuildContext context, int completedLevels) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildColumnWithText(
              dynamicText: "${completedLevels}",
              dynamicText1: "Übungen",
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: _buildColumnWithText(
              dynamicText: "17",
              dynamicText1: "Freunde",
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: _buildColumnWithText(
              dynamicText: "435",
              dynamicText1: "Zeit min",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithViews(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 13.0),
      child: Row(
        children: [
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2.0,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2.0,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2.0,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2.0,
              ),
            ),
          ),
          SizedBox(width: 22.0),
          Text(
            "lbl_alle_anzeigen",
            style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnWithText({
    required String dynamicText,
    required String dynamicText1,
  }) {
    return SizedBox(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Color(0xFFf5f2f2), // Background color similar to .button
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Color(0xFFb3b3b3), // Shadow color similar to #b3b3b3
              offset: Offset(0, 5), // Vertical shadow position
              blurRadius: 0, // No blur for a solid shadow
              spreadRadius: 0, // No spread for a clean shadow line
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 5.0),
            Text(
              dynamicText,
              style: TextStyle(fontSize: 20.0, color: Colors.blueGrey[900]),
            ),
            Text(
              dynamicText1,
              style: TextStyle(fontSize: 16.0, color: Colors.lime[900]),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalSettingDialog extends StatefulWidget {
  final int initialWeeklyGoal;
  final int initialMonthlyGoal;

  const GoalSettingDialog({
    Key? key,
    this.initialWeeklyGoal = 3,
    this.initialMonthlyGoal = 12,
  }) : super(key: key);

  @override
  _GoalSettingDialogState createState() => _GoalSettingDialogState();
}

class _GoalSettingDialogState extends State<GoalSettingDialog> {
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
    return AlertDialog(
      title: Text('Setze deine Ziele'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Wöchentliche Übungen Ziele:'),
            NumberPicker(
              value: weeklyGoal,
              minValue: 0,
              maxValue: 20,
              onChanged: (value) => setState(() => weeklyGoal = value),
            ),
            SizedBox(height: 20),
            Text('Monatliche Übungen Ziele:'),
            NumberPicker(
              value: monthlyGoal,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) => setState(() => monthlyGoal = value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Abbrechen'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Speichern'),
          onPressed: () {
            // Optionally, save the goals here or pass them back to the parent widget
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
