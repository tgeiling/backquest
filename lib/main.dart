import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:backquest/info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';

import 'stats.dart';
import 'video.dart';
import 'questionaire.dart';
import 'elements.dart';
import 'auth.dart';
import 'services.dart';
import 'settings.dart';
import 'download.dart';
import 'localization_service.dart';

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
    final localizationService = GetIt.I<LocalizationService>();

    Map<int, Level> tempLevels = {
      1: Level(
        id: 1,
        description:
            localizationService.getTranslatedString('level1Description'),
        minutes: 13,
      ),
      2: Level(
        id: 2,
        description:
            localizationService.getTranslatedString('level2Description'),
        minutes: 12,
      ),
      3: Level(
        id: 3,
        description:
            localizationService.getTranslatedString('level3Description'),
        minutes: 14,
      ),
      4: Level(
        id: 4,
        description:
            localizationService.getTranslatedString('level4Description'),
        minutes: 11,
      ),
      5: Level(
        id: 5,
        description:
            localizationService.getTranslatedString('level5Description'),
        reward: localizationService.getTranslatedString('rewardGoldCoin'),
        minutes: 6,
      ),
      6: Level(
        id: 6,
        description:
            localizationService.getTranslatedString('level6Description'),
        minutes: 6,
      ),
      7: Level(
        id: 7,
        description:
            localizationService.getTranslatedString('level7Description'),
        minutes: 6,
      ),
      8: Level(
        id: 8,
        description:
            localizationService.getTranslatedString('level8Description'),
        minutes: 6,
      ),
      9: Level(
        id: 9,
        description:
            localizationService.getTranslatedString('level9Description'),
        minutes: 6,
      ),
      10: Level(
        id: 10,
        description:
            localizationService.getTranslatedString('level10Description'),
        reward: localizationService.getTranslatedString('rewardGoldCoin'),
        minutes: 6,
      ),
      11: Level(
        id: 11,
        description:
            localizationService.getTranslatedString('level11Description'),
        minutes: 6,
      ),
      12: Level(
        id: 12,
        description:
            localizationService.getTranslatedString('level12Description'),
        minutes: 6,
      ),
      13: Level(
        id: 13,
        description:
            localizationService.getTranslatedString('level13Description'),
        minutes: 6,
      ),
      14: Level(
        id: 14,
        description:
            localizationService.getTranslatedString('level14Description'),
        minutes: 6,
      ),
      15: Level(
        id: 15,
        description:
            localizationService.getTranslatedString('level15Description'),
        reward: localizationService.getTranslatedString('rewardGoldCoin'),
        minutes: 6,
      ),
      16: Level(
        id: 16,
        description:
            localizationService.getTranslatedString('level16Description'),
        minutes: 6,
      ),
      17: Level(
        id: 17,
        description:
            localizationService.getTranslatedString('level17Description'),
        minutes: 6,
      ),
      18: Level(
        id: 18,
        description:
            localizationService.getTranslatedString('level18Description'),
        minutes: 6,
      ),
      19: Level(
        id: 19,
        description:
            localizationService.getTranslatedString('level19Description'),
        minutes: 6,
      ),
      20: Level(
        id: 20,
        description:
            localizationService.getTranslatedString('level20Description'),
        reward: localizationService.getTranslatedString('rewardGoldCoin'),
        minutes: 6,
      ),
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

    int? completedLevelsTotal = await prefs.getInt('completedLevelsTotal');

    getAuthToken().then((token) {
      if (token != null) {
        updateProfile(
          token: token,
          completedLevels: levelId,
          completedLevelsTotal: completedLevelsTotal!,
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

  void earaseLevelStatusSync(int levelId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${levelId}_isDone', false);

    _levels[levelId]?.isDone = true;
    _loadLevels();
    notifyListeners();
  }

  Future<void> resetAllLevels() async {
    final prefs = await SharedPreferences.getInstance();

    if (completedLevels >= 1) {
      await prefs.setInt('completedLevels', 0);

      for (int levelId = 1; levelId <= 20; levelId++) {
        earaseLevelStatusSync(levelId);
      }

      getAuthToken().then((token) {
        if (token != null) {
          updateProfile(
            token: token,
            completedLevels: 0,
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
    } else {
      print('Invalid completedLevels value: $completedLevels');
    }
  }
}

final GetIt getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingleton<LocalizationService>(LocalizationService());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LevelNotifier()),
        ChangeNotifierProvider(create: (context) => ProfilProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

GlobalKey<DownloadScreenState> downloadScreenKey =
    GlobalKey<DownloadScreenState>();

bool isModalOpen = false;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool? _authenticated;
  bool? _loggedIn;
  final AuthService _authService = AuthService();
  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;
  bool _showConnectionMessage = true;
  bool _showAuthenticateMessage = true;
  bool _isLoading = true; // New state variable for loading

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    Future.microtask(() =>
        Provider.of<ProfilProvider>(context, listen: false).loadInitialData());
    WidgetsBinding.instance.addObserver(this);

    // Initialize connectivity
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
    _checkInitialConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndResetLevels(); // Call the reset check after the app has loaded
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected = !results.contains(ConnectivityResult.none);
      _showConnectionMessage =
          !_isConnected || (_authenticated == false && _isConnected);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Provider.of<ProfilProvider>(context, listen: false).loadInitialData();
    }
  }

  TextTheme buildTextTheme(BuildContext context) {
    var baseTextStyle = const TextStyle(
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
    setState(() {
      _isLoading = true;
    });

    bool isGuest = await _authService.isGuestToken();
    bool tokenExpired = await _authService.isTokenExpired();

    if (!isGuest) {
      setState(() {
        _setAuthenticated(true);
      });
      if (tokenExpired) {
        setState(() {
          _setAuthenticated(false);
        });
      }
    } else {
      await _authService.setGuestToken();
      setState(() {
        _setAuthenticated(false);
      });
    }

    _checkQuestionnaireCompletion();
    setState(() {
      _isLoading = false;
    });
  }

  void _setAuthenticated(bool authenticated) {
    setState(() => _authenticated = authenticated);
    _setLoggedIn(authenticated);
    _checkQuestionnaireCompletion();
    _showAuthenticateMessage = !authenticated;
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

  bool showResetDialogBool = false;

  Future<void> checkAndResetLevels() async {
    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelNotifier>(context, listen: false);
    await profilProvider.loadInitialData();

    String? lastResetDateString = profilProvider.lastResetDate;

    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    if (lastResetDateString != null) {
      DateTime lastResetDate = DateTime.parse(lastResetDateString);

      if (now.month != lastResetDate.month || now.year != lastResetDate.year) {
        setState(() {
          levelProvider.resetAllLevels();
        });

        levelProvider.loadLevelsAfterStart();
        profilProvider.loadInitialData();

        // Store the new reset date
        await profilProvider.setLastResetDate(formatter.format(now));

        showResetDialogBool = true;

        getAuthToken().then((token) {
          if (token != null) {
            updateProfile(
              token: token,
              lastResetDate: formatter.format(now),
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
    } else {
      await profilProvider.setLastResetDate(formatter.format(now));
      getAuthToken().then((token) {
        if (token != null) {
          updateProfile(
            token: token,
            lastResetDate: formatter.format(now),
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Backquest',
      theme: ThemeData(
        primaryColor: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // Initialize LocalizationService after MaterialApp is built
        final appLocalizations = AppLocalizations.of(context);
        if (appLocalizations != null) {
          GetIt.I<LocalizationService>().initialize(appLocalizations);
        } else {
          print("AppLocalizations is null, unable to initialize.");
        }
        return child!;
      },
      home: Container(
          constraints: BoxConstraints.expand(),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            // Determine if the device is a tablet
            bool isTablet = constraints.maxWidth >= 600;

            return Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 48.0 : 16.0),
                    child: Stack(
                      children: [
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else
                          questionaireDone
                              ? MainScaffold(
                                  authenticated: _authenticated ?? false,
                                  setAuthenticated: _setAuthenticated,
                                  setQuestionnairDone:
                                      _checkQuestionnaireCompletion,
                                  isLoggedIn: isLoggedIn,
                                  showResetDialogBool: showResetDialogBool,
                                )
                              : QuestionnaireScreen(
                                  checkQuestionaire:
                                      _checkQuestionnaireCompletion,
                                ),
                        if (_showConnectionMessage)
                          Positioned(
                            top: 70,
                            left: 16,
                            right: 16,
                            child: GreenContainer(
                                padding: const EdgeInsets.all(8.0),
                                child: NoConnectionWidget(onDismiss: () {
                                  setState(() {
                                    _showConnectionMessage = false;
                                  });
                                })),
                          ),
                        if (_showAuthenticateMessage && questionaireDone)
                          Positioned(
                            top: 70,
                            left: 16,
                            right: 16,
                            child: GreenContainer(
                              padding: const EdgeInsets.all(8.0),
                              child: AuthenticateWidget(
                                onDismiss: () {
                                  setState(() {
                                    print("turn off");
                                    _showAuthenticateMessage = false;
                                  });
                                },
                                setAuthenticated: _setAuthenticated,
                                setQuestionnairDone:
                                    _checkQuestionnaireCompletion,
                              ),
                            ),
                          ),
                      ],
                    )));
          })),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;
  final bool Function() isLoggedIn;
  final bool authenticated;
  final bool showResetDialogBool;

  const MainScaffold({
    Key? key,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
    required this.isLoggedIn,
    required this.authenticated,
    required this.showResetDialogBool,
  }) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isModalVisible = false;
  String modalDescription = "Declaring Description";
  int level = 0;
  bool isVideoPlayer = true;

  void _toggleModal(
      [String setDescription = "Was passt für dich ?",
      int setLevel = 0,
      bool setIsVideoPlayer = true]) {
    setState(() {
      _isModalVisible = !_isModalVisible;
      if (_isModalVisible) {
        modalDescription = setDescription;
        level = setLevel;
        isVideoPlayer = setIsVideoPlayer;
      }
    });

    isModalOpen = !isModalOpen;
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
        //showSubscriptionDialog();
        //showInformationDialog();
      });
    }
  }

  /* void showSubscriptionDialog() {
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
            backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
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
                  const SizedBox(height: 10),
                  Image.asset(
                    "assets/logo2.png",
                    width: 40,
                  ),
                  const SizedBox(height: 10),
                  if (!isSmallScreen)
                    const Center(
                      child: Text(
                        "Willst du unseren service länger nutzen? Wir versprechen dir das wir backquest immer weiter entwickeln",
                      ),
                    ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                        "Wähle eine Zahlungsmethode für unbegrenzeten Zugang zu unserer App"),
                  ),
                  const SizedBox(height: 15),
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
                                offset: const Offset(0, 5),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Jährlich \n 49,99 € \n Jahr",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                offset: const Offset(0, 5),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Monatlich \n 5,99 € \n Monat",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PressableButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    onPressed: () {
                      Navigator.of(context).pop(selectedSubscription);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentSettingPage(
                                subscriptionType: selectedSubscription),
                          ));
                    },
                    child: const Text('Jetzt kaufen'),
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
  } */

  void showInformationDialog() {
    showDialog<String>(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isSmallScreen = screenWidth < 360;

        return Dialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
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
                const SizedBox(height: 10),
                Image.asset(
                  "assets/logo2.png",
                  width: 40,
                ),
                const SizedBox(height: 10),
                if (!isSmallScreen)
                  const Center(
                    child: Text(
                      "Möchtest du mehr über unsere App erfahren? Unsere App hilft dir dabei, Rückenschmerzen zu lindern und deine Gesundheit zu verbessern. Wir arbeiten kontinuierlich daran, neue Funktionen und Inhalte hinzuzufügen.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    "Unsere App bietet personalisierte Übungen, Tipps und Ratschläge, um deine Rückengesundheit zu verbessern.",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                PressableButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  onPressed: () async {
                    const url = 'https://backquest.online';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: const Text('Mehr erfahren'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(97, 184, 115, 0.9),
                          Color.fromRGBO(0, 59, 46, 0.9),
                        ],
                      ),
                    ),
                    child: LevelSelectionScreen(
                        toggleModal: _toggleModal,
                        showResetDialogBool: widget.showResetDialogBool)),
                Container(
                    decoration: const BoxDecoration(
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
                Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(97, 184, 115, 0.9),
                          Color.fromRGBO(0, 59, 46, 0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: ExercisesPageMainScreen(),
                    )),
                Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(97, 184, 115, 0.9),
                          Color.fromRGBO(0, 59, 46, 0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: DownloadScreen(
                        toggleModal: _toggleModal,
                        key: downloadScreenKey,
                      ),
                    )),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isModalVisible ? 0 : -450,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 59, 46, 0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SizedBox(
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
                    authenticated: widget.authenticated,
                    isVideoPlayer: isVideoPlayer,
                    toggleModal: _toggleModal,
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
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Calculate the width and height in actual pixels
    double widthInPixels = screenWidth * pixelRatio;
    double heightInPixels = screenHeight * pixelRatio;

    // Calculate the diagonal in pixels
    double diagonalPixels =
        sqrt(pow(widthInPixels, 2) + pow(heightInPixels, 2));

    // Convert the diagonal from pixels to inches
    double diagonalInches = diagonalPixels /
        pixelRatio /
        160; // 160 is typically used as the DPI baseline

    // A more reliable condition for detecting tablets
    bool isTablet =
        (diagonalInches >= 7.0 && (screenWidth / screenHeight) < 1.6);

    bool isSmallScreen = screenWidth < 360;

    double navHeight;

    if (isSmallScreen) {
      navHeight = 60;
    } else if (isTablet) {
      navHeight = 140;
    } else {
      navHeight = 90;
    }

    return SizedBox(
      height: navHeight,
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: SalomonBottomBar(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              backgroundColor: const Color.fromRGBO(0, 59, 46, 0.9),
              currentIndex: _currentIndex,
              onTap: (i) {
                _pageController.jumpToPage(i);
              },
              items: [
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Colors.white,
                  ),
                  title: const Text("Main"),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.chart_bar_square,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Colors.white,
                  ),
                  title: const Text("Stats"),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.info_circle,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Colors.white,
                  ),
                  title: const Text("Info"),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.cloud_download,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Colors.white,
                  ),
                  title: const Text("Lokal"),
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
              const Text(""),
        ),
      );
    }
  }
}

class CustomBottomModal extends StatefulWidget {
  final String description;
  final int levelId;
  final bool authenticated;
  final bool isVideoPlayer;
  final Function(String, int, bool) toggleModal;

  const CustomBottomModal({
    Key? key,
    required this.description,
    required this.levelId,
    required this.authenticated,
    required this.isVideoPlayer,
    required this.toggleModal,
  }) : super(key: key);

  @override
  _CustomBottomModalState createState() => _CustomBottomModalState();
}

class _CustomBottomModalState extends State<CustomBottomModal> {
  int selectedDuration = 600;
  int selectedFocus = 0;
  int selectedGoal = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> focusOptions = [
      AppLocalizations.of(context)!.focusFullBody,
      AppLocalizations.of(context)!.focusLowerBack,
      AppLocalizations.of(context)!.focusUpperBack,
      AppLocalizations.of(context)!.focusNeck,
      AppLocalizations.of(context)!.focusShoulder,
      AppLocalizations.of(context)!.focusKnee,
    ];

    final List<String> goalOptions = [
      AppLocalizations.of(context)!.goalFullBody,
      AppLocalizations.of(context)!.goalStrength,
      AppLocalizations.of(context)!.goalFlexibility,
      AppLocalizations.of(context)!.goalPosture,
    ];

    var mediaQuery = MediaQuery.of(context);

    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    double pixelRatio = mediaQuery.devicePixelRatio;

    double widthInPixels = screenWidth * pixelRatio;
    double heightInPixels = screenHeight * pixelRatio;

    double diagonalPixels =
        sqrt(pow(widthInPixels, 2) + pow(heightInPixels, 2));

    double diagonalInches = diagonalPixels / pixelRatio / 160;

    bool isTablet =
        (diagonalInches >= 7.0 && (screenWidth / screenHeight) < 1.6);

    double modalPadding;
    double smallPressableVerticalPadding;
    double smallPressableHorizontalPadding;
    double bigPressableVerticalPadding;
    double aspectRatioItems;

    if (screenWidth < 360) {
      modalPadding = 8;
      smallPressableVerticalPadding = 0;
      smallPressableHorizontalPadding = 0;
      bigPressableVerticalPadding = 4;
      aspectRatioItems = 10;
    } else if (isTablet) {
      modalPadding = 24;
      smallPressableVerticalPadding = 0;
      smallPressableHorizontalPadding = 0;
      bigPressableVerticalPadding = 12;
      aspectRatioItems = 16;
    } else {
      modalPadding = 16;
      smallPressableVerticalPadding = 8;
      smallPressableHorizontalPadding = 12;
      bigPressableVerticalPadding = 14;
      aspectRatioItems = 8;
    }

    bool isDateSevenDaysAgo(String isoDateString) {
      DateTime parsedDate = DateTime.parse(isoDateString).toLocal();
      DateTime currentDate = DateTime.now().toLocal();
      DateTime sevenDaysAgo = currentDate.subtract(Duration(days: 7)).toLocal();

      return parsedDate.isBefore(sevenDaysAgo) ||
          parsedDate.isAtSameMomentAs(sevenDaysAgo);
    }

    final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
    final bool readyForNextVideo = profilProvider.lastUpdateString == ""
        ? true
        : isDateSevenDaysAgo(profilProvider.lastUpdateString);

    //bool payedUp = profilProvider.payedSubscription == true ? true : false;

    return Padding(
      padding: EdgeInsets.all(modalPadding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.infoOne,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 4),
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
                      AppLocalizations.of(context)!
                          .durationText(selectedDuration ~/ 60),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                PressableButton(
                  onPressed: () => showOptionDialogFocus(
                      focusOptions,
                      AppLocalizations.of(context)!.chooseFocus,
                      (value) => selectedFocus = value),
                  padding: EdgeInsets.symmetric(
                      vertical: smallPressableVerticalPadding,
                      horizontal: smallPressableHorizontalPadding),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.focus +
                          ": ${focusOptions[selectedFocus]}",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                PressableButton(
                  onPressed: () => showOptionDialogGoal(
                      goalOptions,
                      AppLocalizations.of(context)!.chooseGoal,
                      (value) => selectedGoal = value),
                  padding: EdgeInsets.symmetric(
                      vertical: smallPressableVerticalPadding,
                      horizontal: smallPressableHorizontalPadding),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.goal +
                          ": ${goalOptions[selectedGoal]}",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          /* PressableButton(
            onPressed: widget.authenticated && payedUp
                ? widget.isVideoPlayer
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoCombinerScreen(
                              levelId: widget.levelId,
                              levelNotifier: Provider.of<LevelNotifier>(context,
                                  listen: false),
                              profilProvider: Provider.of<ProfilProvider>(
                                  context,
                                  listen: false),
                              focus: selectedFocus,
                              goal: selectedGoal,
                              duration: selectedDuration,
                            ),
                          ),
                        );
                        widget.toggleModal;
                      }
                    : () {
                        downloadScreenKey.currentState!.combineAndDownloadVideo(
                            selectedFocus,
                            selectedGoal,
                            selectedDuration,
                            ProfilProvider().fitnessLevel);
                      }
                : readyForNextVideo
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoCombinerScreen(
                              levelId: widget.levelId,
                              levelNotifier: Provider.of<LevelNotifier>(context,
                                  listen: false),
                              profilProvider: Provider.of<ProfilProvider>(
                                  context,
                                  listen: false),
                              focus: selectedFocus,
                              goal: selectedGoal,
                              duration: selectedDuration,
                            ),
                          ),
                        );
                        widget.toggleModal;
                      }
                    : () async {
                        await _validateSubscriptionAndShowRestrictionDialog(profilProvider);
                      },
            padding: EdgeInsets.symmetric(
                vertical: bigPressableVerticalPadding, horizontal: 12),
            child: Center(
                child: Text(
              widget.isVideoPlayer ? "Jetzt starten" : "Video erstellen",
              style: Theme.of(context).textTheme.labelLarge,
            )),
          ), */
          PressableButton(
            onPressed: widget.isVideoPlayer
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCombinerScreen(
                          levelId: widget.levelId,
                          levelNotifier: Provider.of<LevelNotifier>(context,
                              listen: false),
                          profilProvider: Provider.of<ProfilProvider>(context,
                              listen: false),
                          focus: selectedFocus,
                          goal: selectedGoal,
                          duration: selectedDuration,
                        ),
                      ),
                    );
                    widget.toggleModal;
                  }
                : () {
                    downloadScreenKey.currentState!.combineAndDownloadVideo(
                        selectedFocus,
                        selectedGoal,
                        selectedDuration,
                        ProfilProvider().fitnessLevel);
                  },
            padding: EdgeInsets.symmetric(
                vertical: bigPressableVerticalPadding, horizontal: 12),
            child: Center(
                child: Text(
              widget.isVideoPlayer
                  ? AppLocalizations.of(context)!.startVideo
                  : AppLocalizations.of(context)!.createVideo,
              style: Theme.of(context).textTheme.labelLarge,
            )),
          ),
        ],
      ),
    );
  }

  /* Future<void> _validateSubscriptionAndShowRestrictionDialog(
      ProfilProvider profilProvider) async {
    bool isValid = false;

    if (Platform.isIOS && profilProvider.receiptData != null) {
      isValid = await validateAppleReceipt(profilProvider.receiptData!);
    } else if (Platform.isAndroid && profilProvider.receiptData != null) {
      isValid = await validateGoogleReceipt(profilProvider.receiptData!);
    }

    if (!isValid && profilProvider.receiptData != null) {
      profilProvider.setPayedSubscription(false);
      profilProvider.setSubType('');
      QuickAlert.show(
        backgroundColor: Colors.red.shade900,
        textColor: Colors.white,
        context: context,
        type: QuickAlertType.error,
        title: 'Abonnement ungültig',
        text: 'Ihr Abonnement wurde storniert oder ist ungültig.',
      );
    }

    showVideoRestrictionDialog(profilProvider.lastUpdateString);
  } */

  void showVideoRestrictionDialog(String lastUpdateString) {
    DateTime lastUpdateDate = DateTime.parse(lastUpdateString).toLocal();
    DateTime nextAvailableDate = lastUpdateDate.add(Duration(days: 7));

    int daysUntilNextVideo =
        nextAvailableDate.difference(DateTime.now()).inDays;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            AppLocalizations.of(context)!.videoRestriction,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.videoRestrictionInfo,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$daysUntilNextVideo ',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.days,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.displayLarge?.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDurationDialog() async {
    int? duration = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            AppLocalizations.of(context)!.chooseDuration,
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                int minute = 5 + index;
                return ListTile(
                  selectedColor: Colors.green,
                  title: Text(
                    AppLocalizations.of(context)!.durationTextTwo(minute),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.of(context).pop(minute * 60),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.white),
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

  void showOptionDialogFocus(
      List<String> options, String title, void Function(int) onSelected) async {
    int? selection = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;
                return RadioListTile<int>(
                  activeColor: Colors.white,
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: index, // Return index as value
                  groupValue: selectedFocus, // Compare with integer
                  onChanged: (int? value) {
                    if (value != null) {
                      Navigator.of(context).pop(value); // Return index
                    }
                  },
                );
              }).toList(),
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

  void showOptionDialogGoal(
      List<String> options, String title, void Function(int) onSelected) async {
    int? selection = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;
                return RadioListTile<int>(
                  activeColor: Colors.white,
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: index, // Return index as value
                  groupValue: selectedGoal, // Compare with integer
                  onChanged: (int? value) {
                    if (value != null) {
                      Navigator.of(context).pop(value); // Return index
                    }
                  },
                );
              }).toList(),
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
  final Function(String, int, bool) toggleModal;
  final bool showResetDialogBool;

  const LevelSelectionScreen(
      {super.key,
      required this.toggleModal,
      required this.showResetDialogBool});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with AutomaticKeepAliveClientMixin<LevelSelectionScreen> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showResetDialogBool) {
        showResetDialog(context);
      }
    });
  }

  DateTime _calculateEndOfMonth() {
    DateTime now = DateTime.now();
    int lastDay = DateTime(now.year, now.month + 1, 0).day;
    return DateTime(now.year, now.month, lastDay, 23, 59, 59);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = _formatTimeRemaining();

        if (_timeRemaining == "00:00:00:00") {
          final levelNotifier =
              Provider.of<LevelNotifier>(context, listen: false);
          final profilProvider =
              Provider.of<ProfilProvider>(context, listen: false);
          levelNotifier.resetAllLevels();
          profilProvider.loadInitialData();
          showResetDialog(context);
        }
      });
    });
  }

  String _formatTimeRemaining() {
    DateTime endOfMonth = _calculateEndOfMonth();
    Duration difference = endOfMonth.difference(DateTime.now());
    if (difference.isNegative) {
      return "00:00:00:00";
    }

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;

    return '${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isDialogOpen = false;

  void showResetDialog(BuildContext context) {
    if (_isDialogOpen) {
      return;
    }

    _isDialogOpen = true;

    showDialog<String>(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isSmallScreen = screenWidth < 360;

        return Dialog(
          backgroundColor:
              Colors.transparent, // Set transparent to use GreenContainer
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: GreenContainer(
            padding:
                const EdgeInsets.all(16.0), // Use GreenContainer for background
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  "assets/logo2.png",
                  width: 40,
                ),
                const SizedBox(height: 10),
                if (!isSmallScreen)
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.resetAllLevels,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, // Ensure text is white on green
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.resetInfo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Ensure text is white on green
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PressableButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  onPressed: () {
                    // Close the dialog and reset the flag
                    Navigator.of(context).pop();
                    _isDialogOpen = false;
                  },
                  child: Text(
                    AppLocalizations.of(context)!.close,
                    style: TextStyle(
                        color: Colors.white), // White text for the button
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Reset the flag when the dialog is closed (even if dismissed by back button)
      _isDialogOpen = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelNotifier = Provider.of<LevelNotifier>(context);
    final levels = levelNotifier.levels;

    return Stack(
      children: [
        ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: levels.length,
          itemBuilder: (context, index) {
            int levelId = levels.keys.toList()[index];
            Level level = levels[levelId]!;

            int group = index ~/ 5;
            int withinGroupIndex = index % 5;
            double screenWidth = MediaQuery.of(context).size.width;
            double curveIntensity = screenWidth / 2;

            double curvePadding;
            double startPadding = 0;
            double endPadding = 0;

            if (group % 2 == 0) {
              startPadding = curveIntensity * sin(withinGroupIndex * pi / 5);
            } else {
              // Left curve (use endPadding)
              endPadding = curveIntensity * sin(withinGroupIndex * pi / 5);
            }

            // Determine if this is the next level
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
                    widget.toggleModal(level.description, level.id, true);
                  });
                },
                isTreasureLevel: level.id % 4 == 0,
                isDone: level.isDone,
                isNext: isNext,
              ),
            );
          },
        ),
        Positioned(
          top: 75,
          left: 15,
          child: GreenContainer(
            padding: const EdgeInsets.all(12.0), // Adjust padding if needed
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level Reset: \n $_timeRemaining',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    OverlayEntry? overlayEntry;

                    overlayEntry = OverlayEntry(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          overlayEntry?.remove();
                        },
                        child: Stack(
                          children: <Widget>[
                            Container(
                              color: Colors.transparent,
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.08,
                              left: MediaQuery.of(context).size.width * 0.45,
                              child: SpeechBubble(
                                message:
                                    ' Alle Level werden\n jeden Monat\n zurückgesetzt.\n Schau, wie weit\n du kommst!\n Du verlierst\n nicht deinen\n Gesamtfortschritt.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    Overlay.of(context)?.insert(overlayEntry);
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24, // Adjust size as needed
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: 15,
          child: Consumer<ProfilProvider>(
            builder: (context, profilProvider, child) {
              int totalLevelsCompleted = profilProvider.completedLevelsTotal;

              return GreenContainer(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Level: $totalLevelsCompleted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LevelCircle extends StatelessWidget {
  final int level;
  final VoidCallback onTap;
  final bool isTreasureLevel;
  final bool isDone;
  final bool isNext;

  const LevelCircle({
    super.key,
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
      imageName = 'assets/button_mint.png';
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
      levelNumberFontSize = 36;
      buttonDimension = 100;
      levelNumberFontPadding = 15;
      startFontSize = 17;
      startAbsoluteTopValue = 65;
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          if (isNext || isDone || isModalOpen) {
            onTap();
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
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
                        : const SizedBox
                            .shrink(), // Empty widget if the conditions aren't met
                  ),
                )),
            if (isNext) ...[
              Positioned(
                top: 0,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: startAbsoluteTopValue,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  child: Text(
                    AppLocalizations.of(context)!.cabsStart,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: startFontSize,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
