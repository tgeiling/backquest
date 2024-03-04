import 'dart:typed_data';

import 'package:backquest/stats.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
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

    // Simulating video combining process
    await combineVideos(); // Ensure this is your actual video combining function

    // Assuming combineVideos saves the output video to a known path
    final String outputVideoPath = (await _localPath) + '/combined_video.mp4';

    // Check if the combined video file exists before trying to play it
    final File outputFile = File(outputVideoPath);
    if (await outputFile.exists()) {
      _videoPlayerController = VideoPlayerController.file(outputFile);
      await _videoPlayerController!.initialize();
      _createChewieController();
      setState(() {
        _isLoading = false;
      });
    } else {
      // Handle the case where the video file doesn't exist
      setState(() {
        _isLoading = false;
        // Optionally, set some state variable to show an error message to the user
      });
      print('Combined video file does not exist: $outputVideoPath');
    }

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
      final position = _chewieController!.videoPlayerController.value.position;
      final duration = _chewieController!.videoPlayerController.value.duration;
      final halfwayDuration = duration * 0.5;

      // Calculate the difference between the current position and the last watched position.
      final difference = position - lastWatchedPosition;

      // If the difference is greater than 5 seconds, don't count it as watched.
      if (difference < const Duration(seconds: 5)) {
        watchedDuration += difference;
      }

      // Update the last watched position to the current position.
      lastWatchedPosition = position;

      print("#################################");
      print(watchedDuration);
      print(halfwayDuration);
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

      if (watchedDuration > halfwayDuration) {
        if (!hasBeenUpdated) {
          if (widget.levelId != 0) {
            widget.levelNotifier.updateLevelStatus(widget.levelId, true);
            widget.profilProvider.setCompletedLevels(widget.levelId);
          }
          hasBeenUpdated = true;
        }
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

Future<void> combineVideos() async {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  // Define the URLs of the input streams
  final List<String> streamUrls = [
    'https://player.vimeo.com/external/887648660.m3u8?s=63218d565ec58f2d2e3b8e850df015e9520f5ac3&logging=false',
    'https://player.vimeo.com/external/887650209.m3u8?s=add52ae6fce53491a0dcc44b04afeae9d7bcdb37&logging=false',
    'https://player.vimeo.com/external/887649947.m3u8?s=9876c8bcb50399733deb3ccea025989948aff93a&logging=false',
    'https://player.vimeo.com/external/887649631.m3u8?s=6ae79d78e9ada9cb217346286d7d671682358f5a&logging=false',
    'https://player.vimeo.com/external/887648435.m3u8?s=ab12d21b9e1f2a250e0035b5ede7a15fff9429fa&logging=false'
  ];

  // Temporary directory for intermediate files
  final tempDir = await getTemporaryDirectory();
  final List<String> downloadedPaths = [];

  // Download and convert each M3U8 stream to a file
  for (int i = 0; i < streamUrls.length; i++) {
    final outputPath = '${tempDir.path}/video_$i.mp4';
    final downloadCommand = '-i ${streamUrls[i]} -c copy $outputPath';
    final returnCode = await _flutterFFmpeg.execute(downloadCommand);
    if (returnCode == 0) {
      print('Download and conversion successful for stream $i');
      downloadedPaths.add(outputPath);
    } else {
      print(
          'Error downloading/converting stream $i. FFmpeg returned code: $returnCode');
      return; // Exit if any download fails
    }
  }

  // Generate the file list for concatenation
  final fileListPath = '${tempDir.path}/file_list.txt';
  final fileList = File(fileListPath);
  final fileContent = downloadedPaths.map((path) => "file '$path'").join('\n');
  await fileList.writeAsString(fileContent);

  // Concatenate the downloaded video files
  final outputPath = '${tempDir.path}/combined_video.mp4';
  final concatCommand =
      '-f concat -safe 0 -i $fileListPath -c copy $outputPath';
  final concatReturnCode = await _flutterFFmpeg.execute(concatCommand);

  if (concatReturnCode == 0) {
    print('Video combination successful. Combined video saved at: $outputPath');
  } else {
    print('Error combining videos. FFmpeg returned code: $concatReturnCode');
  }
}

Future<String> downloadFile(String url, int index) async {
  final client = http.Client();
  final request = http.Request('GET', Uri.parse(url));
  final streamedResponse = await client.send(request);

  final contentLength = streamedResponse.contentLength;
  int receivedBytes = 0;

  final directory = await getTemporaryDirectory();
  // Use the index to create a unique file name for each video
  final filePath = '${directory.path}/video_$index.mp4';
  final file = File(filePath);
  final iosink = file.openWrite();

  streamedResponse.stream.listen(
    (List<int> chunk) {
      // Update the received bytes
      receivedBytes += chunk.length;
      print(
          'Download progress: ${(receivedBytes / contentLength! * 100).toStringAsFixed(0)}%');

      // Write the file chunk
      iosink.add(chunk);
    },
    onDone: () async {
      await iosink.flush();
      await iosink.close();
      print('Download completed: $filePath');
    },
    onError: (e) {
      print('Error: $e');
      iosink.close();
      client.close();
    },
    cancelOnError: true,
  );

  // Since we are listening to the stream, we don't want to return the path immediately
  // Wait for the stream to finish and the file to close
  await iosink.done;
  return filePath;
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
