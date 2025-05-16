// offline.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'downloadmanager.dart';
import 'provider.dart';
import 'video.dart';

// Model class for offline video metadata
class OfflineVideo {
  final String filePath;
  final String displayName;
  final DateTime savedDate;
  final int duration;
  final int focus;
  final int goal;
  final int intensity;
  final String sessionId;
  final List<String> videoIds;

  OfflineVideo({
    required this.filePath,
    required this.displayName,
    required this.savedDate,
    required this.duration,
    required this.focus,
    required this.goal,
    required this.intensity,
    required this.sessionId,
    required this.videoIds,
  });

  // Create from JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'displayName': displayName,
      'savedDate': savedDate.toIso8601String(),
      'duration': duration,
      'focus': focus,
      'goal': goal,
      'intensity': intensity,
      'sessionId': sessionId,
      'videoIds': videoIds,
    };
  }

  // Create from JSON for retrieval
  factory OfflineVideo.fromJson(Map<String, dynamic> json) {
    return OfflineVideo(
      filePath: json['filePath'],
      displayName: json['displayName'],
      savedDate: DateTime.parse(json['savedDate']),
      duration: json['duration'],
      focus: json['focus'],
      goal: json['goal'],
      intensity: json['intensity'],
      sessionId: json['sessionId'],
      videoIds: List<String>.from(json['videoIds']),
    );
  }
}

class OfflinePage extends StatefulWidget {
  const OfflinePage({Key? key}) : super(key: key);

  @override
  _OfflinePageState createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  List<OfflineVideo> _offlineVideos = [];
  bool _isLoading = true;
  final DownloadManager _downloadManager = DownloadManager();
  StreamSubscription? _downloadProgressSubscription;
  StreamSubscription? _downloadStateSubscription;
  StreamSubscription? _downloadInfoSubscription;

  @override
  void initState() {
    super.initState();
    _loadOfflineVideos();

    // Listen to download state changes
    _downloadStateSubscription = _downloadManager.downloadStateStream.listen((
      isDownloading,
    ) {
      if (mounted && !isDownloading) {
        // Refresh the list when download completes
        _loadOfflineVideos();
      }
    });

    // Listen to download info updates
    _downloadInfoSubscription = _downloadManager.downloadInfoStream.listen((
      info,
    ) {
      if (mounted) {
        setState(() {
          // This forces a rebuild when download info changes
        });
      }
    });

    // Initiate the download if parameters are set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_downloadManager.duration != null &&
          !_downloadManager.isDownloading &&
          ModalRoute.of(context)?.isCurrent == true) {
        _downloadManager.startDownload(context);
      }
    });
  }

  @override
  void dispose() {
    _downloadProgressSubscription?.cancel();
    _downloadStateSubscription?.cancel();
    _downloadInfoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          appLocalizations.offlineVideos,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color.fromRGBO(97, 184, 115, 1),
                  ),
                ),
              )
              : StreamBuilder<Map<String, dynamic>>(
                stream: _downloadManager.downloadInfoStream,
                builder: (context, snapshot) {
                  final downloadInfo = snapshot.data;
                  final isDownloading = downloadInfo?['isDownloading'] ?? false;

                  // Combined list of offline videos and current download
                  List<dynamic> combinedList = List.from(_offlineVideos);

                  // Add current download to the list if one is active
                  if (isDownloading && downloadInfo != null) {
                    combinedList.insert(0, {
                      'isDownloadItem': true,
                      'info': downloadInfo,
                    });
                  }

                  if (combinedList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            appLocalizations.noOfflineVideos,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            appLocalizations.downloadVideoFirst,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: combinedList.length,
                    itemBuilder: (context, index) {
                      final item = combinedList[index];

                      // Check if this is a download item
                      if (item is Map && item['isDownloadItem'] == true) {
                        final downloadInfo = item['info'];
                        return _buildDownloadItem(
                          downloadInfo: downloadInfo,
                          appLocalizations: appLocalizations,
                          isTablet: isTablet,
                        );
                      }

                      // Otherwise, it's a regular video item
                      final video = item as OfflineVideo;
                      final durationInMinutes = video.duration ~/ 60;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildVideoCard(
                          video: video,
                          appLocalizations: appLocalizations,
                          isTablet: isTablet,
                          durationInMinutes: durationInMinutes,
                        ),
                      );
                    },
                  );
                },
              ),
        ],
      ),
    );
  }

  // New widget for showing active download in the list
  Widget _buildDownloadItem({
    required Map<String, dynamic> downloadInfo,
    required AppLocalizations appLocalizations,
    required bool isTablet,
  }) {
    final progress = downloadInfo['progress'] ?? 0.0;
    final displayName =
        downloadInfo['displayName'] ?? appLocalizations.downloadingVideo;
    final duration = downloadInfo['duration'] ?? 300;
    final durationInMinutes = duration ~/ 60;

    // Get focus, goal, and intensity if available
    final focus = downloadInfo['focus'] ?? 0;
    final goal = downloadInfo['goal'] ?? 0;
    final intensity = downloadInfo['intensity'] ?? 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border(left: BorderSide(color: Colors.blue[500]!, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title and Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Duration with icon
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 2),
                      Text(
                        "${durationInMinutes}m",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),

              // Download Status
              Text(
                appLocalizations.downloadingVideo,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),

              // Progress bar
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey[200],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 4,
                      width:
                          MediaQuery.of(context).size.width *
                          progress *
                          0.8, // Approximate adjustment for padding
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.blue[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _downloadManager.cancelDownload();
                    },
                    child: Text(
                      appLocalizations.cancel,
                      style: TextStyle(
                        color: Colors.red[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Attributes as pills
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _buildAttributeChip(
                          icon: Icons.flag,
                          label: _getFocusName(focus, appLocalizations),
                          bgColor: Colors.blue[50]!,
                          textColor: Colors.blue[800]!,
                        ),
                        _buildAttributeChip(
                          icon: Icons.track_changes,
                          label: _getGoalName(goal, appLocalizations),
                          bgColor: Colors.purple[50]!,
                          textColor: Colors.purple[800]!,
                        ),
                        _buildAttributeChip(
                          icon: Icons.fitness_center,
                          label: _getIntensityName(intensity, appLocalizations),
                          bgColor: Colors.amber[50]!,
                          textColor: Colors.amber[800]!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add these functions to the _OfflinePageState class in offline.dart

  Future<void> _loadOfflineVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/video_metadata.json');

      if (metadataFile.existsSync()) {
        final jsonString = await metadataFile.readAsString();
        final jsonData = json.decode(jsonString);

        List<OfflineVideo> videos = [];
        for (var item in jsonData) {
          final video = OfflineVideo.fromJson(item);
          // Check if the video file still exists
          if (File(video.filePath).existsSync()) {
            videos.add(video);
          }
        }

        setState(() {
          _offlineVideos = videos;
        });
      }
    } catch (e) {
      print('Error loading offline videos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteOfflineVideo(OfflineVideo video) async {
    try {
      // Delete the video file
      final videoFile = File(video.filePath);
      if (videoFile.existsSync()) {
        await videoFile.delete();
      }

      // Update the metadata
      _offlineVideos.remove(video);

      // Save updated metadata
      await _saveMetadata();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.videoDeleted),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error deleting video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.videoDeleteFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveMetadata() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/video_metadata.json');

      final jsonData = _offlineVideos.map((video) => video.toJson()).toList();
      await metadataFile.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving metadata: $e');
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color.fromRGBO(97, 184, 115, 1), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
        depth: 2,
        intensity: 0.6,
        color: color,
      ),
      onPressed: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard({
    required OfflineVideo video,
    required AppLocalizations appLocalizations,
    required bool isTablet,
    required int durationInMinutes,
  }) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(video.savedDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: const Color.fromRGBO(97, 184, 115, 1),
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title and Duration/Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    video.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Right side: Duration + Delete
                Row(
                  children: [
                    // Duration with icon
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 2),
                        Text(
                          "${durationInMinutes}m",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),

                    // Small delete button
                    InkWell(
                      onTap: () => _showDeleteConfirmation(video),
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Date
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),

            // Content area with tags and play button - BOTTOM ALIGNED
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // This aligns items to the bottom
              children: [
                // Tags area
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildAttributeChip(
                        icon: Icons.flag,
                        label: _getFocusName(video.focus, appLocalizations),
                        bgColor: Colors.blue[50]!,
                        textColor: Colors.blue[800]!,
                      ),
                      _buildAttributeChip(
                        icon: Icons.track_changes,
                        label: _getGoalName(video.goal, appLocalizations),
                        bgColor: Colors.purple[50]!,
                        textColor: Colors.purple[800]!,
                      ),
                      _buildAttributeChip(
                        icon: Icons.fitness_center,
                        label: _getIntensityName(
                          video.intensity,
                          appLocalizations,
                        ),
                        bgColor: Colors.amber[50]!,
                        textColor: Colors.amber[800]!,
                      ),
                    ],
                  ),
                ),

                // Play button
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _playVideo(video),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 2,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
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

  String _getGoalName(int goal, AppLocalizations localizations) {
    final goalOptions = [
      localizations.goalMobility,
      localizations.goalStrength,
      localizations.goalRelaxation,
      localizations.goalPrevention,
    ];

    if (goal >= 0 && goal < goalOptions.length) {
      return goalOptions[goal];
    }
    return localizations.goalMobility;
  }

  String _getIntensityName(int intensity, AppLocalizations localizations) {
    final intensityOptions = [
      localizations.intensityLow,
      localizations.intensityMedium,
      localizations.intensityHigh,
    ];

    if (intensity >= 0 && intensity < intensityOptions.length) {
      return intensityOptions[intensity];
    }
    return localizations.intensityMedium;
  }

  void _playVideo(OfflineVideo video) {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VideoCombinerScreen(
              profileProvider: profileProvider,
              levelId: 1,
              focus: video.focus,
              goal: video.goal,
              duration: video.duration,
              useLocalVideo: true,
              sessionId: video.sessionId,
              intensity: video.intensity,
            ),
      ),
    );
  }

  void _showDeleteConfirmation(OfflineVideo video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final appLocalizations = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(appLocalizations.deleteVideoTitle),
          content: Text(appLocalizations.deleteVideoConfirmation),
          actions: [
            TextButton(
              child: Text(
                appLocalizations.cancel,
                style: TextStyle(color: Colors.grey[700]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                appLocalizations.delete,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOfflineVideo(video);
              },
            ),
          ],
        );
      },
    );
  }
}
