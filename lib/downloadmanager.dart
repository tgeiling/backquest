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

  void resetDownloadParameters() {
    isDownloading = false;
    downloadProgress = 0.0;
    sessionId = null;
    downloadError = null;
    currentFileName = null;
    displayName = null;

    // Clear these previously uncleared parameters
    duration = null;
    focus = null;
    goal = null;
    intensity = null;
    selectedVideos = [];

    _downloadStateController.add(false);
    _updateDownloadInfo();
  }

  Future<bool> isDuplicateDownload() async {
    if (sessionId == null) {
      return false;
    }

    try {
      // Get existing videos metadata
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/video_metadata.json');

      if (!metadataFile.existsSync()) {
        return false; // No existing videos
      }

      final jsonString = await metadataFile.readAsString();
      final List<dynamic> existingMetadata = json.decode(jsonString);

      // Check if there's a video with the same sessionId
      for (var item in existingMetadata) {
        final video = OfflineVideo.fromJson(item);

        // Skip if the file doesn't exist anymore
        if (!File(video.filePath).existsSync()) continue;

        // Check if sessionId matches - this means it's exactly the same video
        if (video.sessionId == sessionId) {
          return true; // Found an exact duplicate
        }
      }

      return false; // No duplicates found
    } catch (e) {
      print('Error checking for duplicate downloads: $e');
      return false; // Continue with download if check fails
    }
  }

  // Method to start download
  Future<bool> startDownload(BuildContext context) async {
    if (isDownloading) return false;

    // Check for duplicate downloads
    final isDuplicate = await isDuplicateDownload();
    if (isDuplicate) {
      // Return false without resetting download parameters
      return false;
    }

    // Store context globally
    final scaffoldMessengerState = ScaffoldMessenger.of(context);

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

      // IMPORTANT FIX: First request concatenation from server - same as streaming version
      sessionId = await combineVideos(
        focus!,
        goal!,
        duration: duration!,
        userFitnessLevel: userFitnessLevel,
        intensity: intensity!,
      );

      if (sessionId == null) {
        throw Exception('Failed to get session ID for video concatenation');
      }

      // Now download the video using the sessionId
      final directory = await getApplicationDocumentsDirectory();
      final videoPath = '${directory.path}/$currentFileName';

      // Use the correct URL with sessionId parameter
      final videoUrl = 'http://34.116.240.55:3000/video?sessionId=$sessionId';

      // Track download progress
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(videoUrl));

      // Add timeout and keep-alive for better reliability
      request.headers['Connection'] = 'keep-alive';
      final response = await client
          .send(request)
          .timeout(
            Duration(minutes: 10),
            onTimeout: () {
              throw TimeoutException('Download timed out after 10 minutes');
            },
          );

      if (response.statusCode == 200) {
        final file = File(videoPath);
        final contentLength = response.contentLength ?? 0;

        // CHANGED: Create a file sink to write chunks directly to disk
        final sink = file.openWrite();
        int downloadedBytes = 0;

        // CHANGED: Stream each chunk directly to disk
        await for (var chunk in response.stream) {
          // Write chunk directly to file instead of keeping in memory
          sink.add(chunk);
          downloadedBytes += chunk.length;

          // Update progress
          if (contentLength > 0) {
            downloadProgress = downloadedBytes / contentLength;
            _downloadProgressController.add(downloadProgress);
            _updateDownloadInfo();

            // Update background service
            BackgroundService.updateDownloadProgress(
              downloadProgress,
              displayName ?? 'Video',
            );
          }
        }

        // CHANGED: Close file properly
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

        // Show success message
        try {
          scaffoldMessengerState.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.videoDownloadSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('Error showing success SnackBar: $e');
        }

        resetDownloadParameters();
        _downloadStateController.add(false);
        _updateDownloadInfo();
        return true;
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading video: $e');
      downloadError = e.toString();

      // Use the stored scaffold messenger state instead of context
      try {
        scaffoldMessengerState.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.videoDownloadFailed),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print('Error showing error SnackBar: $e');
      }

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
      resetDownloadParameters();
      downloadError = "Download canceled";

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

// Add this annotation to make the class accessible to native code
@pragma('vm:entry-point')
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

  // Add the annotation to the onStart method as well
  @pragma('vm:entry-point')
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
        // Fix: Handle both int and double types for progress
        final progress =
            event['progress'] != null
                ? (event['progress'] is int
                        ? (event['progress'] as int).toDouble()
                        : event['progress'] as double?) ??
                    0.0
                : 0.0;
        final displayName = event['displayName'] as String? ?? 'Video';

        service.setForegroundNotificationInfo(
          title: 'Downloading $displayName',
          content: '${(progress * 100).toStringAsFixed(0)}% complete',
        );
      }

      // Save progress to shared preferences for recovery
      if (event['progress'] != null) {
        final prefs = await SharedPreferences.getInstance();
        // Fix: Convert to double before saving
        final progressValue =
            event['progress'] is int
                ? (event['progress'] as int).toDouble()
                : (event['progress'] as double?);
        await prefs.setDouble('download_progress', progressValue ?? 0.0);
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
    service.on('cancelDownload').listen((event) async {
      // Clean up shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('download_progress');
      await prefs.remove('download_name');

      service.stopSelf();
    });
  }

  // Add the annotation to the iOS background handler as well
  @pragma('vm:entry-point')
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
