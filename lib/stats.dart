import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'elements.dart';
import 'settings.dart';
import 'services.dart';
import 'auth.dart';
import 'info.dart';

class ProfilProvider extends ChangeNotifier {
  int _weeklyGoal = 0;
  int _weeklyDone = 0;
  int _weeklyStreak = 0;
  String _lastUpdateString = "";
  String _fitnessLevel = 'Nicht so oft';

  int _completedLevels = 0;
  int _completedLevelsTotal = 0;
  int _level = 0;
  int _exp = 0;

  DateTime? _birthdate;
  String? _gender;
  int? _weight;
  int? _height;
  String? _workplaceEnvironment;

  String? _expectation;
  List<String> _hasPain = [];
  List<String> _goals = [];
  bool? _questionnaireDone;
  bool? _payedSubscription;
  String? _subType;
  DateTime? _subStarted;
  String? _receiptData;
  String? _lastResetDate;
  List<ExerciseFeedback> _feedback = [];

  int get weeklyGoal => _weeklyGoal;
  int get weeklyDone => _weeklyDone;
  int get weeklyStreak => _weeklyStreak;
  String get lastUpdateString => _lastUpdateString;
  String get fitnessLevel => _fitnessLevel;

  int get completedLevels => _completedLevels;
  int get completedLevelsTotal => _completedLevelsTotal;
  int get level => _level;
  int get exp => _exp;

  DateTime? get birthdate => _birthdate;
  String? get gender => _gender;
  int? get weight => _weight;
  int? get height => _height;
  String? get workplaceEnvironment => _workplaceEnvironment;
  String? get expectation => _expectation;
  List<String> get hasPain => _hasPain;
  List<String> get goals => _goals;
  bool? get questionnaireDone => _questionnaireDone;
  bool? get payedSubscription => _payedSubscription;
  String? get subType => _subType;
  DateTime? get subStarted => _subStarted;
  String? get receiptData => _receiptData;
  String? get lastResetDate => _lastResetDate;
  List<ExerciseFeedback> get feedback => _feedback;

  Future<void> loadInitialData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _completedLevels = prefs.getInt('completedLevels') ?? 0;
    _completedLevelsTotal = prefs.getInt('completedLevelsTotal') ?? 0;
    _level = prefs.getInt('level') ?? 0;
    _exp = prefs.getInt('exp') ?? 0;

    _weeklyGoal = prefs.getInt('weeklyGoal') ?? 0;
    _weeklyDone = prefs.getInt('weeklyDone') ?? 0;
    _weeklyStreak = prefs.getInt('weeklyStreak') ?? 0;
    _lastUpdateString = prefs.getString('lastUpdateString') ?? "";

    _birthdate = DateTime.tryParse(prefs.getString('birthdate') ?? '');
    _gender = prefs.getString('gender');
    _weight = prefs.getInt('weight');
    _height = prefs.getInt('height');
    _workplaceEnvironment = prefs.getString('workplaceEnvironment');
    _fitnessLevel = prefs.getString('fitnessLevel') ?? 'Nicht so oft';
    _goals = prefs.getStringList('goals') ?? [];
    _hasPain = prefs.getStringList('hasPain') ?? [];
    _questionnaireDone = prefs.getBool('questionnaireDone');
    _payedSubscription = prefs.getBool('payedSubscription');
    _subType = prefs.getString('subType');
    _subStarted = DateTime.tryParse(prefs.getString('subStarted') ?? '');
    _receiptData = prefs.getString('receiptData');
    _lastResetDate = prefs.getString('lastResetDate');
    String? feedbackJson = prefs.getString('feedback');
    if (feedbackJson != null) {
      List<dynamic> feedbackList = json.decode(feedbackJson);
      _feedback = feedbackList
          .map((feedback) => ExerciseFeedback.fromJson(feedback))
          .toList();
    }

    DateTime? lastUpdate =
        _lastUpdateString != "" ? DateTime.parse(_lastUpdateString) : null;

    print(lastUpdate);
    print(_lastUpdateString);

    final now = DateTime.now();
    final daysSinceLastUpdate =
        lastUpdate != null ? now.difference(lastUpdate).inDays : null;

    final currentWeek = weekNumber(now);
    final lastUpdateWeek = lastUpdate != null ? weekNumber(lastUpdate) : null;

    if (lastUpdateWeek != null && currentWeek != lastUpdateWeek) {
      _weeklyDone = 0;

      getAuthToken().then((token) {
        if (token != null) {
          updateProfile(
            token: token,
            weeklyDone: _weeklyDone,
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
    }

    if (daysSinceLastUpdate != null && daysSinceLastUpdate >= 14) {
      _weeklyStreak = 0;

      getAuthToken().then((token) {
        if (token != null) {
          updateProfile(
            token: token,
            weeklyStreak: _weeklyStreak,
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
    }

    notifyListeners();
  }

  void setCompletedLevels(int levels) {
    _completedLevels = levels;
    notifyListeners();
  }

  Future<void> setCompletedLevelsTotal(int completedLevelsTotal) async {
    _completedLevelsTotal = completedLevelsTotal;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedLevelsTotal', _completedLevelsTotal);
    notifyListeners();
  }

  Future<void> setWeeklyDone([int? number]) async {
    final prefs = await SharedPreferences.getInstance();

    DateTime? lastUpdate =
        _lastUpdateString != "" ? DateTime.parse(_lastUpdateString) : null;

    print(lastUpdate);
    print(_lastUpdateString);

    final now = DateTime.now();
    final currentWeek = weekNumber(now);
    final lastUpdateWeek =
        lastUpdate != null ? weekNumber(lastUpdate) : currentWeek;

    if (number == null) {
      if (lastUpdate == null) {
        _weeklyStreak += 1;
      }
      if (currentWeek != lastUpdateWeek) {
        _weeklyDone += 1;
        _weeklyStreak += 1;
      } else {
        _weeklyDone += 1;
      }

      getAuthToken().then((token) {
        if (token != null) {
          updateProfile(
            token: token,
            lastUpdateString: _lastUpdateString,
            weeklyStreak: _weeklyStreak,
            weeklyDone: _weeklyDone,
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

      setLastUpdateString(now.toIso8601String());
      await prefs.setInt('weeklyDone', _weeklyDone);
      await prefs.setInt('weeklyStreak', _weeklyStreak);
    } else {
      await prefs.setInt('weeklyDone', number);
    }
    notifyListeners();
  }

  Future<void> setWeeklyGoal(int weeklyGoal) async {
    _weeklyGoal = weeklyGoal;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyGoal', _weeklyGoal);
    notifyListeners();
  }

  Future<void> setWeeklyStreak(int weeklyStreak) async {
    _weeklyStreak = weeklyStreak;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyStreak', weeklyStreak);
    notifyListeners();
  }

  Future<void> setLastUpdateString(String lastUpdateString) async {
    _lastUpdateString = lastUpdateString;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUpdateString', lastUpdateString);
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

  Future<void> setGoals(List<String> goals) async {
    _goals = goals;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('goals', goals);
    notifyListeners();
  }

  Future<void> setQuestionnaireDone(bool questionnaireDone) async {
    _questionnaireDone = questionnaireDone;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('questionnaireDone', questionnaireDone);
    notifyListeners();
  }

  Future<void> setPayedSubscription(bool payedSubscription) async {
    _payedSubscription = payedSubscription;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payedSubscription', payedSubscription);
    notifyListeners();
  }

  Future<void> setSubType(String subType) async {
    _subType = subType;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('subType', subType);
    notifyListeners();
  }

  Future<void> setSubStarted(DateTime subStarted) async {
    _subStarted = subStarted;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('birthdate', subStarted.toIso8601String());
    notifyListeners();
  }

  Future<void> setReceiptData(String receiptData) async {
    _receiptData = receiptData;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('receiptData', receiptData);
    notifyListeners();
  }

  Future<void> setLastResetDate(String lastResetDate) async {
    _lastResetDate = lastResetDate;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastResetDate', lastResetDate);
    notifyListeners();
  }

  Future<void> setFeedback(List<ExerciseFeedback> feedback) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String feedbackJson = json.encode(feedback.map((f) => f.toJson()).toList());
    await prefs.setString('feedback', feedbackJson);
  }
}

class ProfilPage extends StatefulWidget {
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;
  final bool Function() isLoggedIn;

  const ProfilPage({
    Key? key,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  ProfilPageState createState() => ProfilPageState();

  static Widget builder(BuildContext context, Function(bool) setAuth,
      VoidCallback setQuestDone, bool Function() isLoggedIn) {
    return ChangeNotifierProvider(
      create: (context) => ProfilProvider(),
      child: ProfilPage(
        setAuthenticated: setAuth,
        setQuestionnairDone: setQuestDone,
        isLoggedIn: isLoggedIn,
      ),
    );
  }
}

class ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    getAuthToken().then((token) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double startingPadding;
    double spacerBox;
    double spacerBox2;

    if (isSmallScreen) {
      startingPadding = 0;
      spacerBox = 10;
      spacerBox2 = 5.0;
    } else {
      startingPadding = MediaQuery.of(context).size.height * 0.06;
      spacerBox = MediaQuery.of(context).size.height * 0.02;
      spacerBox2 = 15.0;
    }

    return SafeArea(
        child: SizedBox(
      width: double.maxFinite,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: startingPadding,
        ),
        child:
            Consumer<ProfilProvider>(builder: (context, profilProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowWithImageAndText(context),
              SizedBox(height: spacerBox),
              Text(
                "Ziele",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 23.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Einheiten pro Woche",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "${profilProvider.weeklyDone}/${profilProvider.weeklyGoal}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              ProgressBarWithPill(
                  initialProgress: min(
                      profilProvider.weeklyDone / profilProvider.weeklyGoal,
                      1.0)),
              SizedBox(height: spacerBox2),
              Text(
                "Statistiken",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 14.0),
              Consumer<ProfilProvider>(
                builder: (context, provider, child) {
                  return _buildRowWithColumns(
                      context, provider.completedLevelsTotal);
                },
              ),
            ],
          );
        }),
      ),
    ));
  }

  Widget _buildRowWithImageAndText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double bigNumberFontSize;
    double leafDimensions;
    double settingsIconSize;

    if (isSmallScreen) {
      bigNumberFontSize = 60;
      leafDimensions = 60;
      settingsIconSize = 25;
    } else {
      bigNumberFontSize = 85;
      leafDimensions = 80;
      settingsIconSize = 40;
    }

    bool loggedIn = !widget.isLoggedIn();
    print("visibilty $loggedIn");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // This aligns children to the right
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Container(
                          width: 160,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.settings),
                            iconSize: settingsIconSize,
                            color: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsPage(
                                          setAuthenticated:
                                              widget.setAuthenticated,
                                          setQuestionnairDone:
                                              widget.setQuestionnairDone,
                                        )),
                              );
                            },
                          )),
                      /* Container(
                          width: 60,
                          margin: EdgeInsets.only(right: 0),
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.info),
                            iconSize: settingsIconSize,
                            color: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InfoPage()));
                            },
                          )), */
                    ],
                  ),
                  Positioned(
                    top: 12,
                    left: 25,
                    child: Visibility(
                      visible: loggedIn,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    setAuthenticated: widget.setAuthenticated,
                                    setQuestionnairDone:
                                        widget.setQuestionnairDone,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Consumer<ProfilProvider>(
            builder: (context, profilProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${profilProvider.weeklyStreak}",
                        style: TextStyle(fontSize: bigNumberFontSize),
                      ),
                      const SizedBox(width: 8),
                      Image.asset('assets/leaf.png',
                          width: leafDimensions, height: leafDimensions),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Wochen in Folge!",
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign
                        .center, // Center the text within the Text widget
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildRowWithColumns(BuildContext context, int completedLevelsTotal) {
    final List<String> options2 = [
      'Nicht so oft',
      'Mehrmals im Monat',
      'Einmal pro Woche',
      'Mehrmals pro Woche',
      'Täglich',
    ];

    return Consumer<ProfilProvider>(builder: (context, profilProvider, child) {
      return SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildColumnWithText(
                dynamicText: "$completedLevelsTotal",
                dynamicText1: "Einheiten",
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildColumnWithText(
                dynamicText: "${profilProvider.hasPain.length}",
                dynamicText1: "Schmerzen",
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildColumnWithText(
                dynamicText:
                    "${options2.indexOf(profilProvider.fitnessLevel ?? 'Nicht so oft')}",
                dynamicText1: "Fitness",
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildColumnWithText({
    required String dynamicText,
    required String dynamicText1,
  }) {
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: const Color(0xFFf5f2f2),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFb3b3b3),
              offset: Offset(0, 5),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5.0),
            Text(
              dynamicText,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Colors.blueGrey[900],
                  ),
            ),
            Text(
              dynamicText1,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.lime[900],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
