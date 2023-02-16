import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

Map<int, Color> color = {
  50: Color.fromRGBO(64, 154, 181, .1),
  100: Color.fromRGBO(64, 154, 181, .2),
  200: Color.fromRGBO(64, 154, 181, .3),
  300: Color.fromRGBO(64, 154, 181, .4),
  400: Color.fromRGBO(64, 154, 181, .5),
  500: Color.fromRGBO(64, 154, 181, .6),
  600: Color.fromRGBO(64, 154, 181, .7),
  700: Color.fromRGBO(64, 154, 181, .8),
  800: Color.fromRGBO(64, 154, 181, .9),
  900: Color.fromRGBO(64, 154, 181, 1),
};

List<Map<String, dynamic>> _levelList = [
  {
    'id': 1,
    'title': 'Level 1',
    'description': Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPlayerView(
          path: 'assets/videos/level_1/2_1.mp4',
          text: "2_1",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_1/1_1.jpeg'),
        ),
        VideoPlayerView(
          path: 'assets/videos/level_1/2_2.mp4',
          text: "2_2",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_1/1_2.jpg'),
        ),
        VideoPlayerView(
          path: 'assets/videos/level_1/2_3.mp4',
          text: "2_3",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_1/1_3.jpg'),
        ),
      ],
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
          path: 'assets/videos/level_2/2_1.mp4',
          text: "2_1",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_2/2_1.jpg'),
        ),
        VideoPlayerView(
          path: 'assets/videos/level_2/2_2.mp4',
          text: "2_2",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_2/2_2.jpg'),
        ),
        VideoPlayerView(
          path: 'assets/videos/level_2/2_3.mp4',
          text: "2_3",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_2/2_3.jpeg'),
        ),
      ],
    ),
    'isExpanded': false,
    'isPlayed': false
  },
  {
    'id': 3,
    'title': 'Level 3',
    'description': Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPlayerView(
          path: 'assets/videos/level_2/3_1.mp4',
          text: "2_1",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_2/3_1.jpg'),
        ),
        VideoPlayerView(
          path: 'assets/videos/level_2/3_2.mp4',
          text: "2_2",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_2/3_2.jpg'),
        ),
        VideoPlayerView(
          path: 'assets/videos/level_2/3_3.mp4',
          text: "2_3",
          description: "Never gonna give you up never gonna let you down",
          overlay: Thumbnail('assets/thumbnails/level_2/3_3.png'),
        ),
      ],
    ),
    'isExpanded': false,
    'isPlayed': false
  }
];

class Levels extends StatefulWidget {
  const Levels({Key? key}) : super(key: key);

  @override
  _LevelsState createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
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
                  backgroundColor: Colors.white,
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
  const VideoPlayerView(
      {super.key,
      required this.path,
      required this.text,
      required this.description,
      required this.overlay});

  final String path;
  final String text;
  final String description;
  final Widget overlay;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  bool isClicked = false;

  Future initializeVideo() async {
    videoPlayerController = VideoPlayerController.asset(
      widget.path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );

    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );
    setState(() {});
  }

  @override
  void initState() {
    initializeVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isClicked == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 800,
            margin: const EdgeInsets.only(top: 50.0, bottom: 50.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 153, 152, 152),
              border: Border.all(
                  width: 2, color: Color.fromARGB(255, 153, 152, 152)),
            ),
            child: InkWell(
                child: widget.overlay,
                onTap: () {
                  setState(() {
                    isClicked = true;
                  });
                }),
          ),
          VideoText(widget.text, widget.description)
        ],
      );
    }
    if (chewieController == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            margin: const EdgeInsets.only(top: 50.0, bottom: 100.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  MaterialColor(0xFF409AB5, color)),
            ),
          ),
          Text(
            widget.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: 800,
          margin: const EdgeInsets.only(top: 50.0, bottom: 50.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 153, 152, 152),
            border:
                Border.all(width: 2, color: Color.fromARGB(255, 153, 152, 152)),
          ),
          child: Chewie(
            controller: chewieController!,
          ),
        ),
        VideoText(widget.text, widget.description)
      ],
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}

class VideoText extends StatelessWidget {
  VideoText(this.text, this.description);

  final String text;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            this.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 5.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: 2, color: Color.fromARGB(255, 153, 152, 152)),
            ),
          ),
          child: Text(
            this.description,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

class Thumbnail extends StatelessWidget {
  Thumbnail(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
