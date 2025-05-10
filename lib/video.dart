import 'dart:convert';
import 'dart:io';

import 'localization_service.dart';
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

import 'services.dart';
import 'provider.dart';
import 'afterVideo.dart';

List<String> selectedVideos = [];

class VideoCombinerScreen extends StatefulWidget {
  final ProfileProvider profileProvider;
  final int levelId;
  final int focus;
  final int goal;
  final int duration;
  final bool useLocalVideo;
  final String? sessionId;
  final int intensity;
  final String? localVideoPath; // Add path to local video

  const VideoCombinerScreen({
    super.key,
    required this.profileProvider,
    required this.levelId,
    required this.focus,
    required this.goal,
    this.duration = 600,
    this.useLocalVideo = false,
    this.sessionId,
    this.intensity = 1,
    this.localVideoPath,
  });

  @override
  _VideoCombinerScreenState createState() => _VideoCombinerScreenState();
}

class _VideoCombinerScreenState extends State<VideoCombinerScreen> {
  bool _isLoading = false;
  bool hasBeenUpdated = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.useLocalVideo) {
      _initializeLocalVideo();
    } else {
      _startVideoCombining();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    hasBeenUpdated = false;
    super.dispose();
  }

  Future<void> _initializeLocalVideo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String videoPath;

      if (widget.localVideoPath != null) {
        // Use the provided specific video path
        videoPath = widget.localVideoPath!;
      } else {
        // Try to find a video in the app's document directory
        final directory = await getApplicationDocumentsDirectory();

        // Load metadata to find the latest video
        final metadataFile = File('${directory.path}/video_metadata.json');
        if (metadataFile.existsSync()) {
          final jsonString = await metadataFile.readAsString();
          final List<dynamic> metadata = json.decode(jsonString);

          if (metadata.isNotEmpty) {
            // Sort by date (newest first)
            metadata.sort(
              (a, b) => DateTime.parse(
                b['savedDate'],
              ).compareTo(DateTime.parse(a['savedDate'])),
            );

            // Use the most recent video
            videoPath = metadata.first['filePath'];
            selectedVideos = List<String>.from(metadata.first['videoIds']);
          } else {
            throw Exception('No saved videos found');
          }
        } else {
          throw Exception('No saved videos found');
        }
      }

      if (File(videoPath).existsSync()) {
        _videoPlayerController = VideoPlayerController.file(File(videoPath));
        await _videoPlayerController!.initialize();

        _createChewieController();

        setState(() {
          _isLoading = false;
        });

        _videoPlayerController!.addListener(videoProgressListener);
      } else {
        // If file doesn't exist, fall back to streaming
        _startVideoCombining();
      }
    } catch (e) {
      print('Error initializing local video: $e');
      // Fall back to streaming if there's an error
      _startVideoCombining();
    }
  }

  Future<void> _startVideoCombining() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // If we already have a session ID, use it directly
      if (widget.sessionId != null) {
        final String outputVideoUrl =
            'http://34.116.240.55:3000/video?sessionId=${widget.sessionId}';

        _videoPlayerController = VideoPlayerController.network(outputVideoUrl);
        await _videoPlayerController!.initialize();

        _createChewieController();

        setState(() {
          _isLoading = false;
        });

        _videoPlayerController!.addListener(videoProgressListener);
        return;
      }

      final localizationService = GetIt.I<LocalizationService>();
      final String languageCode = localizationService.getTranslatedMessage(
        'locale',
      );

      final response = await http.post(
        Uri.parse('http://34.116.240.55:3000/concatenate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'focus': widget.focus,
          'goal': widget.goal,
          'duration': widget.duration,
          'userFitnessLevel': widget.profileProvider.fitnessLevel ?? 0,
          'locale': languageCode,
          'intensity': widget.intensity,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response to get the session ID
        final jsonResponse = json.decode(response.body);
        final String sessionId = jsonResponse['sessionId'];
        selectedVideos =
            jsonResponse['selectedVideos']
                .map<String>((dynamicItem) => dynamicItem.toString())
                .toList();

        print('Selected videos: $selectedVideos');

        // Step 2: Use sessionId in the video URL for the /video endpoint
        final String outputVideoUrl =
            'http://34.116.240.55:3000/video?sessionId=$sessionId';

        _videoPlayerController = VideoPlayerController.network(outputVideoUrl);
        await _videoPlayerController!.initialize();

        _createChewieController();

        setState(() {
          _isLoading = false;
        });

        _videoPlayerController!.addListener(videoProgressListener);
      } else {
        print('Failed to fetch session ID: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error combining videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      autoInitialize: true,
      placeholder: Container(color: Colors.black),
      allowFullScreen: true,
      fullScreenByDefault: false,
    );
  }

  Duration lastWatchedPosition = Duration.zero;
  Duration watchedDuration = Duration.zero;

  void videoProgressListener() {
    if (_chewieController != null) {
      final duration = _chewieController!.videoPlayerController.value.duration;
      final requiredWatchDuration =
          duration * 0.1; // 10% of video needs to be watched
      watchedDuration += const Duration(milliseconds: 500);

      print("#################################");
      print(watchedDuration);
      print(requiredWatchDuration);
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

      if (watchedDuration > requiredWatchDuration && !hasBeenUpdated) {
        if (widget.levelId != 0) {
          // Record this as a completed exercise
          // This will increment _weeklyGoalProgress by 1
          widget.profileProvider.recordExercise(
            'video_${widget.levelId}', // Create a unique exercise ID based on the video ID
            (duration.inSeconds / 60)
                .ceil(), // Still pass duration for other tracking purposes
          );

          // Mark as updated so we don't increment multiple times
          hasBeenUpdated = true;

          final progress = widget.profileProvider.weeklyGoalProgress;
          final target = widget.profileProvider.weeklyGoalTarget;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Exercise completed! $progress of $target weekly exercises completed',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (hasBeenUpdated) {
              _videoPlayerController?.setVolume(0.0);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AfterVideoView(videoIds: selectedVideos),
                ),
              );
            } else {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: AppLocalizations.of(context)!.notCompletedTitle,
                text: AppLocalizations.of(context)!.notCompletedMessage,
                confirmBtnText: AppLocalizations.of(context)!.confirmButton,
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                showCancelBtn: true,
                cancelBtnText: AppLocalizations.of(context)!.cancelButton,
              );
            }
          },
        ),
      ),
      body: Center(
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SpinKitCubeGrid(color: Colors.white, size: 90.0),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.preparingVideo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? AspectRatio(
                  aspectRatio:
                      _chewieController!
                          .videoPlayerController
                          .value
                          .aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
                : Text(
                  AppLocalizations.of(context)!.waitingForVideo,
                  style: const TextStyle(color: Colors.white),
                ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

Future<String?> combineVideos(
  int focus,
  int goal, {
  int duration = 600,
  required int userFitnessLevel,
  int intensity = 1,
}) async {
  const String baseUrl = 'http://34.116.240.55:3000/concatenate';
  final token = await getAuthToken();

  try {
    final localizationService = GetIt.I<LocalizationService>();

    final String languageCode = localizationService.getTranslatedMessage(
      'locale',
    );

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "userFitnessLevel": userFitnessLevel,
        "duration": duration,
        "focus": focus,
        "goal": goal,
        "intensity": intensity,
        "locale": languageCode, // Use the translated language code
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final sessionId = jsonResponse['sessionId']; // Extract sessionId
      selectedVideos =
          jsonResponse['selectedVideos']
              .map<String>((dynamicItem) => dynamicItem.toString())
              .toList();

      print('Video concatenation triggered successfully.');
      print('Session ID: $sessionId');
      print('Selected videos: $selectedVideos');

      return sessionId; // Return the sessionId
    } else {
      // Log the response body for debugging
      print('Failed to trigger video concatenation: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error making request to /concatenate endpoint: $e');
  }

  return null;
}

Future<String> _assetToFile(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final List<int> bytes = data.buffer.asUint8List();
  final String tempPath = (await getTemporaryDirectory()).path;
  final File file = File('$tempPath/${assetPath.split('/').last}');
  await file.writeAsBytes(bytes);
  return file.path;
}
