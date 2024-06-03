import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'elements.dart';
import 'questionaire.dart';
import 'video.dart';

class DownloadScreen extends StatefulWidget {
  final Function(String, int, bool) toggleModal;

  DownloadScreen({
    required Key key,
    required this.toggleModal,
  }) : super(key: key);

  @override
  DownloadScreenState createState() => DownloadScreenState();
}

class DownloadScreenState extends State<DownloadScreen> {
  bool _isLoading = false;
  List<String> _downloadedVideos = [];
  List<String> _downloadedVideoNames = [];
  List<String> _downloadedVideoDetails = [];
  List<List<String>> _downloadedSelectedVideos = [];

  @override
  void initState() {
    super.initState();
    _fetchDownloadedVideos();
  }

  Future<void> _fetchDownloadedVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _downloadedVideos = prefs.getStringList('downloadedVideos') ?? [];
    _downloadedVideoNames = prefs.getStringList('downloadedVideoNames') ?? [];
    _downloadedVideoDetails =
        prefs.getStringList('downloadedVideoDetails') ?? [];
    _downloadedSelectedVideos =
        (prefs.getStringList('downloadedSelectedVideos') ?? [])
            .map((e) => List<String>.from(json.decode(e)))
            .toList();
    setState(() {});
  }

  Future<void> _saveDownloadedVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('downloadedVideos', _downloadedVideos);
    prefs.setStringList('downloadedVideoNames', _downloadedVideoNames);
    prefs.setStringList('downloadedVideoDetails', _downloadedVideoDetails);
    prefs.setStringList(
      'downloadedSelectedVideos',
      _downloadedSelectedVideos.map((e) => json.encode(e)).toList(),
    );
  }

  Future<void> combineAndDownloadVideo(
      String focus, String goal, int duration) async {
    setState(() {
      _isLoading = true;
    });

    await combineVideos(focus, goal, duration: duration);

    await Future.delayed(Duration(seconds: 2));

    final String outputVideoUrl = 'http://135.125.218.147:3000/video';

    try {
      await _downloadVideo(
          outputVideoUrl, focus, goal, duration, selectedVideos);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error downloading video: $e');
    }
  }

  Future<void> _downloadVideo(String videoUrl, String focus, String goal,
      int duration, List<String> selectedVideos) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        String nameTimestamp = DateFormat('MMdd HH:mm').format(DateTime.now());
        final filePath = '${directory.path}/video_$timestamp.mp4';
        final displayName = 'Einheit ${nameTimestamp}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _downloadedVideos.add(filePath);
          _downloadedVideoNames.add(displayName);
          _downloadedVideoDetails
              .add('$focus, $goal, ${_formatDuration(duration)}');
          _downloadedSelectedVideos.add(selectedVideos);
          _isLoading = false;
        });

        _saveDownloadedVideos();

        QuickAlert.show(
          backgroundColor: Colors.grey.shade900,
          textColor: Colors.white,
          context: context,
          type: QuickAlertType.success,
          title: 'Download Complete',
          text: 'Video has been downloaded successfully!',
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        QuickAlert.show(
          backgroundColor: Colors.grey.shade700,
          textColor: Colors.white,
          context: context,
          type: QuickAlertType.error,
          title: 'Download Failed',
          text: 'Failed to download video. Please try again.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      QuickAlert.show(
        backgroundColor: Colors.grey.shade700,
        textColor: Colors.white,
        context: context,
        type: QuickAlertType.error,
        title: 'Download Error',
        text:
            'An error occurred while downloading the video. Please try again.',
      );
    }
  }

  String _formatDuration(int duration) {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '${minutes}min ${seconds}s';
  }

  void _playVideo(String videoPath, List<String> selectedVideos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
            videoPath: videoPath, selectedVideos: selectedVideos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SpinKitCubeGrid(
                      color: Colors.white,
                      size: 90.0,
                    ),
                  ),
                  Text(
                    "Wir erstellen und Laden ihr \n nächstes Video herunter",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              )
            : Column(
                children: [
                  Expanded(
                      child: _downloadedVideos.isNotEmpty
                          ? ListView.builder(
                              itemCount: _downloadedVideos.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16.0),
                                    title: Text(
                                      _downloadedVideoNames[index],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      _downloadedVideoDetails[index],
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.play_arrow,
                                              color: Colors.white),
                                          onPressed: () => _playVideo(
                                              _downloadedVideos[index],
                                              _downloadedSelectedVideos[index]),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.white),
                                          onPressed: () async {
                                            setState(() {
                                              _downloadedVideos.removeAt(index);
                                              _downloadedVideoNames
                                                  .removeAt(index);
                                              _downloadedVideoDetails
                                                  .removeAt(index);
                                              _downloadedSelectedVideos
                                                  .removeAt(index);
                                            });
                                            _saveDownloadedVideos();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Text("")),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    child: PressableButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.toggleModal("", 0, false);
                        });
                      },
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Center(
                          child: Text(
                        "Video erstellen",
                        style: Theme.of(context).textTheme.labelLarge,
                      )),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final List<String> selectedVideos;

  VideoPlayerScreen({
    required this.videoPath,
    required this.selectedVideos,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  bool hasBeenUpdated = false;

  Duration lastWatchedPosition = Duration.zero;
  Duration watchedDuration = Duration.zero;

  void videoProgressListener() {
    if (_chewieController != null) {
      final duration = _chewieController!.videoPlayerController.value.duration;
      final halfwayDuration = duration * 0.1;

      watchedDuration += Duration(milliseconds: 500);

      if (watchedDuration > halfwayDuration && !hasBeenUpdated) {
        hasBeenUpdated = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            looping: true,
          );
        });
      });
    _controller.addListener(videoProgressListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (hasBeenUpdated) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AfterVideoView(videoIds: widget.selectedVideos)),
              );
            } else {
              QuickAlert.show(
                backgroundColor: Colors.grey.shade700,
                textColor: Colors.white,
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
        child: _controller.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : CircularProgressIndicator(),
      ),
      backgroundColor: Colors.black,
    );
  }
}
