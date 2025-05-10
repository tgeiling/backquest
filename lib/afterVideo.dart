import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

import 'services.dart';
import 'provider.dart';
import 'elements.dart';
import 'localization_service.dart';

class ExerciseFeedback {
  final String videoId;
  int? difficulty;
  List<int> painAreas;

  ExerciseFeedback({
    required this.videoId,
    this.difficulty,
    this.painAreas = const [],
  });

  factory ExerciseFeedback.fromJson(Map<String, dynamic> json) {
    return ExerciseFeedback(
      videoId: json['videoId'],
      difficulty: json['difficulty'],
      painAreas: List<int>.from(json['painAreas'] ?? []),
    );
  }

  void update({int? newDifficulty, List<int>? newPainAreas}) {
    if (newDifficulty != null) {
      difficulty = newDifficulty;
    }
    if (newPainAreas != null && newPainAreas.isNotEmpty) {
      painAreas = newPainAreas;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'difficulty': difficulty,
      'painAreas': painAreas,
    };
  }
}

class AfterVideoView extends StatefulWidget {
  final List<String> videoIds;

  const AfterVideoView({Key? key, required this.videoIds}) : super(key: key);

  @override
  _AfterVideoViewState createState() => _AfterVideoViewState();
}

class _AfterVideoViewState extends State<AfterVideoView> {
  final PageController _pageController = PageController();

  List<String> get filteredVideoIds {
    return widget.videoIds
        .where((id) => id.compareTo("0133") < 0 || id.compareTo("0139") > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          FirstPage(
            onPressedWeiter:
                () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
          ),
          SecondPage(videoIds: filteredVideoIds),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  final VoidCallback onPressedWeiter;

  const FirstPage({super.key, required this.onPressedWeiter});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double bigHeaderFontSize;

    if (isSmallScreen) {
      bigHeaderFontSize = 22;
    } else {
      bigHeaderFontSize = 40;
    }

    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 70,
                  child: Text(
                    AppLocalizations.of(context)!.feedbackIntroduction,
                    style: TextStyle(
                      fontSize: bigHeaderFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18.0),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 70,
                  child: Text(
                    AppLocalizations.of(context)!.feedbackDetails,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: PressableButton(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 17,
                  ),
                  onPressed: onPressedWeiter,
                  child: Text(
                    AppLocalizations.of(context)!.letsGo,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: PressableButton(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  color: Colors.grey.shade100,
                  shadowColor: Colors.grey.shade300,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.skip,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(color: Colors.grey),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final List<String> videoIds;

  const SecondPage({Key? key, required this.videoIds}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<ExerciseFeedback> feedbackList = [];

  void _handleFeedbackUpdated(ExerciseFeedback feedback) {
    setState(() {
      int index = feedbackList.indexWhere((f) => f.videoId == feedback.videoId);
      if (index != -1) {
        feedbackList[index].update(
          newDifficulty: feedback.difficulty,
          newPainAreas: feedback.painAreas,
        );
      } else {
        feedbackList.add(feedback);
      }
    });
  }

  Future<void> _sendFeedback() async {
    final feedbackData = feedbackList.map((f) => f.toJson()).toList();

    const String url = 'http://34.116.240.55:3000/feedback';
    final token = await getAuthToken();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'feedback': feedbackData}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.feedbackSuccess),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.feedbackFailure),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.feedbackError}: $e'),
        ),
      );
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromRGBO(97, 184, 115, 0.9)),
      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.videoIds.length,
                itemBuilder:
                    (context, index) => ExerciseFeedbackTile(
                      index: index,
                      videoId: widget.videoIds[index],
                      onFeedbackUpdated: _handleFeedbackUpdated,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 36,
                top: 16,
              ),
              child: PressableButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 28,
                ),
                onPressed: _sendFeedback,
                child: Text(
                  AppLocalizations.of(context)!.finish,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseFeedbackTile extends StatefulWidget {
  final String videoId;
  final int index;
  final Function(ExerciseFeedback) onFeedbackUpdated;

  const ExerciseFeedbackTile({
    Key? key,
    required this.index,
    required this.videoId,
    required this.onFeedbackUpdated,
  }) : super(key: key);

  @override
  _ExerciseFeedbackTileState createState() => _ExerciseFeedbackTileState();
}

class _ExerciseFeedbackTileState extends State<ExerciseFeedbackTile> {
  int? selectedDifficulty;
  List<int> selectedPainAreas = [];

  @override
  Widget build(BuildContext context) {
    double baseSize = MediaQuery.of(context).size.width * 0.1;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double wrapSpacing;
    double wrapItemVerticalPadding;
    double wrapItemHorizontalPadding;
    double thumbnailDimensions;

    if (isSmallScreen) {
      wrapSpacing = 0;
      wrapItemVerticalPadding = 1;
      wrapItemHorizontalPadding = 2;
      thumbnailDimensions = 70;
    } else {
      wrapSpacing = 8;
      wrapItemVerticalPadding = 2;
      wrapItemHorizontalPadding = 4;
      thumbnailDimensions = 80;
    }

    return Card(
      color: Colors.grey.shade500.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Container(
              height: thumbnailDimensions,
              width: thumbnailDimensions,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  "assets/thumbnails/${widget.videoId}.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.exercise} ${widget.index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flash_on),
                          onPressed: _showPainLocationDialog,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: wrapSpacing,
                      children:
                          [
                                AppLocalizations.of(context)!.difficultyEasy,
                                AppLocalizations.of(context)!.difficultyMedium,
                                AppLocalizations.of(context)!.difficultyHard,
                              ]
                              .asMap()
                              .entries
                              .map(
                                (entry) => ChoiceChip(
                                  backgroundColor: Colors.grey.shade700,
                                  checkmarkColor: Colors.white,
                                  selectedColor: Colors.green,
                                  label: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: baseSize * 0.3,
                                    ),
                                  ),
                                  labelPadding: EdgeInsets.symmetric(
                                    vertical: wrapItemVerticalPadding,
                                    horizontal: wrapItemHorizontalPadding,
                                  ),
                                  selected: selectedDifficulty == entry.key,
                                  onSelected: (bool selected) {
                                    setState(
                                      () =>
                                          selectedDifficulty =
                                              selected ? entry.key : null,
                                    );
                                    _updateFeedback();
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFeedback() {
    final feedback = ExerciseFeedback(
      videoId: widget.videoId,
      difficulty: selectedDifficulty,
      painAreas: selectedPainAreas,
    );
    widget.onFeedbackUpdated(feedback);
  }

  void _showPainLocationDialog() {
    List<int> tempSelectedPainAreas = List.from(selectedPainAreas);

    final Map<int, String> painAreaTranslations = {
      0: AppLocalizations.of(context)!.lowerBack,
      1: AppLocalizations.of(context)!.upperBack,
      2: AppLocalizations.of(context)!.neck,
      3: AppLocalizations.of(context)!.knee,
      4: AppLocalizations.of(context)!.wrists,
      5: AppLocalizations.of(context)!.feet,
      6: AppLocalizations.of(context)!.ankle,
      7: AppLocalizations.of(context)!.hip,
      8: AppLocalizations.of(context)!.jaw,
      9: AppLocalizations.of(context)!.shoulder,
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: Colors.green.shade800),
              ),
              child: AlertDialog(
                backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
                title: Text(AppLocalizations.of(context)!.selectPainAreasTitle),
                content: SingleChildScrollView(
                  child: Wrap(
                    spacing: 5.0,
                    children:
                        painAreaTranslations.entries
                            .map(
                              (entry) => FilterChip(
                                selectedColor: Colors.green.shade300,
                                backgroundColor: Colors.grey.shade600,
                                label: Text(entry.value),
                                selected: tempSelectedPainAreas.contains(
                                  entry.key,
                                ),
                                onSelected: (bool selected) {
                                  setDialogState(() {
                                    if (selected) {
                                      tempSelectedPainAreas.add(entry.key);
                                    } else {
                                      tempSelectedPainAreas.remove(entry.key);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedPainAreas = tempSelectedPainAreas;
                        _updateFeedback();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
