// start.dart
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'provider.dart';
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

  // Access the download manager
  final DownloadManager _downloadManager = DownloadManager();

  @override
  void initState() {
    super.initState();
    // Load saved preferences if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
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
    );

    setState(() {
      isStarting = false;
    });
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

                        // Download Checkbox
                        _buildDownloadCheckbox(
                          appLocalizations: appLocalizations,
                        ),
                        SizedBox(height: spacing),

                        // Start Video Button
                        _buildStartButton(
                          height: buttonHeight + 10,
                          width: buttonWidth,
                          isStarting: isStarting,
                          onTap: _startVideo,
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

  Widget _buildDownloadCheckbox({required AppLocalizations appLocalizations}) {
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
                color: const Color.fromRGBO(97, 184, 115, 1),
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  appLocalizations.downloadVideo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              // Checkbox for download option
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: shouldDownload,
                  activeColor: const Color.fromRGBO(97, 184, 115, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (bool? value) {
                    setState(() {
                      shouldDownload = value ?? false;
                    });
                  },
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
  }) {
    return Center(
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: 4,
          intensity: 0.8,
          lightSource: LightSource.topLeft,
          color: const Color.fromRGBO(97, 184, 115, 1),
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
                            shouldDownload
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
}
