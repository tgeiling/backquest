import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'elements.dart';

class DownloadScreen extends StatefulWidget {
  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _isLoading = false;
  List<String> _downloadedVideos = ["video 1", "video 2"];

  @override
  void initState() {
    super.initState();
    //_fetchDownloadedVideos();
  }

  Future<void> _fetchDownloadedVideos() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _downloadedVideos = prefs.getStringList('downloadedVideos') ?? [];

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDownloadedVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('downloadedVideos', _downloadedVideos);
  }

  Future<void> _downloadVideo(String videoUrl) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${videoUrl.split('/').last}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _downloadedVideos.add(filePath);
          _isLoading = false;
        });

        _saveDownloadedVideos();

        QuickAlert.show(
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
        context: context,
        type: QuickAlertType.error,
        title: 'Download Error',
        text:
            'An error occurred while downloading the video. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _downloadedVideos = ["video 1", "video 2"];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: SpinKitCubeGrid(
                  color: Colors.blue,
                  size: 90.0,
                ),
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
                                    _downloadedVideos[index].split('/').last,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  trailing: IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.white),
                                    onPressed: () async {
                                      setState(() {
                                        _downloadedVideos.removeAt(index);
                                      });
                                      _saveDownloadedVideos();
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No saved videos.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    child: PressableButton(
                      onPressed: () {
                        //nothin
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
