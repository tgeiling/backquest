import 'dart:convert';

import 'package:backquest/localization_service.dart';
import 'package:backquest/stats.dart';
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

import 'main.dart';
import 'questionaire.dart';
import 'services.dart';

List<String> selectedVideos = [];

class VideoCombinerScreen extends StatefulWidget {
  final LevelNotifier levelNotifier;
  final ProfilProvider profilProvider;
  final int levelId;
  final int focus;
  final int goal;
  final int duration;

  const VideoCombinerScreen({
    super.key,
    required this.levelNotifier,
    required this.profilProvider,
    required this.levelId,
    required this.focus,
    required this.goal,
    this.duration = 600,
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
    _startVideoCombining();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    hasBeenUpdated = false;
    super.dispose();
  }

  Future<void> _startVideoCombining() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final localizationService = GetIt.I<LocalizationService>();
      final String languageCode =
          localizationService.getTranslatedMessage('locale');

      final response = await http.post(
        Uri.parse('http://34.116.240.55/:3000/concatenate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'focus': widget.focus,
          'goal': widget.goal,
          'duration': widget.duration,
          'userFitnessLevel': widget.profilProvider.fitnessLevel ?? 0,
          'locale': languageCode,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response to get the session ID
        final jsonResponse = json.decode(response.body);
        final String sessionId = jsonResponse['sessionId'];
        selectedVideos = jsonResponse['selectedVideos']
            .map<String>((dynamicItem) => dynamicItem.toString())
            .toList();

        print('Selected videos: $selectedVideos');

        // Step 2: Use sessionId in the video URL for the /video endpoint
        final String outputVideoUrl =
            'http://34.116.240.55/:3000/video?sessionId=$sessionId';

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
      placeholder: Container(
        color: Colors.black,
      ),
      allowFullScreen: true,
      fullScreenByDefault: false,
    );
  }

  Duration lastWatchedPosition = Duration.zero;
  Duration watchedDuration = Duration.zero;

  void videoProgressListener() {
    if (_chewieController != null) {
      final duration = _chewieController!.videoPlayerController.value.duration;
      final halfwayDuration = duration * 0.1;

      watchedDuration += const Duration(milliseconds: 500);

      print("#################################");
      print(watchedDuration);
      print(halfwayDuration);
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

      if (watchedDuration > halfwayDuration && !hasBeenUpdated) {
        if (widget.levelId != 0) {
          widget.levelNotifier.updateLevelStatus(widget.levelId);
          widget.profilProvider.setCompletedLevels(widget.levelId);
          widget.profilProvider.setCompletedLevelsTotal(
              widget.profilProvider.completedLevelsTotal + 1);
          widget.profilProvider.setWeeklyDone();
        }
        hasBeenUpdated = true;
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (hasBeenUpdated) {
              _videoPlayerController?.setVolume(0.0);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AfterVideoView(videoIds: selectedVideos)),
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
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SpinKitCubeGrid(
                      color: Colors.white,
                      size: 90.0,
                    ),
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
                    aspectRatio: _chewieController!
                        .videoPlayerController.value.aspectRatio,
                    child: Chewie(
                      controller: _chewieController!,
                    ),
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
}) async {
  const String baseUrl = 'http://34.116.240.55/:3000/concatenate';
  final token = await getAuthToken();

  try {
    final localizationService = GetIt.I<LocalizationService>();

    final String languageCode =
        localizationService.getTranslatedMessage('locale');

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
        "locale": languageCode, // Use the translated language code
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final sessionId = jsonResponse['sessionId']; // Extract sessionId
      selectedVideos = jsonResponse['selectedVideos']
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

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
