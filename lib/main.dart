import 'dart:async';

import 'package:backquest/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get_it/get_it.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'offline.dart';
import 'payment_service.dart';
import 'provider.dart';
import 'services.dart';
import 'start.dart';
import 'auth.dart';
import 'firebase_options.dart';
import 'localization_service.dart';
import 'downloadmanager.dart';
import 'exercise.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register LocalizationService FIRST before any Firebase initialization
  final getIt = GetIt.instance;
  getIt.registerSingleton<LocalizationService>(LocalizationService());

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //await FirebaseService.initialize();
    print("Firebase successfully initialized");
  } catch (e) {
    print("Firebase initialization failed: $e");
    // Continue without Firebase
  }

  await BackgroundService.initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.grey,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
          ),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // Using a try-catch to prevent crashes during initialization
        try {
          // Initialize LocalizationService after MaterialApp is built
          final appLocalizations = AppLocalizations.of(context);
          if (appLocalizations != null) {
            GetIt.I<LocalizationService>().initialize(appLocalizations);
          } else {
            print("AppLocalizations is null, unable to initialize.");
          }
          return child!;
        } catch (e) {
          print("Error during app initialization: $e");
          // Return a fallback UI that won't crash
          return Material(
            child: Center(
              child: Text(
                "App initialization error. Please restart the app.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      },
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isModalVisible = false;
  String modalDescription = "Declaring Description";
  int level = 0;
  bool isVideoPlayer = true;

  bool? _authenticated;
  bool? _loggedIn;
  final AuthService _authService = AuthService();
  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;
  bool _showConnectionMessage = true;
  bool _showAuthenticateMessage = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();

    // Load local data first, then try to sync with server
    _loadDataAndSync();

    WidgetsBinding.instance.addObserver(this);

    // Initialize connectivity
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      _updateConnectionStatus(result);
    });
    _checkInitialConnectivity();

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        //FirebaseService.checkAndProcessPendingNotifications(context);
      }
    });
  }

  Future<void> _loadDataAndSync() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // First load local data
    print("Loading local preferences and levels...");
    await profileProvider.loadPreferences();

    // Initialize payment service
    final paymentService = PaymentService(profileProvider: profileProvider);
    await paymentService.initialize();

    // Then try to sync with server if we're connected
    print("Checking for auth token to sync with server...");
    try {
      String? token = await getAuthToken();
      if (token != null) {
        print("Auth token found, attempting server sync");
        bool syncSuccess = await profileProvider.syncProfile(token);
        if (syncSuccess) {
          print("Server sync successful");
        } else {
          print("Server sync failed, using local data only");
        }
      } else {
        print("No auth token available, using local data only");
      }
    } catch (e) {
      print("Error during server sync attempt: $e");
    }
  }

  void triggerAnimation() {
    print("placeholder");
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
      Provider.of<ProfileProvider>(context, listen: false).loadPreferences();
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
        fontSize: largeTextSize,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: normalTextSize,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: baseTextStyle.copyWith(
        fontSize: smallTextSize,
        fontWeight: FontWeight.bold,
      ),
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

    try {
      if (!mounted) {
        print("Widget not mounted, skipping authentication check");
        return;
      }
      bool isGuest = await _authService.isGuestToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => true, // Assume guest if timeout
      );

      bool tokenExpired = await _authService.isTokenExpired().timeout(
        const Duration(seconds: 5),
        onTimeout: () => true, // Assume expired if timeout
      );

      if (!isGuest) {
        setState(() {
          _setAuthenticated(true);
          print("isLoggedIn");
        });
        if (tokenExpired) {
          setState(() {
            _setAuthenticated(false);
            print("tokenExpired");
          });
        }
      } else {
        // Try to set guest token with timeout
        await _authService.setGuestToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // Continue with offline mode if timeout
            print("Guest token request timed out");
          },
        );
        setState(() {
          _setAuthenticated(false);
          print("guestTokenSet");
        });
      }
    } catch (e) {
      print('Error in authentication check: $e');
      // Continue with offline mode if any error occurs
      setState(() {
        _setAuthenticated(false);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _setAuthenticated(bool authenticated) {
    setState(() => _authenticated = authenticated);
    _setLoggedIn(authenticated);
    _showAuthenticateMessage = !authenticated;
  }

  void _setLoggedIn(bool loggedIn) {
    setState(() {
      print("########");
      print(loggedIn);
      _loggedIn = loggedIn;
    });
  }

  bool isLoggedIn() {
    return _loggedIn ?? false;
  }

  bool isAuthenticated() {
    return _authenticated ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final downloadManager = DownloadManager();

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              Center(
                child: StartPage(
                  isLoggedIn: isLoggedIn,
                  setAuthenticated: _setAuthenticated,
                  isAuthenticated: isAuthenticated,
                ),
              ),
              Center(child: ExercisesPage()),
              Center(child: OfflinePage()),
              Center(
                child: SettingsPage(
                  setAuthenticated: _setAuthenticated,
                  isAuthenticated: isAuthenticated,
                ),
              ),
              /* SettingsPage(
                setAuthenticated: _setAuthenticated,
                isLoggedIn: isLoggedIn,
              ), */
            ],
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Download progress indicator above bottom navigation bar
          StreamBuilder<Map<String, dynamic>>(
            stream: downloadManager.downloadInfoStream,
            builder: (context, snapshot) {
              final downloadInfo = snapshot.data;
              final isDownloading = downloadInfo?['isDownloading'] ?? false;
              final progress = downloadInfo?['progress'] ?? 0.0;

              if (!isDownloading) {
                return SizedBox.shrink();
              }

              return Container(
                height: 3,
                width: double.infinity,
                color: Colors.grey[200],
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    color: const Color.fromRGBO(97, 184, 115, 1),
                  ),
                ),
              );
            },
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  // Replace the StreamBuilder code in _buildBottomNavigationBar with this:

  Widget _buildBottomNavigationBar() {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final downloadManager = DownloadManager();

    return SalomonBottomBar(
      backgroundColor: Colors.grey[200],
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() {
          _currentIndex = i;
          _pageController.jumpToPage(i);
        });
      },
      items: [
        _buildBottomBarItem(
          icon: Icons.directions_run,
          title: AppLocalizations.of(context)!.menu1,
          isTablet: isTablet,
        ),
        _buildBottomBarItem(
          icon: Icons.menu_book,
          title: AppLocalizations.of(context)!.menu2,
          isTablet: isTablet,
        ),
        // Save icon with download indicator badge
        _buildDownloadIndicatorItem(
          downloadManager: downloadManager,
          isTablet: isTablet,
        ),
        _buildBottomBarItem(
          icon: Icons.settings,
          title: AppLocalizations.of(context)!.menu4,
          isTablet: isTablet,
        ),
      ],
    );
  }

  // Add this new method to handle the download indicator item
  // Replace the _buildDownloadIndicatorItem method in main.dart with this:

  SalomonBottomBarItem _buildDownloadIndicatorItem({
    required DownloadManager downloadManager,
    required bool isTablet,
  }) {
    // Fixed width like other items
    double fixedWidth = (MediaQuery.of(context).size.width / 5 - 10) * 0.6;

    return SalomonBottomBarItem(
      icon: StreamBuilder<Map<String, dynamic>>(
        stream: downloadManager.downloadInfoStream,
        builder: (context, snapshot) {
          final isDownloading = snapshot.data?['isDownloading'] ?? false;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              NeumorphicIcon(
                Icons.save,
                size: isTablet ? 55 : 32,
                style: NeumorphicStyle(depth: 2, color: Colors.grey.shade400),
              ),
              if (isDownloading)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(97, 184, 115, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '↓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      title: Container(
        width: fixedWidth,
        child: Text(
          AppLocalizations.of(context)!.menu3,
          style: TextStyle(
            fontSize: isTablet ? 17 : MediaQuery.of(context).size.width * 0.030,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      selectedColor: Colors.blueGrey[700],
    );
  }

  SalomonBottomBarItem _buildBottomBarItem({
    required IconData icon,
    required String title,
    required bool isTablet,
  }) {
    // Calculate a smaller fixed width (60% of previous suggestion)
    double fixedWidth = (MediaQuery.of(context).size.width / 5 - 10) * 0.6;

    return SalomonBottomBarItem(
      icon: NeumorphicIcon(
        icon,
        size: isTablet ? 55 : 32, // Reduce icon size on tablets
        style: NeumorphicStyle(depth: 2, color: Colors.grey.shade400),
      ),
      title: Container(
        width: fixedWidth, // Apply fixed width constraint
        child: Text(
          title,
          style: TextStyle(
            fontSize:
                isTablet
                    ? 17
                    : MediaQuery.of(context).size.width *
                        0.030, // Reduce font size on tablets
          ),
          overflow: TextOverflow.ellipsis, // Adds "..." when text is too long
          maxLines: 1, // Ensures the text stays on a single line
        ),
      ),
      selectedColor: Colors.blueGrey[700],
    );
  }
}
