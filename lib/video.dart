import 'dart:typed_data';

import 'package:backquest/stats.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:io';

import 'main.dart';
import 'questionaire.dart';

class VideoCombinerScreen extends StatefulWidget {
  final LevelNotifier levelNotifier;
  final ProfilProvider profilProvider;
  final int levelId;

  VideoCombinerScreen({
    required this.levelNotifier,
    required this.profilProvider,
    required this.levelId,
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
      _isLoading = true; // Show loading indicator while processing
    });

    // Trigger video combining process on the server
    await combineVideos();

    // URL of the concatenated video on the server
    // Assuming your server is accessible via HTTP and the concatenated video is served at the /video endpoint
    final String outputVideoUrl = 'http://135.125.218.147:3000/video';

    // Initialize the video player controller with the network URL
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

      watchedDuration += Duration(milliseconds: 300);

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
      appBar: AppBar(
        title: Text('Seamless Video Playback'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (hasBeenUpdated) {
              if (hasBeenUpdated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AfterVideoView()), // Directly open AfterVideoView
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
            ? CircularProgressIndicator()
            : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : Container(
                    child: Text('Waiting for video...'),
                  ),
      ),
    );
  }

  // Function to get the local path for saving the combined video
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

/* Future<void> combineVideos() async {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

// Define the paths of the input videos in the assets
  final List<String> videoAssetPaths = [
    'assets/videos/abschluss1_cp_fesi.mp4',
    'assets/videos/birddog_hiswi_auf_4fl_auf.mp4',
    'assets/videos/birddog_wippen_links_4fl_auf_4fl_auf.mp4',
    'assets/videos/childpose_4fl_cp.mp4',
    'assets/videos/childpose_cp_cp.mp4',
    'assets/videos/katzekuh_4fl-auf_4fl-auf_.mp4',
  ];

  // Copy videos from assets to temporary files
  final List<String> videoFilePaths = await Future.wait(
    videoAssetPaths.map((assetPath) => _assetToFile(assetPath)),
  );

  // Create a temporary file to list all videos for the concat demuxer
  final String listPath =
      (await getTemporaryDirectory()).path + '/video_list.txt';
  final File listFile = File(listPath);
  final String content =
      videoFilePaths.map((path) => "file '$path'").join('\n');
  await listFile.writeAsString(content);

  // Define the output path for the combined video
  final String outputPath = await _localPath + '/combined_video.mp4';

  // FFmpeg command using the concat demuxer
  final String command =
      '-y -f concat -safe 0 -i $listPath -c copy $outputPath';

  // Run FFmpeg command
  final int returnCode = await _flutterFFmpeg.execute(command);

  if (returnCode == 0) {
    print('Video combination successful. Combined video saved at: $outputPath');
  } else {
    print('Error combining videos. FFmpeg returned code: $returnCode');
  }
} */

Future<void> combineVideos() async {
  final String url =
      'http://135.125.218.147:3000/concatenate'; // Replace with your actual server URL and port
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    print('Video concatenation triggered successfully.');
  } else {
    throw Exception('Failed to trigger video concatenation');
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
