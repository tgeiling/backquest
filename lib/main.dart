import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroke_text/stroke_text.dart';

import 'stats.dart';
import 'video.dart';
import 'questionaire.dart';
import 'elements.dart';
import 'auth.dart';
import 'services.dart';
import 'settings.dart';

class LevelNotifier with ChangeNotifier {
  Map<int, Level> _levels = {};

  Map<int, Level> get levels => _levels;

  int get completedLevels =>
      _levels.values.where((level) => level.isDone).length;

  LevelNotifier() {
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<int, Level> tempLevels = {
      1: Level(
          id: 1,
          description: "Erste Schritte zur Rückengesundheit",
          minutes: 13),
      2: Level(id: 2, description: "Schritt 2 für deinen Rücken", minutes: 12),
      3: Level(id: 3, description: "Alle guten Dinge sind 3", minutes: 14),
      4: Level(id: 4, description: "Fokus auf Unteren Rücken", minutes: 11),
      5: Level(
          id: 5,
          description: "Zu einfach? Passe dein Fitnesslevel an",
          reward: "Gold Coin",
          minutes: 6),
      6: Level(id: 6, description: "Die meisten geben hier auf!", minutes: 6),
      7: Level(id: 7, description: "Rückenschmerzen hartnäckig?", minutes: 6),
      8: Level(id: 8, description: "Du bist auf einem gutem Weg", minutes: 6),
      9: Level(id: 9, description: "Fokus auf Hüfte", minutes: 6),
      10: Level(
          id: 10,
          description: "Schon fast 10 Level geschafft",
          reward: "Gold Coin",
          minutes: 6),
      11: Level(id: 11, description: "Fokus auf Schultern", minutes: 6),
      12: Level(
          id: 12,
          description: "Jetzt hast du bald alles ausprobiert",
          minutes: 6),
      13: Level(id: 13, description: "Lange Meditation", minutes: 6),
      14: Level(id: 14, description: "Fokus auf Unterer Rücken", minutes: 6),
      15: Level(
          id: 15,
          description: "Schau wie weit du schon bist!",
          reward: "Gold Coin",
          minutes: 6),
      16: Level(id: 16, description: "Noch 4 Level!", minutes: 6),
      17: Level(id: 17, description: "Noch 3 Level!", minutes: 6),
      18: Level(id: 18, description: "Noch 2 Level!", minutes: 6),
      19: Level(id: 19, description: "Noch 1 Level!", minutes: 6),
      20: Level(
          id: 20,
          description: "20 Übungen machen eine Gewohnheit",
          reward: "Gold Coin",
          minutes: 6),
    };

    _levels = {
      for (var entry in tempLevels.entries)
        entry.key: Level(
          id: entry.value.id,
          description: entry.value.description,
          minutes: entry.value.minutes,
          reward: entry.value.reward,
          isDone: prefs.getBool('level_${entry.value.id}_isDone') ?? false,
        ),
    };

    notifyListeners();
  }

  void updateLevelStatus(int levelId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${levelId}_isDone', true);
    await prefs.setInt('completedLevels', completedLevels + 1);

    getAuthToken().then((token) {
      if (token != null) {
        updateProfile(
          token: token,
          completedLevels: levelId,
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

    _levels[levelId]?.isDone = true;
    notifyListeners();
  }

  void updateLevelStatusSync(int levelId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${levelId}_isDone', true);

    _levels[levelId]?.isDone = true;
    _loadLevels();
    notifyListeners();
  }

  void loadLevelsAfterStart() async {
    _loadLevels();
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LevelNotifier()),
        ChangeNotifierProvider(create: (context) => ProfilProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool? _authenticated;
  bool? _loggedIn;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    Future.microtask(() =>
        Provider.of<ProfilProvider>(context, listen: false).loadInitialData());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Provider.of<ProfilProvider>(context, listen: false).loadInitialData();
    }
  }

  TextTheme buildTextTheme(BuildContext context) {
    var baseTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      letterSpacing: 0.4,
    );

    // Determine screen width for responsive sizing
    double screenWidth = MediaQuery.of(context).size.width;

    // Define responsive sizes based on screen width
    double smallTextSize = screenWidth < 360 ? 11.0 : 16.0;
    double normalTextSize = screenWidth < 360 ? 12.0 : 18.0;
    double largeTextSize = screenWidth < 360 ? 16.0 : 20.0;
    double xLargeTextSize = screenWidth < 360 ? 18.0 : 22.0;
    double xxLargeTextSize = screenWidth < 360 ? 20.0 : 24.0;

    double labelLarge = screenWidth < 360 ? 14.0 : 18.0;

    return TextTheme(
      displayLarge: baseTextStyle.copyWith(fontSize: xxLargeTextSize),
      displayMedium: baseTextStyle.copyWith(fontSize: xLargeTextSize),
      displaySmall: baseTextStyle.copyWith(fontSize: largeTextSize),
      headlineLarge: baseTextStyle.copyWith(
          fontSize: largeTextSize, fontWeight: FontWeight.bold),
      headlineMedium: baseTextStyle.copyWith(
          fontSize: normalTextSize, fontWeight: FontWeight.bold),
      headlineSmall: baseTextStyle.copyWith(
          fontSize: smallTextSize, fontWeight: FontWeight.bold),
      titleLarge: baseTextStyle.copyWith(fontSize: largeTextSize),
      titleMedium: baseTextStyle.copyWith(fontSize: normalTextSize),
      titleSmall: baseTextStyle.copyWith(fontSize: smallTextSize),
      labelLarge: baseTextStyle.copyWith(fontSize: labelLarge),
      bodyLarge: baseTextStyle.copyWith(fontSize: normalTextSize),
      bodyMedium: baseTextStyle.copyWith(fontSize: smallTextSize),
      bodySmall: baseTextStyle.copyWith(fontSize: smallTextSize - 2),
    );
  }

  Future<void> _checkAuthentication() async {
    bool isGuest = await _authService.isGuestToken();
    bool tokenExpired = await _authService.isTokenExpired();

    if (isGuest) {
      setState(() {
        _setAuthenticated(true);
      });
    } else if (!isGuest) {
      setState(() {
        _setAuthenticated(false);
      });
    } else {
      await _authService.setGuestToken();
      tokenExpired = await _authService.isTokenExpired();
      setState(() {
        _setAuthenticated(!tokenExpired);
        _setLoggedIn(false);
      });
    }
  }

  void _setAuthenticated(bool authenticated) {
    setState(() => _authenticated = authenticated);
    _setLoggedIn(authenticated);
    _checkQuestionnaireCompletion();
  }

  void _setLoggedIn(bool loggedIn) {
    setState(() {
      _loggedIn = loggedIn;
    });
  }

  bool isLoggedIn() {
    return _loggedIn ?? false;
  }

  Future<void> _checkQuestionnaireCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final bool questionnaireCompleted =
        prefs.getBool('questionnaireDone') ?? false;

    if (questionnaireCompleted) {
      setState(() {
        questionaireDone = true;
      });
    } else {
      setState(() {
        questionaireDone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated == null) {
      return MaterialApp(
        home: CircularProgressIndicator(),
      );
    }

    return MaterialApp(
        title: 'Backquest',
        theme: ThemeData(
          primaryColor: Colors.green,
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            labelStyle: TextStyle(
              color: Colors.black,
            ),
          ),
          fontFamily: 'Roboto',
          textTheme: buildTextTheme(context),
        ),
        home: questionaireDone
            ? MainScaffold(
                setAuthenticated: _setAuthenticated,
                setQuestionnairDone: _checkQuestionnaireCompletion,
                isLoggedIn: isLoggedIn,
              )
            : QuestionnaireScreen(
                checkQuestionaire: _checkQuestionnaireCompletion));
  }
}

class MainScaffold extends StatefulWidget {
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;
  final bool Function() isLoggedIn;

  MainScaffold(
      {Key? key,
      required this.setAuthenticated,
      required this.setQuestionnairDone,
      required this.isLoggedIn})
      : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isModalVisible = false;
  String modalDescription = "Declaring Description";
  int level = 0;

  void _toggleModal(
      [String setDescription = "Was passt für dich ?", int setLevel = 0]) {
    setState(() {
      _isModalVisible = !_isModalVisible;
      if (_isModalVisible) {
        modalDescription = setDescription;
        level = setLevel;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkLaunchAndShowDialog();
  }

  Future<void> checkLaunchAndShowDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = (prefs.getInt('launchCount') ?? 0) + 1;
    await prefs.setInt('launchCount', launchCount);

    print(launchCount);

    if (launchCount % 2 == 0 || launchCount == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSubscriptionDialog();
      });
    }
  }

  void showSubscriptionDialog() {
    showDialog<String>(
      context: context,
      builder: (context) {
        String selectedSubscription = 'Monatlich';
        double screenWidth = MediaQuery.of(context).size.width;
        bool isSmallScreen = screenWidth < 360;

        double rectangleBoxWidth;
        double rectangleBoxPadding;

        if (isSmallScreen) {
          rectangleBoxWidth = screenWidth * 0.30;
          rectangleBoxPadding = 16;
        } else {
          rectangleBoxWidth = screenWidth * 0.33;
          rectangleBoxPadding = 20;
        }

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            backgroundColor: Color.fromRGBO(97, 184, 115, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Image.asset(
                    "assets/logo2.png",
                    width: 40,
                  ),
                  SizedBox(height: 10),
                  if (!isSmallScreen)
                    Center(
                      child: Text(
                        "Willst du unseren service länger nutzen? Wir versprechen dir das wir backquest immer weiter entwickeln",
                      ),
                    ),
                  SizedBox(height: 18),
                  Center(
                    child: Text(
                        "Wähle eine Zahlungsmethode für unbegrenzeten Zugang zu unserer App"),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedSubscription = 'Jährlich';
                          });
                        },
                        child: Container(
                          width: rectangleBoxWidth,
                          padding: EdgeInsets.all(rectangleBoxPadding),
                          decoration: BoxDecoration(
                            color: selectedSubscription == 'Jährlich'
                                ? const Color(0xFF59c977)
                                : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: selectedSubscription == 'Jährlich'
                                    ? const Color(0xFF48a160)
                                    : Colors.transparent,
                                offset: Offset(0, 5),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Jährlich \n 65,99 € \n Jahr",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedSubscription = 'Monatlich';
                          });
                        },
                        child: Container(
                          width: rectangleBoxWidth,
                          padding: EdgeInsets.all(rectangleBoxPadding),
                          decoration: BoxDecoration(
                            color: selectedSubscription == 'Monatlich'
                                ? const Color(0xFF59c977)
                                : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: selectedSubscription == 'Monatlich'
                                    ? const Color(0xFF48a160)
                                    : Colors.transparent,
                                offset: Offset(0, 5),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Monatlich \n 10,99 € \n Monat",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  PressableButton(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    onPressed: () {
                      Navigator.of(context).pop(selectedSubscription);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentSettingPage(
                                subscriptionType: selectedSubscription!),
                          ));
                    },
                    child: Text('Jetzt kaufen'),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).then((selectedSubscription) {
      if (selectedSubscription != null) {
        print("Selected Subscription: $selectedSubscription");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double modalHeight;

    if (isSmallScreen) {
      modalHeight = 250;
    } else {
      modalHeight = 380;
    }

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isModalVisible) {
                _toggleModal();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(97, 184, 115, 0.9),
                          Color.fromRGBO(0, 59, 46, 0.9),
                        ],
                      ),
                    ),
                    child: LevelSelectionScreen(toggleModal: _toggleModal)),
                Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(97, 184, 115, 0.9),
                          Color.fromRGBO(0, 59, 46, 0.9),
                        ],
                      ),
                    ),
                    child: ProfilPage(
                      setAuthenticated: widget.setAuthenticated,
                      setQuestionnairDone: widget.setQuestionnairDone,
                      isLoggedIn: widget.isLoggedIn,
                    )),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isModalVisible ? 0 : -450,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 59, 46, 0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Container(
                height: modalHeight,
                width: double.maxFinite,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print("Inner pressed");
                  },
                  child: CustomBottomModal(
                    description: modalDescription,
                    levelId: level,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double navHeight;

    if (isSmallScreen) {
      navHeight = 60;
    } else {
      navHeight = 90;
    }

    return Container(
      height: navHeight,
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: SalomonBottomBar(
              backgroundColor: Color.fromRGBO(0, 59, 46, 0.9),
              currentIndex: _currentIndex,
              onTap: (i) {
                _pageController.jumpToPage(i);
              },
              items: [
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    size: MediaQuery.of(context).size.width * 0.09,
                    color: Colors.white,
                  ),
                  title: Text("Main"),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.chart_bar_square,
                    size: MediaQuery.of(context).size.width * 0.09,
                    color: Colors.white,
                  ),
                  title: Text("Stats"),
                  selectedColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_isModalVisible) {
      return Container();
    } else {
      return Container(
        child: GestureDetector(
          onTap: _toggleModal,
          child: /* PressableButton(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Icon(Icons.arrow_upward, color: Colors.white, size: 24),
          ), */
              Text(""),
        ),
      );
    }
  }
}

class CustomBottomModal extends StatefulWidget {
  final String description;
  final int levelId;

  CustomBottomModal(
      {Key? key, required this.description, required this.levelId})
      : super(key: key);

  @override
  _CustomBottomModalState createState() => _CustomBottomModalState();
}

class _CustomBottomModalState extends State<CustomBottomModal> {
  int selectedDuration = 900;
  String selectedFocus = "Allgemein";
  String selectedGoal = "Allgemein";

  final List<String> focusOptions = [
    "unterer Ruecken",
    "oberer Ruecken",
    "Nacken",
    "Schulter",
    "Knie",
    "Allgemein"
  ];

  final List<String> goalOptions = [
    "Allgemein",
    "Kraft",
    "Beweglichkeit",
    "Haltung"
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double modalPadding;
    double smallPressableVerticalPadding;
    double smallPressableHorizontalPadding;
    double bigPressableVerticalPadding;
    double aspectRatioItems;

    if (isSmallScreen) {
      modalPadding = 8;
      smallPressableVerticalPadding = 0;
      smallPressableHorizontalPadding = 0;
      bigPressableVerticalPadding = 4;
      aspectRatioItems = 10;
    } else {
      modalPadding = 16;
      smallPressableVerticalPadding = 8;
      smallPressableHorizontalPadding = 12;
      bigPressableVerticalPadding = 14;
      aspectRatioItems = 8;
    }

    return Padding(
      padding: EdgeInsets.all(modalPadding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Passe dein Training an!",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10,
              childAspectRatio: aspectRatioItems / 1,
              children: <Widget>[
                PressableButton(
                  onPressed: () => showDurationDialog(),
                  padding: EdgeInsets.symmetric(
                      vertical: smallPressableVerticalPadding,
                      horizontal: smallPressableHorizontalPadding),
                  child: Center(
                    child: Text(
                      "Dauer: ${selectedDuration ~/ 60} Minuten",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                PressableButton(
                  onPressed: () => showOptionDialogFocus(focusOptions,
                      "Wählen Sie den Fokus", (value) => selectedFocus = value),
                  padding: EdgeInsets.symmetric(
                      vertical: smallPressableVerticalPadding,
                      horizontal: smallPressableHorizontalPadding),
                  child: Center(
                    child: Text(
                      "Fokus: $selectedFocus",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                PressableButton(
                  onPressed: () => showOptionDialogGoal(goalOptions,
                      "Wählen Sie das Ziel", (value) => selectedGoal = value),
                  padding: EdgeInsets.symmetric(
                      vertical: smallPressableVerticalPadding,
                      horizontal: smallPressableHorizontalPadding),
                  child: Center(
                    child: Text(
                      "Ziel: $selectedGoal",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          PressableButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCombinerScreen(
                    levelId: widget.levelId,
                    levelNotifier:
                        Provider.of<LevelNotifier>(context, listen: false),
                    profilProvider:
                        Provider.of<ProfilProvider>(context, listen: false),
                    focus: selectedFocus,
                    goal: selectedGoal,
                    duration: selectedDuration,
                  ),
                ),
              );
            },
            padding: EdgeInsets.symmetric(
                vertical: bigPressableVerticalPadding, horizontal: 12),
            child: Center(
                child: Text(
              "Jetzt starten",
              style: Theme.of(context).textTheme.labelLarge,
            )),
          ),
        ],
      ),
    );
  }

  void showDurationDialog() async {
    int? duration = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(97, 184, 115, 1),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.0), // Rounded corners for the dialog
          ),
          title: Text(
            "Wählen Sie die Dauer",
            style:
                TextStyle(color: Colors.white), // Title text with white color
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                int minute = 4 + index;
                return ListTile(
                  selectedColor: Colors.green,
                  title: Text(
                    "$minute Minuten",
                    style: TextStyle(
                        color: Colors.white), // List item text with white color
                  ),
                  onTap: () => Navigator.of(context).pop(minute * 60),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Abbrechen",
                style: TextStyle(
                    color: Colors.white), // Button text with white color
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );

    if (duration != null) {
      setState(() {
        selectedDuration = duration;
      });
    }
  }

  void showOptionDialogFocus(List<String> options, String title,
      void Function(String) onSelected) async {
    String? selection = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(97, 184, 115, 1),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map((String option) => RadioListTile<String>(
                        activeColor: Colors.white,
                        title: Text(
                          option,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: option,
                        groupValue: selectedFocus,
                        onChanged: (String? value) {
                          if (value != null) {
                            Navigator.of(context).pop(value);
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );

    if (selection != null) {
      setState(() {
        onSelected(selection);
      });
    }
  }

  void showOptionDialogGoal(List<String> options, String title,
      void Function(String) onSelected) async {
    String? selection = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(97, 184, 115, 1),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map((String option) => RadioListTile<String>(
                        activeColor: Colors.white,
                        title: Text(
                          option,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: option,
                        groupValue: selectedGoal,
                        onChanged: (String? value) {
                          if (value != null) {
                            Navigator.of(context).pop(value);
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );

    if (selection != null) {
      setState(() {
        onSelected(selection);
      });
    }
  }
}

class CompletedLevelsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 2.0),
        ),
      ),
      child: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 20),
            Consumer<LevelNotifier>(
              builder: (context, levelNotifier, child) {
                int completedLevels = levelNotifier.completedLevels;

                return Row(
                  children: [
                    Image.asset('assets/crownIcon.png', height: 24),
                    SizedBox(width: 8),
                    Text("$completedLevels", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 20),
                    Image.asset('assets/fireIcon.png', height: 24),
                    SizedBox(width: 8),
                    Text("$completedLevels", style: TextStyle(fontSize: 20)),
                  ],
                );
              },
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1.0);
}

class Level {
  final int id;
  final String description;
  final int minutes;
  final String reward;
  bool isDone;

  Level(
      {required this.id,
      required this.description,
      this.minutes = 15,
      this.reward = '',
      this.isDone = false});
}

class LevelSelectionScreen extends StatefulWidget {
  final Function(String, int) toggleModal;

  LevelSelectionScreen({required this.toggleModal});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final levelNotifier = Provider.of<LevelNotifier>(context);
    final levels = levelNotifier.levels;

    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemCount: levels.length,
      itemBuilder: (context, index) {
        int levelId = levels.keys.toList()[index];
        Level level = levels[levelId]!;

        int row = index % 4;
        int group = index ~/ 4;

        bool isEvenGroup = group % 2 == 0;
        double startPadding, endPadding;
        if (isEvenGroup) {
          startPadding = MediaQuery.of(context).size.width / 8 * row;
          endPadding = MediaQuery.of(context).size.width / 8 * (3 - row);
        } else {
          startPadding = MediaQuery.of(context).size.width / 8 * (3 - row);
          endPadding = MediaQuery.of(context).size.width / 8 * row;
        }

        bool isNext = false;
        if (!level.isDone) {
          int? maxDoneLevelId = levels.entries
              .where((entry) => entry.value.isDone)
              .map((entry) => entry.key)
              .fold<int?>(
                  null,
                  (prev, element) => prev != null
                      ? (element > prev ? element : prev)
                      : element);

          if (maxDoneLevelId == null) {
            isNext = levelId == levels.keys.first;
          } else {
            if (levelId == maxDoneLevelId + 1) {
              isNext = true;
            }
          }
        }

        return Padding(
          padding: EdgeInsets.only(left: startPadding, right: endPadding),
          child: LevelCircle(
            level: level.id,
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.toggleModal(level.description, level.id);
              });
            },
            isTreasureLevel: level.id % 4 == 0,
            isDone: level.isDone,
            isNext: isNext,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class LevelCircle extends StatelessWidget {
  final int level;
  final VoidCallback onTap;
  final bool isTreasureLevel;
  final bool isDone;
  final bool isNext;

  LevelCircle({
    required this.level,
    required this.onTap,
    this.isTreasureLevel = false,
    this.isDone = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    String imageName;
    if (isDone) {
      imageName = 'assets/button_green.png';
    } else if (isNext) {
      imageName = 'assets/button_grey.png';
    } else {
      imageName = 'assets/button_locked.png';
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double levelNumberFontSize;
    double levelNumberFontPadding;
    double buttonDimension;
    double startFontSize;
    double startAbsoluteTopValue;

    if (isSmallScreen) {
      levelNumberFontSize = 28;
      levelNumberFontPadding = 10;
      buttonDimension = 70;
      startFontSize = 12;
      startAbsoluteTopValue = 50;
    } else {
      levelNumberFontSize = 34;
      buttonDimension = 95;
      levelNumberFontPadding = 15;
      startFontSize = 15;
      startAbsoluteTopValue = 65;
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          if (isNext || isDone) {
            onTap();
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                width: buttonDimension,
                height: buttonDimension,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageName),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Container(
                  padding:
                      EdgeInsets.only(right: 0, bottom: levelNumberFontPadding),
                  child: Center(
                    child: (isDone || isNext)
                        ? StrokeText(
                            text: "$level",
                            textStyle: TextStyle(
                                fontSize: levelNumberFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            strokeColor: Colors.black,
                            strokeWidth: 2,
                          )
                        : SizedBox
                            .shrink(), // Empty widget if the conditions aren't met
                  ),
                )),
            if (isNext)
              Positioned(
                top: startAbsoluteTopValue,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "START",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: startFontSize,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
