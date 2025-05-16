// start.dart
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'payment_service.dart';
import 'provider.dart';
import 'services.dart';
import 'settings.dart';
import 'video.dart';
import 'offline.dart'; // Import the offline page
import 'downloadmanager.dart';

class StartPage extends StatefulWidget {
  final Function isLoggedIn;
  final Function(bool) setAuthenticated;
  final Function isAuthenticated;

  const StartPage({
    Key? key,
    required this.isLoggedIn,
    required this.setAuthenticated,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int selectedDuration = 300; // 5 minutes default
  int selectedFocus = 0;
  int selectedGoal = 0;
  int selectedIntensity = 1; // Medium as default
  bool isStarting = false;
  bool shouldDownload = false; // Added checkbox state for download option
  bool _canWatchVideo = true; // Track if user can watch video

  // Access the download manager
  final DownloadManager _downloadManager = DownloadManager();

  @override
  void initState() {
    super.initState();
    // Load saved preferences if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
      _checkVideoAvailability();

      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      if (profileProvider.payedSubscription != true) {
        final paymentService = PaymentService(profileProvider: profileProvider);
        paymentService.verifySubscription().then((_) {
          if (mounted) {
            setState(() {
              // This empty setState will force the UI to rebuild
            });
          }
        });
      }
    });
  }

  void _loadPreferences() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    // Load preferences from provider
    selectedDuration = profileProvider.duration ?? 300;
    selectedFocus = profileProvider.focus ?? 0;
    selectedGoal = profileProvider.goal ?? 0;
    selectedIntensity = profileProvider.intensity ?? 1;
  }

  // Check if user can watch more videos based on subscription or weekly limit
  void _checkVideoAvailability() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // If user has an active subscription, they can watch unlimited videos
    if (profileProvider.payedSubscription == true) {
      setState(() {
        _canWatchVideo = true;
      });
      return;
    }

    // For non-subscribers, check if they've already watched a video this week
    // Get current date info for week comparison
    final DateTime now = DateTime.now();
    final int currentWeek = getWeekNumber(now);
    final int currentYear = now.year;

    // Add a dedicated flag in SharedPreferences to track weekly viewing status
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int lastViewedWeek = prefs.getInt('lastViewedWeek') ?? 0;
    final int lastViewedYear = prefs.getInt('lastViewedYear') ?? 0;

    // Check if user has already watched a video in current week
    final bool hasWatchedVideoThisWeek =
        (currentWeek == lastViewedWeek && currentYear == lastViewedYear);

    setState(() {
      _canWatchVideo = !hasWatchedVideoThisWeek;
      // Reset download checkbox if they can't watch videos
      if (!_canWatchVideo) {
        shouldDownload = false;
      }
    });
  }

  // Helper method to get week number from a date
  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    return woy;
  }

  void _savePreferences() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    profileProvider.saveVideoPreferences(
      duration: selectedDuration,
      focus: selectedFocus,
      goal: selectedGoal,
      intensity: selectedIntensity,
    );
  }

  String _getFocusName(AppLocalizations localizations) {
    final focusOptions = [
      localizations.focusLowerBack,
      localizations.focusUpperBack,
      localizations.focusNeck,
      localizations.focusAll,
    ];

    if (selectedFocus >= 0 && selectedFocus < focusOptions.length) {
      return focusOptions[selectedFocus];
    }
    return localizations.focusAll;
  }

  String _getGoalName(AppLocalizations localizations) {
    final goalOptions = [
      localizations.goalMobility,
      localizations.goalStrength,
      localizations.goalRelaxation,
      localizations.goalPrevention,
    ];

    if (selectedGoal >= 0 && selectedGoal < goalOptions.length) {
      return goalOptions[selectedGoal];
    }
    return localizations.goalMobility;
  }

  void _startVideo() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // Check if user can watch more videos (has subscription or hasn't used weekly limit)
    if (!_canWatchVideo) {
      // Show subscription required dialog
      _showSubscriptionRequiredDialog();
      return;
    }

    setState(() {
      isStarting = true;
    });

    // Save preferences before starting
    _savePreferences();

    // If download option is selected, set download parameters and show dialog
    if (shouldDownload) {
      if (_downloadManager.isDownloading) {
        setState(() {
          isStarting = false;
        });
        _showDownloadInProgressDialog();
        return;
      }

      _downloadManager.setDownloadParameters(
        duration: selectedDuration,
        focus: selectedFocus,
        goal: selectedGoal,
        intensity: selectedIntensity,
        selectedVideos: [], // Set your selected videos if needed
      );

      // Show a dialog that the download has started
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              AppLocalizations.of(context)!.downloadingVideo,
              style: TextStyle(
                color: const Color.fromRGBO(97, 184, 115, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.downloadStarted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(
                    color: const Color.fromRGBO(97, 184, 115, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Start the download without navigating to offline page
      _downloadManager.startDownload(context);

      setState(() {
        isStarting = false;
        shouldDownload = false; // Reset download flag after initiating
      });
      return;
    }

    // If no download option, just start the streaming video
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VideoCombinerScreen(
              profileProvider: Provider.of<ProfileProvider>(
                context,
                listen: false,
              ),
              levelId: 1, // Set appropriate level ID
              focus: selectedFocus,
              goal: selectedGoal,
              duration: selectedDuration,
              useLocalVideo:
                  false, // Always stream by default in the start page
              sessionId: null,
              intensity: selectedIntensity,
            ),
      ),
    ).then((_) {
      // After returning from the video screen, check availability again
      _checkVideoAvailability();
    });

    setState(() {
      isStarting = false;
    });
  }

  void _showDownloadInProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            AppLocalizations.of(context)!.downloadInProgress ??
                "Download in Progress",
            style: TextStyle(
              color: const Color.fromRGBO(97, 184, 115, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.downloading_rounded,
                size: 48,
                color: const Color.fromRGBO(97, 184, 115, 0.8),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.downloadAlreadyRunning ??
                    "A download is already in progress. Please wait for it to complete before starting another download.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: TextStyle(
                  color: const Color.fromRGBO(97, 184, 115, 1),
                  fontWeight: FontWeight.bold,
                ),
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

  // Show dialog when subscription is required
  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.subscriptionRequiredTitle ??
                'Subscription Required',
            style: TextStyle(
              color: const Color.fromRGBO(97, 184, 115, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)?.subscriptionRequiredMessage ??
                'You have reached your weekly video limit. Subscribe to watch unlimited videos.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.subscribeNow ?? 'Subscribe Now',
                style: TextStyle(
                  color: const Color.fromRGBO(97, 184, 115, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to subscription page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionSettingPage(),
                  ),
                );
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.cancel ?? 'Cancel',
                style: TextStyle(color: Colors.grey),
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

  // Direct minute editor when clicking on the circle
  void showMinuteEditor() {
    int currentMinutes = selectedDuration ~/ 60;
    TextEditingController minuteController = TextEditingController(
      text: currentMinutes.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            AppLocalizations.of(context)!.chooseDuration,
            style: TextStyle(
              color: const Color.fromRGBO(97, 184, 115, 1),
              fontWeight: FontWeight.bold,
              fontSize: 18, // Smaller title font
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Reduced padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minuteController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: AppLocalizations.of(context)!.minutes,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ), // Reduced padding
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // Reduced from 10
                    borderSide: BorderSide(
                      color: const Color.fromRGBO(97, 184, 115, 1),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // Reduced from 10
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                style: TextStyle(
                  fontSize: 22, // Reduced from 24
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(97, 184, 115, 1),
                ),
              ),
              SizedBox(height: 8), // Reduced from 10
              Text(
                AppLocalizations.of(context)!.chooseMinutes ??
                    "Choose between 5-30 minutes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ), // Reduced from 14
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.cancel ?? 'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.confirm ?? 'Confirm',
                    style: TextStyle(
                      color: const Color.fromRGBO(97, 184, 115, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // Parse input value
                    int newMinutes;
                    try {
                      newMinutes = int.parse(minuteController.text);
                      // Apply constraints: 5-30 minutes
                      if (newMinutes < 5) newMinutes = 5;
                      if (newMinutes > 30) newMinutes = 30;
                      setState(() {
                        selectedDuration = newMinutes * 60;
                      });
                    } catch (e) {
                      // If parsing fails, keep current value
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showOptionDialogFocus(
    List<String> options,
    String title,
    void Function(int) onSelected,
  ) async {
    int? selection = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.asMap().entries.map((entry) {
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
    List<String> options,
    String title,
    void Function(int) onSelected,
  ) async {
    int? selection = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.asMap().entries.map((entry) {
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

  void showIntensityDialog() async {
    final intensityOptions = [
      AppLocalizations.of(context)!.intensityLow,
      AppLocalizations.of(context)!.intensityMedium,
      AppLocalizations.of(context)!.intensityHigh,
    ];

    int? selection = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
          title: Text(
            AppLocalizations.of(context)!.chooseIntensity,
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  intensityOptions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    return RadioListTile<int>(
                      activeColor: Colors.white,
                      title: Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: index,
                      groupValue: selectedIntensity,
                      onChanged: (int? value) {
                        if (value != null) {
                          Navigator.of(context).pop(value);
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
        selectedIntensity = selection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final appLocalizations = AppLocalizations.of(context)!;

    // Get subscription status from provider
    final profileProvider = Provider.of<ProfileProvider>(context);
    final bool isSubscribed = profileProvider.payedSubscription == true;

    // Define focus area options
    final focusOptions = [
      appLocalizations.focusLowerBack,
      appLocalizations.focusUpperBack,
      appLocalizations.focusNeck,
      appLocalizations.focusAll,
    ];

    // Define goal options
    final goalOptions = [
      appLocalizations.goalMobility,
      appLocalizations.goalStrength,
      appLocalizations.goalRelaxation,
      appLocalizations.goalPrevention,
    ];

    // Convert duration from seconds to minutes for display
    final durationMinutes = selectedDuration ~/ 60;

    return Stack(
      children: <Widget>[
        // Background image
        Image.asset(
          "assets/settingsbg.PNG",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image fails to load
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout calculations
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                final isTablet = maxWidth >= 600;

                // Adjust sizing based on screen dimensions
                final circleSize =
                    maxWidth * 0.40 > 180 ? 180.0 : maxWidth * 0.40;
                final innerCircleSize = circleSize * 0.9;
                final contentPadding = isTablet ? 24.0 : 16.0;
                final buttonSpacing = isTablet ? 16.0 : 10.0;

                return Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      width: maxWidth,
                      height: maxHeight,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(contentPadding),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Title
                                    Text(
                                      appLocalizations.configureVideo,
                                      style: TextStyle(
                                        fontSize: isTablet ? 24 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: isTablet ? 90.0 : 100.0),

                                    // Duration Circle - Simplified with direct tap
                                    Center(
                                      child: GestureDetector(
                                        onTap: showMinuteEditor,
                                        child: Container(
                                          width: circleSize,
                                          height: circleSize,
                                          margin: EdgeInsets.symmetric(
                                            vertical: buttonSpacing,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Inner colored circle
                                              Container(
                                                width: innerCircleSize,
                                                height: innerCircleSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color.fromRGBO(
                                                    97,
                                                    184,
                                                    115,
                                                    0.1,
                                                  ),
                                                  border: Border.all(
                                                    color: const Color.fromRGBO(
                                                      97,
                                                      184,
                                                      115,
                                                      0.2,
                                                    ),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              // Time display
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    durationMinutes.toString(),
                                                    style: TextStyle(
                                                      fontSize:
                                                          circleSize * 0.25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          const Color.fromRGBO(
                                                            97,
                                                            184,
                                                            115,
                                                            1,
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                    appLocalizations.minutes,
                                                    style: TextStyle(
                                                      fontSize:
                                                          circleSize * 0.08,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: buttonSpacing),

                                    // Options wrapped with FittedBox
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        width: maxWidth * 0.9,
                                        child: Column(
                                          children: [
                                            // Focus Area Button
                                            _buildCardButton(
                                              icon: Icons.flag,
                                              title: appLocalizations.focusArea,
                                              value:
                                                  focusOptions[selectedFocus],
                                              onTap:
                                                  () => showOptionDialogFocus(
                                                    focusOptions,
                                                    appLocalizations
                                                        .chooseFocusArea,
                                                    (index) => setState(
                                                      () =>
                                                          selectedFocus = index,
                                                    ),
                                                  ),
                                            ),
                                            SizedBox(height: buttonSpacing),

                                            // Goal Button
                                            _buildCardButton(
                                              icon: Icons.track_changes,
                                              title: appLocalizations.goal,
                                              value: goalOptions[selectedGoal],
                                              onTap:
                                                  () => showOptionDialogGoal(
                                                    goalOptions,
                                                    appLocalizations.chooseGoal,
                                                    (index) => setState(
                                                      () =>
                                                          selectedGoal = index,
                                                    ),
                                                  ),
                                            ),
                                            SizedBox(height: buttonSpacing),

                                            // Intensity Button
                                            _buildCardButton(
                                              icon: Icons.fitness_center,
                                              title: appLocalizations.intensity,
                                              value:
                                                  selectedIntensity == 0
                                                      ? appLocalizations
                                                          .intensityLow
                                                      : selectedIntensity == 1
                                                      ? appLocalizations
                                                          .intensityMedium
                                                      : appLocalizations
                                                          .intensityHigh,
                                              onTap: showIntensityDialog,
                                            ),
                                            SizedBox(height: buttonSpacing),

                                            // Download Checkbox
                                            _buildDownloadCheckbox(
                                              appLocalizations:
                                                  appLocalizations,
                                              isEnabled: isSubscribed,
                                            ),
                                            SizedBox(height: buttonSpacing),

                                            // Start Video Button
                                            _buildStartButton(
                                              isStarting: isStarting,
                                              onTap: _startVideo,
                                              appLocalizations:
                                                  appLocalizations,
                                              canWatch: _canWatchVideo,
                                            ),

                                            // Subscription Status Indicator
                                            SizedBox(height: buttonSpacing),
                                            _buildStatusIndicator(
                                              isSubscribed: isSubscribed,
                                              canWatch: _canWatchVideo,
                                              appLocalizations:
                                                  appLocalizations,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(8), // Further reduced radius
        ),
        depth: 2, // Further reduced depth
        intensity: 0.5, // Further reduced intensity
        lightSource: LightSource.topLeft,
        color: Colors.grey[100],
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8, // Further reduced vertical padding
          ),
          child: Row(
            children: [
              Container(
                width: 28, // Further reduced width
                height: 28, // Further reduced height
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(97, 184, 115, 0.1),
                  borderRadius: BorderRadius.circular(
                    6,
                  ), // Further reduced radius
                ),
                child: Icon(
                  icon,
                  color: const Color.fromRGBO(97, 184, 115, 1),
                  size: 16, // Further reduced size
                ),
              ),
              SizedBox(width: 8), // Further reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Add this to minimize height
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11, // Further reduced font size
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 1), // Further reduced spacing
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13, // Further reduced font size
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 18, // Further reduced size
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadCheckbox({
    required AppLocalizations appLocalizations,
    required bool isEnabled,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(8), // Further reduced radius
        ),
        depth: 2, // Further reduced depth
        intensity: 0.5, // Further reduced intensity
        lightSource: LightSource.topLeft,
        color: Colors.grey[100],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8, // Further reduced vertical padding
        ),
        child: Row(
          children: [
            Container(
              width: 28, // Further reduced width
              height: 28, // Further reduced height
              decoration: BoxDecoration(
                color:
                    isEnabled
                        ? const Color.fromRGBO(97, 184, 115, 0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  6,
                ), // Further reduced radius
              ),
              child: Icon(
                Icons.download,
                color:
                    isEnabled
                        ? const Color.fromRGBO(97, 184, 115, 1)
                        : Colors.grey[400],
                size: 16, // Further reduced size
              ),
            ),
            SizedBox(width: 8), // Further reduced spacing
            Expanded(
              child: Text(
                appLocalizations.downloadVideo,
                style: TextStyle(
                  fontSize: 13, // Further reduced font size
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.grey[800] : Colors.grey[400],
                ),
              ),
            ),
            GestureDetector(
              onTap:
                  isEnabled
                      ? () {
                        setState(() {
                          shouldDownload = !shouldDownload;
                        });
                      }
                      : null,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 18, // Further reduced width
                height: 18, // Further reduced height
                decoration: BoxDecoration(
                  color:
                      shouldDownload && isEnabled
                          ? const Color.fromRGBO(97, 184, 115, 1)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // Further reduced radius
                  border: Border.all(
                    color:
                        isEnabled
                            ? const Color.fromRGBO(97, 184, 115, 1)
                            : Colors.grey[300]!,
                    width: 1, // Further reduced width
                  ),
                  boxShadow:
                      shouldDownload && isEnabled
                          ? [
                            BoxShadow(
                              color: const Color.fromRGBO(97, 184, 115, 0.3),
                              blurRadius: 2, // Further reduced blur
                              offset: Offset(0, 1),
                            ),
                          ]
                          : [],
                ),
                child:
                    shouldDownload && isEnabled
                        ? Center(
                          child: Icon(
                            Icons.check,
                            size: 12, // Further reduced size
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton({
    required bool isStarting,
    required VoidCallback onTap,
    required AppLocalizations appLocalizations,
    required bool canWatch,
  }) {
    final bool isSubscribed =
        Provider.of<ProfileProvider>(context, listen: true).payedSubscription ==
        true;
    final bool buttonEnabled = canWatch || isSubscribed;
    final Color buttonColor =
        buttonEnabled
            ? const Color.fromRGBO(97, 184, 115, 1)
            : Colors.grey[400]!;

    return GestureDetector(
      onTap: buttonEnabled && !isStarting ? onTap : null,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(8), // Further reduced radius
          ),
          depth: buttonEnabled ? 4 : 1, // Further reduced depth
          intensity: 0.6, // Further reduced intensity
          lightSource: LightSource.topLeft,
          color: buttonColor,
        ),
        child: Container(
          height: 44, // Further reduced height
          child: Center(
            child:
                isStarting
                    ? SizedBox(
                      height: 22, // Smaller progress indicator
                      width: 22,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5, // Further reduced stroke width
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28, // Further reduced width
                          height: 28, // Further reduced height
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              6,
                            ), // Further reduced radius
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 18, // Further reduced size
                          ),
                        ),
                        SizedBox(width: 8), // Further reduced spacing
                        Text(
                          shouldDownload && isSubscribed
                              ? '${appLocalizations.startVideo} & ${appLocalizations.downloadVideo}'
                              : appLocalizations.startVideo,
                          style: TextStyle(
                            fontSize: 14, // Further reduced font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  // Modify the _buildStatusIndicator method
  Widget _buildStatusIndicator({
    required bool isSubscribed,
    required bool canWatch,
    required AppLocalizations appLocalizations,
  }) {
    final String statusText =
        isSubscribed
            ? appLocalizations.subscribedStatus ??
                'Subscribed: Unlimited Access'
            : canWatch
            ? appLocalizations.freeUserCanWatch ??
                'Free User: 1 video available this week'
            : appLocalizations.freeUserLimit ??
                'Free User: Weekly limit reached';

    final Color statusColor =
        isSubscribed
            ? const Color.fromRGBO(97, 184, 115, 1)
            : canWatch
            ? Colors.orange
            : Colors.red;

    final IconData statusIcon =
        isSubscribed
            ? Icons.verified
            : canWatch
            ? Icons.timer
            : Icons.block;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6), // Reduced from 8
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ), // Reduced from 12,16
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10), // Reduced from 12
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, // Reduced from 32
            height: 28, // Reduced from 32
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6), // Reduced from 8
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 16,
            ), // Reduced from 18
          ),
          SizedBox(width: 10), // Reduced from 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Reduced from 14
                  ),
                ),
                if (!isSubscribed)
                  Padding(
                    padding: EdgeInsets.only(top: 2), // Reduced from 4
                    child: Text(
                      appLocalizations.upgradeForUnlimited ??
                          'Upgrade for unlimited videos',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ), // Reduced from 12
                    ),
                  ),
              ],
            ),
          ),
          if (!isSubscribed)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: statusColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // Reduced from 8
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ), // Reduced from 12,8
                minimumSize: Size(60, 28), // Add minimum size
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionSettingPage(),
                  ),
                );
              },
              child: Text(
                appLocalizations.upgradeNow ?? 'Upgrade',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ), // Reduced from 12
              ),
            ),
        ],
      ),
    );
  }
}
