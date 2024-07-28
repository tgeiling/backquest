import 'dart:convert';

import 'package:backquest/stats.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';

import 'main.dart';
import 'questionaire.dart';
import 'services.dart';

List<String> selectedVideos = [];

class VideoCombinerScreen extends StatefulWidget {
  final LevelNotifier levelNotifier;
  final ProfilProvider profilProvider;
  final int levelId;
  final String focus;
  final String goal;
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

    await combineVideos(widget.focus, widget.goal, duration: widget.duration);

    await Future.delayed(const Duration(seconds: 2));

    const String outputVideoUrl = 'http://135.125.218.147:3000/video';

    _videoPlayerController = VideoPlayerController.network(outputVideoUrl);
    await _videoPlayerController!.initialize();
    _createChewieController();
    setState(() {
      _isLoading = false;
    });

    _videoPlayerController!.addListener(videoProgressListener);
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      placeholder: Container(
        color: Colors.black,
      ),
      autoInitialize: true,
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
              if (hasBeenUpdated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AfterVideoView(videoIds: selectedVideos)),
                );
              }
            } else {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Noch nicht geschafft',
                text: 'Möchtest du deine Trainingssitzung wirklich beenden?',
                confirmBtnText: 'zurück',
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                showCancelBtn: true,
                cancelBtnText: 'bleiben',
              );
            }
          },
        ),
      ),
      body: Center(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SpinKitCubeGrid(
                      color: Colors.white,
                      size: 90.0,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Wir bereiten Ihr Video vor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : Container(
                    child: const Text('Waiting for video...'),
                  ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

Future<void> combineVideos(
  String focus,
  String goal, {
  int duration = 600,
}) async {
  const String baseUrl = 'http://135.125.218.147:3000/concatenate';

  final String encodedFocus = Uri.encodeComponent(focus);
  final String encodedGoal = Uri.encodeComponent(goal);

  final String urlWithParams =
      "$baseUrl?duration=$duration&focus=$encodedFocus&goal=$encodedGoal";

  final token = await getAuthToken();

  try {
    final response = await http.get(
      Uri.parse(urlWithParams),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      print('Video concatenation triggered successfully.');

      final jsonResponse = json.decode(response.body);
      final totalDuration = jsonResponse['totalDuration'];
      selectedVideos = jsonResponse['selectedVideos']
          .map<String>((dynamicItem) => dynamicItem.toString())
          .toList();

      print(totalDuration);
      print('Selected videos: $selectedVideos');
    } else {
      print('Failed to trigger video concatenation: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error making request to /concatenate endpoint: $e');
  }
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
