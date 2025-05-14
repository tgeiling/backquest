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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color.fromRGBO(97, 184, 115, 1),
                  ),
                ),
                SizedBox(height: 20),
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
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final buttonHeight = isTablet ? 70.0 : 60.0;
    final buttonWidth = isTablet ? size.width * 0.8 : size.width * 0.85;
    final spacing = isTablet ? 24.0 : 16.0;

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        SizedBox(height: spacing * 2),

                        // Duration Button
                        _buildConfigButton(
                          title: appLocalizations.duration,
                          value: appLocalizations.durationTextTwo(
                            durationMinutes,
                          ),
                          icon: Icons.timer,
                          onTap: showDurationDialog,
                          height: buttonHeight,
                          width: buttonWidth,
                        ),
                        SizedBox(height: spacing),

                        // Focus Area Button
                        _buildConfigButton(
                          title: appLocalizations.focusArea,
                          value: focusOptions[selectedFocus],
                          icon: Icons.flag,
                          onTap:
                              () => showOptionDialogFocus(
                                focusOptions,
                                appLocalizations.chooseFocusArea,
                                (index) =>
                                    setState(() => selectedFocus = index),
                              ),
                          height: buttonHeight,
                          width: buttonWidth,
                        ),
                        SizedBox(height: spacing),

                        // Goal Button
                        _buildConfigButton(
                          title: appLocalizations.goal,
                          value: goalOptions[selectedGoal],
                          icon: Icons.track_changes,
                          onTap:
                              () => showOptionDialogGoal(
                                goalOptions,
                                appLocalizations.chooseGoal,
                                (index) => setState(() => selectedGoal = index),
                              ),
                          height: buttonHeight,
                          width: buttonWidth,
                        ),
                        SizedBox(height: spacing),

                        // Intensity Button
                        _buildConfigButton(
                          title: appLocalizations.intensity,
                          value:
                              selectedIntensity == 0
                                  ? appLocalizations.intensityLow
                                  : selectedIntensity == 1
                                  ? appLocalizations.intensityMedium
                                  : appLocalizations.intensityHigh,
                          icon: Icons.fitness_center,
                          onTap: showIntensityDialog,
                          height: buttonHeight,
                          width: buttonWidth,
                        ),
                        SizedBox(height: spacing),

                        // Download Checkbox - Disabled for non-subscribers
                        _buildDownloadCheckbox(
                          appLocalizations: appLocalizations,
                          isEnabled: isSubscribed,
                        ),
                        SizedBox(height: spacing),

                        // Start Video Button
                        _buildStartButton(
                          height: buttonHeight + 10,
                          width: buttonWidth,
                          isStarting: isStarting,
                          onTap: _startVideo,
                          appLocalizations: appLocalizations,
                          canWatch: _canWatchVideo,
                        ),

                        // Subscription Status or Weekly Limit Indicator
                        SizedBox(height: spacing),
                        _buildStatusIndicator(
                          isSubscribed: isSubscribed,
                          canWatch: _canWatchVideo,
                          appLocalizations: appLocalizations,
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
  }

  Widget _buildConfigButton({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required double height,
    required double width,
  }) {
    return Center(
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: 4,
          intensity: 0.7,
          lightSource: LightSource.topLeft,
          color: Colors.grey[100],
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color.fromRGBO(97, 184, 115, 1),
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadCheckbox({
    required AppLocalizations appLocalizations,
    required bool isEnabled,
  }) {
    return Center(
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: 4,
          intensity: 0.7,
          lightSource: LightSource.topLeft,
          color: Colors.grey[100],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.download,
                color:
                    isEnabled
                        ? const Color.fromRGBO(97, 184, 115, 1)
                        : Colors.grey[400],
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  appLocalizations.downloadVideo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? Colors.grey[800] : Colors.grey[400],
                  ),
                ),
              ),
              // Checkbox for download option - disabled for non-subscribers
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isEnabled ? shouldDownload : false,
                  activeColor: const Color.fromRGBO(97, 184, 115, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged:
                      isEnabled
                          ? (bool? value) {
                            setState(() {
                              shouldDownload = value ?? false;
                            });
                          }
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton({
    required double height,
    required double width,
    required bool isStarting,
    required VoidCallback onTap,
    required AppLocalizations appLocalizations,
    required bool canWatch,
  }) {
    // Get subscription info
    final bool isSubscribed =
        Provider.of<ProfileProvider>(context).payedSubscription == true;
    final Color buttonColor =
        canWatch ? const Color.fromRGBO(97, 184, 115, 1) : Colors.grey[400]!;

    return Center(
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: 4,
          intensity: 0.8,
          lightSource: LightSource.topLeft,
          color: buttonColor,
        ),
        child: InkWell(
          onTap: isStarting ? null : onTap,
          child: Container(
            height: height,
            width: width,
            child: Center(
              child:
                  isStarting
                      ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            shouldDownload && isSubscribed
                                ? '${appLocalizations.startVideo} & ${appLocalizations.downloadVideo}'
                                : appLocalizations.startVideo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  // New widget to show subscription status or weekly limit indicator
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

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            SizedBox(width: 8),
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            if (!isSubscribed) ...[
              SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Navigate to subscription page
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
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
