import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'elements.dart';
import 'settings.dart';

class ProfilProvider extends ChangeNotifier {
  int _completedLevels = 0;
  int _level = 0;
  int _exp = 0;

  // Keeping only weekly variables
  int _weeklyGoal = 0;
  int _weeklyDone = 0;

  // Getters for weekly variables
  int get weeklyGoal => _weeklyGoal;
  int get weeklyDone => _weeklyDone;

  int get completedLevels => _completedLevels;
  int get level => _level;
  int get exp => _exp;

  Future<void> loadInitialData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _completedLevels = prefs.getInt('completedLevels') ?? 0;
    _level = prefs.getInt('level') ?? 0; // Load level from SharedPreferences
    _exp = prefs.getInt('exp') ?? 0; // Load exp from SharedPreferences

    // Load weekly values from SharedPreferences
    _weeklyGoal = prefs.getInt('weeklyGoal') ?? 0;
    _weeklyDone = prefs.getInt('weeklyDone') ?? 0;

    notifyListeners(); // Notify listeners once after loading all values
  }

  void setCompletedLevels(int levels) {
    _completedLevels = levels;
    notifyListeners();
  }

  void setLevel(int newLevel) {
    _level = newLevel;
    notifyListeners();
  }

  void setExp(int newExp) {
    _exp = newExp;
    notifyListeners();
  }

  // Setters for weekly variables
  void setWeeklyGoal(int goal) {
    _weeklyGoal = goal;
    notifyListeners();
  }

  void setWeeklyDone(int done) {
    _weeklyDone = done;
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
                SizedBox(height: 12.0),
                ProgressBarWithPill(initialProgress: 0.5),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Aligns the children at the start and end of the row
                  children: [
                    Text(
                      "Benjamin",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      iconSize: 20.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()),
                        );
                      },
                    )
                  ],
                ),
                SizedBox(height: 10.0),
                Consumer<ProfilProvider>(
                  builder: (context, profilProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Aligns the text to the start of the column
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "${profilProvider.weeklyDone}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 8), // Space between text and image
                            Image.asset('assets/leaf.png',
                                width: 24, height: 24),
                          ],
                        ),
                        SizedBox(
                            height:
                                4), // Space between the row and the text below
                        Text(
                          "Tage diese Woche trainiert",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
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
