import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider.dart';
import 'video.dart';
import 'offline.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal() {
    // Initialize background service
    BackgroundService.initializeService();

    // Recover any in-progress downloads after app restart
    _recoverDownload();
  }

  // Download state
  bool isDownloading = false;
  double downloadProgress = 0.0;
  String? sessionId;
  String? downloadError;
  String? currentFileName; // Add filename for UI display
  String? displayName; // Add display name for UI

  // Parameters for download
  int? duration;
  int? focus;
  int? goal;
  int? intensity;
  List<String> selectedVideos = [];

  // Stream controllers to notify listeners
  final _downloadProgressController = StreamController<double>.broadcast();
  Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

  final _downloadStateController = StreamController<bool>.broadcast();
  Stream<bool> get downloadStateStream => _downloadStateController.stream;

  // New controller for download info updates
  final _downloadInfoController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get downloadInfoStream =>
      _downloadInfoController.stream;

  // Method to recover download after app restart
  Future<void> _recoverDownload() async {
    // Check shared preferences for any in-progress download
    final prefs = await SharedPreferences.getInstance();
    final savedProgress = prefs.getDouble('download_progress');
    final savedName = prefs.getString('download_name');

    if (savedProgress != null && savedName != null) {
      // Restore download state
      isDownloading = true;
      downloadProgress = savedProgress;
      displayName = savedName;

      // Update streams
      _downloadStateController.add(true);
      _downloadProgressController.add(downloadProgress);
      _updateDownloadInfo();
    }
  }

  // Method to set download parameters
  void setDownloadParameters({
    required int duration,
    required int focus,
    required int goal,
    required int intensity,
    List<String>? selectedVideos,
    String? displayName,
  }) {
    this.duration = duration;
    this.focus = focus;
    this.goal = goal;
    this.intensity = intensity;
    this.selectedVideos = selectedVideos ?? [];
    this.displayName = displayName;
  }

  // Method to start download
  Future<bool> startDownload(BuildContext context) async {
    if (isDownloading) return false;
    if (duration == null ||
        focus == null ||
        goal == null ||
        intensity == null) {
      downloadError = "Download parameters not set";
      return false;
    }

    isDownloading = true;
    downloadProgress = 0.0;
    downloadError = null;
    _downloadStateController.add(true);
    _downloadProgressController.add(0.0);

    // Generate a filename
    final now = DateTime.now();
    currentFileName = 'video_${now.millisecondsSinceEpoch}.mp4';

    // Create a display name if not provided
    if (displayName == null) {
      final appLocalizations = AppLocalizations.of(context)!;
      final dateFormat = DateFormat('MM-dd');
      final formattedDate = dateFormat.format(now);
      final focusName = _getFocusName(focus!, appLocalizations);
      displayName = '${appLocalizations.exercise} $formattedDate: $focusName';
    }

    // Update download info
    _updateDownloadInfo();

    // Start background service for the download
    final downloadInfo = {
      'progress': 0.0,
      'displayName': displayName,
      'duration': duration,
      'focus': focus,
      'goal': goal,
      'intensity': intensity,
    };
    BackgroundService.startDownloadService(downloadInfo);

    try {
      // Get user fitness level from provider
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final userFitnessLevel = profileProvider.fitnessLevel;

      // Request video concatenation from server
      sessionId = await combineVideos(
        focus!,
        goal!,
        duration: duration!,
        userFitnessLevel: userFitnessLevel,
        intensity: intensity!,
      );

      if (sessionId != null) {
        // Download the video
        final directory = await getApplicationDocumentsDirectory();
        final videoPath = '${directory.path}/$currentFileName';

        // Use HTTP instead of HTTPS due to cleartext traffic issue
        final videoUrl = 'http://34.116.240.55:3000/video?sessionId=$sessionId';

        // Download with progress tracking
        final request = http.Request('GET', Uri.parse(videoUrl));
        final response = await http.Client().send(request);

        if (response.statusCode == 200) {
          final file = File(videoPath);
          final sink = file.openWrite();

          final contentLength = response.contentLength ?? 0;
          int receivedBytes = 0;

          await for (final chunk in response.stream) {
            if (!isDownloading) {
              // If download was canceled
              await sink.flush();
              await sink.close();
              file.deleteSync();
              _downloadStateController.add(false);
              return false;
            }

            sink.add(chunk);
            receivedBytes += chunk.length;

            if (contentLength > 0) {
              downloadProgress = receivedBytes / contentLength;
              _downloadProgressController.add(downloadProgress);
              _updateDownloadInfo();

              // Update background service with progress
              BackgroundService.updateDownloadProgress(
                downloadProgress,
                displayName ?? "Video",
              );
            }
          }

          await sink.flush();
          await sink.close();

          // Save video metadata for offline access
          await _saveVideoMetadata(
            context: context,
            filePath: videoPath,
            sessionId: sessionId!,
          );

          // Successfully completed
          downloadProgress = 1.0;
          _downloadProgressController.add(1.0);
          _updateDownloadInfo();

          // Signal completion to background service
          BackgroundService.completeDownload();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.videoDownloadSuccess),
              backgroundColor: Colors.green,
            ),
          );

          isDownloading = false;
          displayName = null;
          currentFileName = null;
          _downloadStateController.add(false);
          _updateDownloadInfo();
          return true;
        } else {
          throw Exception('Failed to download video: ${response.statusCode}');
        }
      } else {
        throw Exception('Failed to generate video session');
      }
    } catch (e) {
      print('Error downloading video: $e');
      downloadError = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.videoDownloadFailed),
          backgroundColor: Colors.red,
        ),
      );

      isDownloading = false;
      displayName = null;
      currentFileName = null;
      _downloadStateController.add(false);
      _updateDownloadInfo();
      return false;
    }
  }

  // Method to cancel download
  void cancelDownload() {
    if (isDownloading) {
      isDownloading = false;
      downloadError = "Download canceled";
      _downloadStateController.add(false);
      _updateDownloadInfo();

      // Signal cancellation to background service
      BackgroundService.cancelDownload();
    }
  }

  // Update download info for all listeners
  void _updateDownloadInfo() {
    _downloadInfoController.add({
      'isDownloading': isDownloading,
      'progress': downloadProgress,
      'fileName': currentFileName,
      'displayName': displayName,
      'error': downloadError,
      'sessionId': sessionId,
      'duration': duration,
      'focus': focus,
      'goal': goal,
      'intensity': intensity,
    });
  }

  // Method to save video metadata
  Future<void> _saveVideoMetadata({
    required BuildContext context,
    required String filePath,
    required String sessionId,
  }) async {
    try {
      // Create metadata object
      final videoMetadata = OfflineVideo(
        filePath: filePath,
        displayName: displayName ?? 'Video ${DateTime.now().toIso8601String()}',
        savedDate: DateTime.now(),
        duration: duration!,
        focus: focus!,
        goal: goal!,
        intensity: intensity!,
        sessionId: sessionId,
        videoIds: selectedVideos,
      );

      // Load existing metadata
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/video_metadata.json');
      List<dynamic> existingMetadata = [];

      if (metadataFile.existsSync()) {
        final jsonString = await metadataFile.readAsString();
        existingMetadata = json.decode(jsonString);
      }

      // Add new metadata and save
      existingMetadata.add(videoMetadata.toJson());
      await metadataFile.writeAsString(json.encode(existingMetadata));
    } catch (e) {
      print('Error saving video metadata: $e');
    }
  }

  String _getFocusName(int focus, AppLocalizations localizations) {
    final focusOptions = [
      localizations.focusLowerBack,
      localizations.focusUpperBack,
      localizations.focusNeck,
      localizations.focusAll,
    ];

    if (focus >= 0 && focus < focusOptions.length) {
      return focusOptions[focus];
    }
    return localizations.focusAll;
  }

  void dispose() {
    _downloadProgressController.close();
    _downloadStateController.close();
    _downloadInfoController.close();
  }
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Configure notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'download_channel',
      'Download Service',
      description: 'Background service for video downloads',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // Initialize background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'download_channel',
        initialNotificationTitle: 'Video Download',
        initialNotificationContent: 'Preparing download...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  // This is the function that will be called when the service is started
  static Future<void> onStart(ServiceInstance service) async {
    // For Android, we need to handle foreground service
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    // Listen for download progress updates
    service.on('updateProgress').listen((event) async {
      if (event == null) return;

      // Update notification with progress
      if (service is AndroidServiceInstance) {
        final progress = (event['progress'] as double?) ?? 0.0;
        final displayName = event['displayName'] as String? ?? 'Video';

        service.setForegroundNotificationInfo(
          title: 'Downloading $displayName',
          content: '${(progress * 100).toStringAsFixed(0)}% complete',
        );
      }

      // Save progress to shared preferences for recovery
      if (event['progress'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('download_progress', event['progress']);
        await prefs.setString('download_name', event['displayName'] ?? 'Video');
      }
    });

    // Listen for download completion
    service.on('downloadComplete').listen((event) async {
      // Clean up shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('download_progress');
      await prefs.remove('download_name');

      // Show completion notification
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Download Complete',
          content: 'Your video has been saved offline',
        );
      }

      // Stop the service after a short delay
      await Future.delayed(Duration(seconds: 3));
      service.stopSelf();
    });

    // Listen for download cancellation
    service.on('cancelDownload').listen((event) {
      service.stopSelf();
    });
  }

  // For iOS, a separate background handler is needed
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  // Method to start the background service for download
  static Future<void> startDownloadService(
    Map<String, dynamic> downloadInfo,
  ) async {
    final service = FlutterBackgroundService();
    await service.startService();

    // Send initial download info
    service.invoke('updateProgress', downloadInfo);
  }

  // Method to update download progress in the background service
  static void updateDownloadProgress(double progress, String displayName) {
    final service = FlutterBackgroundService();
    service.invoke('updateProgress', {
      'progress': progress,
      'displayName': displayName,
    });
  }

  // Method to signal download completion
  static void completeDownload() {
    final service = FlutterBackgroundService();
    service.invoke('downloadComplete');
  }

  // Method to cancel the download
  static void cancelDownload() {
    final service = FlutterBackgroundService();
    service.invoke('cancelDownload');
  }
}
