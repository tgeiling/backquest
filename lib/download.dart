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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';

import 'elements.dart';
import 'questionaire.dart';
import 'video.dart';

class DownloadScreen extends StatefulWidget {
  final Function(String, int, bool) toggleModal;

  const DownloadScreen({
    required Key key,
    required this.toggleModal,
  }) : super(key: key);

  @override
  DownloadScreenState createState() => DownloadScreenState();
}

class DownloadScreenState extends State<DownloadScreen>
    with AutomaticKeepAliveClientMixin<DownloadScreen> {
  final GlobalKey<ProgressBarWithPillState> _progressBarKey = GlobalKey();
  bool _isLoading = false;
  List<String> _downloadedVideos = [];
  List<String> _downloadedVideoNames = [];
  List<String> _downloadedVideoDetails = [];
  List<List<String>> _downloadedSelectedVideos = [];
  double _downloadProgress = 0.0;

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

  bool _isDownloading = false;

  Future<void> combineAndDownloadVideo(
    int focus,
    int goal,
    int duration,
    int userFitnessLevel,
  ) async {
    if (_isDownloading) {
      QuickAlert.show(
        backgroundColor: Colors.grey.shade700,
        textColor: Colors.white,
        context: context,
        type: QuickAlertType.warning,
        title: AppLocalizations.of(context)!.downloadInProgress,
        text: AppLocalizations.of(context)!.pleaseWaitForCurrentDownload,
      );
      return;
    }

    _isDownloading = true;

    setState(() {
      _isLoading = true;
    });

    // Combine videos and get the session ID
    final sessionId = await combineVideos(
      focus,
      goal,
      duration: duration,
      userFitnessLevel: userFitnessLevel,
    );

    if (sessionId == null) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to retrieve session ID. Cannot download video.');
      return;
    }

    // Construct the URL with the session ID
    final String outputVideoUrl =
        'http://135.125.218.147:3000/video?sessionId=$sessionId';

    await Future.delayed(const Duration(seconds: 2));

    try {
      await _downloadVideo(
        outputVideoUrl,
        focus,
        goal,
        duration,
        selectedVideos,
      );
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

  Future<void> _downloadVideo(String videoUrl, int focus, int goal,
      int duration, List<String> selectedVideos) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/video_$timestamp.mp4';
      String nameTimestamp = DateFormat('MMdd HH:mm').format(DateTime.now());
      final displayName = AppLocalizations.of(context)!
          .downloadedVideoName(nameTimestamp); // Translated name

      // Use Dio for downloading with progress
      Dio dio = Dio();
      await dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            setState(() {
              _progressBarKey.currentState?.updateProgress(progress);
            });
          }
        },
      );

      // After download completes
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
        title: AppLocalizations.of(context)!.downloadComplete,
        text: AppLocalizations.of(context)!.videoDownloadedSuccessfully,
      );
    } on DioError catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error downloading video: ${e.message}');
      QuickAlert.show(
        backgroundColor: Colors.grey.shade700,
        textColor: Colors.white,
        context: context,
        type: QuickAlertType.error,
        title: AppLocalizations.of(context)!.downloadError,
        text: AppLocalizations.of(context)!.errorWhileDownloadingVideo,
      );
    } finally {
      setState(() {
        _isDownloading = false; // Reset the flag when the download completes
        _isLoading = false;
      });
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
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: SpinKitCubeGrid(
                      color: Colors.white,
                      size: 90.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: ProgressBarWithPill(
                        key: _progressBarKey,
                        initialProgress: 0.0,
                      )),
                  const SizedBox(height: 10),
                  Text(
                    '${((_progressBarKey.currentState?.progress ?? 0.0) * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    AppLocalizations.of(context)!.creatingAndDownloadingVideo,
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
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    title: Text(
                                      _downloadedVideoNames[index],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      _downloadedVideoDetails[index],
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.play_arrow,
                                              color: Colors.white),
                                          onPressed: () => _playVideo(
                                              _downloadedVideos[index],
                                              _downloadedSelectedVideos[index]),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
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
                          : const Text("")),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    child: PressableButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.toggleModal("", 0, false);
                        });
                      },
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)!.createVideo,
                        style: Theme.of(context).textTheme.labelLarge,
                      )),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final List<String> selectedVideos;

  const VideoPlayerScreen({
    super.key,
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

      watchedDuration += const Duration(milliseconds: 500);

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
            autoInitialize: true,
            placeholder: Container(
              color: Colors.black,
            ),
            allowFullScreen: true,
            fullScreenByDefault: false,
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
          icon: const Icon(
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
                title: AppLocalizations.of(context)!.notDoneTitle,
                text: AppLocalizations.of(context)!.notDoneMessage,
                confirmBtnText: AppLocalizations.of(context)!.confirmButton,
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                showCancelBtn: true,
                cancelBtnText: AppLocalizations.of(context)!.cancel,
              );
            }
          },
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController!,
                ),
              )
            : const CircularProgressIndicator(),
      ),
      backgroundColor: Colors.black,
    );
  }
}
