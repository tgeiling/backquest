import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'elements.dart';
import 'settings.dart';
import 'services.dart';

class ProfilProvider extends ChangeNotifier {
  int _completedLevels = 0;
  int _level = 0;
  int _exp = 0;

  int _weeklyGoal = 0;
  int _weeklyDone = 0;

  int get weeklyGoal => _weeklyGoal;
  int get weeklyDone => _weeklyDone;

  int get completedLevels => _completedLevels;
  int get level => _level;
  int get exp => _exp;

  DateTime? _birthdate;
  String? _gender;
  int? _weight;
  int? _height;
  String? _workplaceEnvironment;
  String? _fitnessLevel;
  String? _goal;
  String? _expectation;
  List<String> _hasPain = [];

  DateTime? get birthdate => _birthdate;
  String? get gender => _gender;
  int? get weight => _weight;
  int? get height => _height;
  String? get workplaceEnvironment => _workplaceEnvironment;
  String? get fitnessLevel => _fitnessLevel;
  String? get goal => _goal;
  String? get expectation => _expectation;
  List<String> get hasPain => _hasPain;

  Future<void> loadInitialData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _completedLevels = prefs.getInt('completedLevels') ?? 0;
    _level = prefs.getInt('level') ?? 0;
    _exp = prefs.getInt('exp') ?? 0;

    _weeklyGoal = prefs.getInt('weeklyGoal') ?? 0;
    _weeklyDone = prefs.getInt('weeklyDone') ?? 0;

    _birthdate = DateTime.tryParse(prefs.getString('birthdate') ?? '');
    _gender = prefs.getString('gender');
    _weight = prefs.getInt('weight');
    _height = prefs.getInt('height');
    _workplaceEnvironment = prefs.getString('workplaceEnvironment');
    _fitnessLevel = prefs.getString('fitnessLevel');
    _goal = prefs.getString('goal');
    _expectation = prefs.getString('expectation');
    _hasPain = prefs.getStringList('hasPain') ?? [];

    notifyListeners();
  }

  void setCompletedLevels(int levels) {
    _completedLevels = levels;
    notifyListeners();
  }

  Future<void> setWeeklyDone() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to read the last update date from SharedPreferences
    final lastUpdateString = prefs.getString('lastWeeklyDoneUpdate');
    DateTime? lastUpdate =
        lastUpdateString != null ? DateTime.parse(lastUpdateString) : null;

    final now = DateTime.now();
    final currentWeek = weekNumber(now);
    final lastUpdateWeek =
        lastUpdate != null ? weekNumber(lastUpdate) : currentWeek;

    if (currentWeek != lastUpdateWeek) {
      _weeklyDone = 0;
    } else {
      _weeklyDone += 1; // Increment weeklyDone by one
    }

    // Update SharedPreferences with the new last update date and weeklyDone
    await prefs.setString('lastWeeklyDoneUpdate', now.toIso8601String());
    await prefs.setInt('weeklyDone', _weeklyDone);

    notifyListeners();
  }

  Future<void> setWeeklyGoal(int weeklyGoal) async {
    _weeklyGoal = weeklyGoal;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyGoal', _weeklyGoal);
    notifyListeners();
  }

  Future<void> setBirthdate(DateTime date) async {
    _birthdate = date;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('birthdate', date.toIso8601String());
    notifyListeners();
  }

  Future<void> setGender(String gender) async {
    _gender = gender;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);
    notifyListeners();
  }

  Future<void> setWeight(int weight) async {
    _weight = weight;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weight', weight);
    notifyListeners();
  }

  Future<void> setHeight(int height) async {
    _height = height;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('height', height);
    notifyListeners();
  }

  Future<void> setWorkplaceEnvironment(String environment) async {
    _workplaceEnvironment = environment;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('workplaceEnvironment', environment);
    notifyListeners();
  }

  Future<void> setFitnessLevel(String level) async {
    _fitnessLevel = level;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitnessLevel', level);
    notifyListeners();
  }

  Future<void> setHasPain(List<String> pains) async {
    _hasPain = pains;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('hasPain', pains);
    notifyListeners();
  }

  Future<void> setGoal(String goal) async {
    _goal = goal;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('goal', goal);
    notifyListeners();
  }

  Future<void> setExpectation(String expectation) async {
    _expectation = expectation;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fitnessLevel', expectation);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ProfilPage extends StatefulWidget {
  final Function(bool) setAuthenticated;

  const ProfilPage({
    Key? key,
    required this.setAuthenticated,
  }) : super(key: key);

  @override
  ProfilPageState createState() => ProfilPageState();

  static Widget builder(BuildContext context, Function(bool) setAuth) {
    return ChangeNotifierProvider(
      create: (context) => ProfilProvider(),
      child: ProfilPage(
        setAuthenticated: setAuth,
      ),
    );
  }
}

class ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    /* getAuthToken().then((token) {
      if (token != null) {
        fetchProfile(token).then((profileData) {
          if (profileData != null) {
            print(profileData);
          } else {
            print('Failed to fetch profile');
          }
        });
        print('Token available');
      }
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      width: double.maxFinite,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 56.0,
        ),
        child:
            Consumer<ProfilProvider>(builder: (context, profilProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowWithImageAndText(context),
              SizedBox(height: 39.0),
              Text(
                "Ziele",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 23.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Woche",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "${profilProvider.weeklyDone}/${profilProvider.weeklyGoal}", // Replace "3/4" with the dynamic progress text you need
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              ProgressBarWithPill(
                  initialProgress:
                      profilProvider.weeklyDone / profilProvider.weeklyGoal),
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
          );
        }),
      ),
    ));
  }

  Widget _buildRowWithImageAndText(BuildContext context) {
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
                  color: Colors.white.withOpacity(
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
                      "Profil",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      iconSize: 26.0,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                  setAuthenticated: widget.setAuthenticated)),
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
                              style: TextStyle(fontSize: 44),
                            ),
                            SizedBox(width: 8), // Space between text and image
                            Image.asset('assets/leaf.png',
                                width: 45, height: 45),
                          ],
                        ),
                        SizedBox(
                            height:
                                4), // Space between the row and the text below
                        Text(
                          "Tage diese Woche \n trainiert",
                          style: TextStyle(fontSize: 22),
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
    return Consumer<ProfilProvider>(builder: (context, profilProvider, child) {
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
                dynamicText: "${profilProvider.hasPain.length}",
                dynamicText1: "Schmerzen",
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: _buildColumnWithText(
                dynamicText: "${profilProvider.fitnessLevel}",
                dynamicText1: "Fitnesslevel",
              ),
            ),
          ],
        ),
      );
    });
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
