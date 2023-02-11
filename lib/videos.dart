import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Levels extends StatefulWidget {
  const Levels({Key? key}) : super(key: key);

  @override
  _LevelsState createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  List<Map<String, dynamic>> _levelList = [
    {
      'id': 1,
      'title': 'Level 1',
      'description': VideoPlayerView(
        url: 'assets/videos/level_1/1_1.mp4',
        text: "1_1",
      ),
      'isExpanded': false,
      'isPlayed': false
    },
    {
      'id': 2,
      'title': 'Level 2',
      'description': Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoPlayerView(
            url: 'assets/videos/level_2/2_1.mp4',
            text: "2_1",
          ),
          VideoPlayerView(
            url: 'assets/videos/level_2/2_2.mp4',
            text: "2_2",
          ),
          VideoPlayerView(
            url: 'assets/videos/level_2/2_3.mp4',
            text: "2_3",
          ),
        ],
      ),
      'isExpanded': false,
      'isPlayed': false
    },
    {
      'id': 2,
      'title': 'Level 3',
      'description': Text("456"),
      'isExpanded': false,
      'isPlayed': false
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Flutter Expansion Panel List Demo'),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          elevation: 3,
          // Controlling the expansion behavior
          expansionCallback: (index, isExpanded) {
            setState(() {
              _levelList[index]['isExpanded'] = !isExpanded;
            });
          },
          animationDuration: Duration(milliseconds: 600),
          children: _levelList
              .map(
                (item) => ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: item['isExpanded'] == true
                      ? Colors.cyan[100]
                      : Colors.white,
                  headerBuilder: (_, isExpanded) => Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      child: Text(
                        item['title'],
                        style: TextStyle(fontSize: 20),
                      )),
                  body: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: item['description'],
                  ),
                  isExpanded: item['isExpanded'],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key, required this.url, required this.text});

  final String url;
  final String text;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset(widget.url);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        AspectRatio(
            aspectRatio: 16 / 9, child: Chewie(controller: _chewieController)),
      ],
    );
  }
}
