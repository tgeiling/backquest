library videos;

import 'dart:io';

import 'package:backquest/data_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:giff_dialog/giff_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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

List<Map<String, dynamic>> _videoList = [
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834199066/rendition/720p/file.mp4?loc=external&signature=7ccaddbc42656a8dabed22fd305723431732333803baa30812e0ef827ee38028',
    'text': "Der Anfang deiner Rückengesundheit: Schritt für Schritt",
    'description':
        "Willkommen bei BackQuest, deinem persönlichen Begleiter auf dem Weg zu einem gesunden Rücken! Mache mit diesem Video den ersten Schritt und entscheide dich für eine positive Veränderung. " +
            "Dieses Video ist der Beginn einer neuen Gewohnheit. Ich weiß, dass es nicht immer einfach ist, aber sei geduldig mit dir selbst. Jeder kleine Fortschritt ist ein Schritt in die richtige Richtung. " +
            "Manchmal wenn wir einen neuen Weg in unserem Leben einschlagen wollen fühlt es sich an als würden wir in tiefem Schlamm laufen. Der unsere Schuhe mit jedem Schritt schwerer werden lässt und jeder Schritt mehr Anstrengung kostet. Gerade dann lohnt es sich aufzuschauen, manchmal sieht man erst dann dass es noch einen anderen Weg gibt. " +
            "BackQuest – Der einfache Weg zur Rückengesundheit",
    'overlay': Thumbnail('assets/thumbnails/level_1/1_1.jpeg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834201612/rendition/720p/file.mp4?loc=external&signature=4be3cb1a0d128710d08a3f60fd3c18c0d0df257ee53d7484f9af9732279eb124',
    'text': "Entspannter Atem – Entspannter Rücken",
    'description':
        "Wie du im letzten Video gemerkt hast starten wir am Anfang oft mit einer kurzen Atemmethode. Gönn dir damit eine wohlverdiente Auszeit vom Alltagsstress und schenke dir und deinem Rücken einen Moment der Ruhe. " +
            "Aktiviere damit dein parasympathisches Nervensystem. Spüre, wie der Stress von dir abfällt und eine Atmosphäre von Ruhe und Gelassenheit sich in dir ausbreitet. Erst entspannt entfalten die folgenden Dehn- und Mobilisationsübungen ihr ganzes Potenzial. ",
    'overlay': Thumbnail('assets/thumbnails/level_1/1_2.jpg'),
  },
  {
    'path': 'assets/videos/level_1/1_3.mp4',
    'text': "Roll dich gesund",
    'description':
        "Bereit für ein Abenteuer, das deinen Rücken stärkt und dich von Schmerzen befreit? In diesem Video lernst du die faszinierende Welt des Baby Rollings kennen, einer Methode zur Prävention von Rückenschmerzen. Es basiert auf der Bewegungsentwicklung von Säuglingen und Kleinkindern, die das Rollen erlernen, um ihre motorischen Fähigkeiten zu entwickeln. " +
            "Leider haben viele Erwachsene verlernt sich ohne die Kraft ihrer Beine zu rollen. Versuche die Bewegung nur über die Bewegung deiner Arme einzuleiten und spüre, wie deine Rumpfmuskulatur die Bewegung weiter überträgt. Deine Körperwahrnehmung, Koordination und Wohlbefinden sich verbessern. ",
    'overlay': Thumbnail('assets/thumbnails/level_1/1_3.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834206245/rendition/720p/file.mp4?loc=external&signature=5a565e80adb8ad094c3ee29099922c508aac2de8dbacac5eee55761611529ee5',
    'text':
        "Proximale Stabilität für distale Mobilität: Stärke deinen Kern für bessere Beweglichkeit",
    'description':
        "Bereit, deinen Körper auf ein neues Level der Beweglichkeit zu bringen? In diesem Video erfährst du alles über das Prinzip der proximalen Stabilität für distale Mobilität. " +
            "Dieses grundlegende Konzept der Sport- und Physiotherapie besagt, dass eine stabile und kontrollierte Rumpfmuskulatur (proximale Stabilität) die Vorraussetung schafft, dass die Muskeln und Gelenke in den entfernten Körperregionen (distale Mobilität) frei und effizient arbeiten können. " +
            "Stärke deinen Kern und erlebe die Freude an einem geschmeidigen und beweglichen Körper!",
    'overlay': Thumbnail('assets/thumbnails/level_2/2_1.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834208309/rendition/720p/file.mp4?loc=external&signature=43647bcbdbab7cd1066b2710ae2e2587531e15dcc0b8d4dcce11ccfa06a87b5d',
    'text': "Faszienrollen ohne Rolle: Befreie deinen Rücken mit Bodenübungen",
    'description':
        "Bist du bereit, deinen Rücken zu befreien und dich von Verspannungen zu lösen? In diesem Video zeigen wir dir, wie du Faszienrollen ganz ohne Rolle verwenden kannst – mit einfachen Bodenübungen für deinen Rücken. " +
            "Du brauchst keine teure Ausrüstung, denn der Boden wird zu deinem besten Freund. Wir führen dich durch eine Reihe von gezielten Übungen, bei denen du deinen Körper sanft auf dem Boden bewegst, um deine Faszien zu stimulieren und Verspannungen zu lösen. " +
            "Spüre, wie sich dein Rücken mit jedem Atemzug freier und leichter anfühlt. Sei dabei und entdecke die Kraft des Bodens für eine junge und bewegliche Wirbelsäule! ",
    'overlay': Thumbnail('assets/thumbnails/level_2/2_2.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834210625/rendition/720p/file.mp4?loc=external&signature=3f9b6676bff9f989c2c87d29742f0405b07ad2888ab77beb8d3ed0bf9d594e43',
    'text': "Brace yourself – not only winter is coming",
    'description':
        "Indem du deinen Bauchnabel zur Wirbelsäule ziehst, spannst du die tief liegende Bauchmuskulatur, insbesondere den Transversus Abdominis, an. Diese Muskulatur fungiert als eine Art natürlicher Korsett um die Wirbelsäule herum. Durch die Aktivierung des Transversus Abdominis wird die intraabdominale Druckerzeugung erhöht, was zu einer besseren Stabilität der Wirbelsäule führt. " +
            "Die sogenannte „Bracing“- Technik wird eingesetzt um die Stabilität und Ausrichtung der Wirbelsäule während einer Übung zu verbessern. Du wirst lernen, wie du die korrekte Ausrichtung deines Beckens unterstützt und eine neutrale Wirbelsäulenposition förderst, um übermäßige Belastungen und Kompensationen zu vermeiden. ",
    'overlay': Thumbnail('assets/thumbnails/level_2/2_3.jpeg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834693321/rendition/720p/file.mp4?loc=external&signature=6261bb05c87834a21743844c19210583f654341e20bd246f7341483baf24c580',
    'text': "Wer anspannen kann muss auch loslassen können",
    'description':
        "Willkommen zu einer neuen Perspektive auf Rückengesundheit! In diesem Video erkunden wir das wichtige Zusammenspiel von Anspannen und Loslassen, speziell für Menschen mit Rückenschmerzen. " +
            "Studien zeigen, dass während Kraftübungen die Bracing-Technik entscheidend ist. Doch wir wissen auch, dass Menschen mit Rückenschmerzen oft einen überspannten Körper haben und es ihnen schwerfällt, loszulassen. Deshalb ist es von großer Bedeutung, das Gleichgewicht zwischen Anspannen und Loslassen zu finden. " +
            "Unser Ziel ist es, dir zu zeigen, dass ein gesunder Rücken nicht nur von körperlicher Stärke, sondern auch von der Fähigkeit abhängt, loszulassen und zu entspannen. Finde die Balance zwischen Anspannen und Loslassen, um deinem Rücken eine optimale Unterstützung zu bieten und deinen Alltag mit Leichtigkeit zu meistern. " +
            "P.S. Videoqualität wird nach der ersten Minute besser. ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_1.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834162030/rendition/720p/file.mp4?loc=external&signature=b4c985a0d594777cc270695923946d1e62da641585ea3b43ead4a798104e194b',
    'text': "Gesunde Hüfte, Starker Rücken: Der Joint-by-Joint Ansatz",
    'description':
        "Entdecke den Joint-by-Joint Ansatz und lerne, wie die Mobilität der Hüfte eine wichtige Rolle bei der Prävention von Rückenschmerzen spielt. In diesem Video tauchen wir in die faszinierende Welt der Gelenke ein und zeigen dir, wie du deine Hüfte mobilisieren kannst, um deinen Rücken zu stärken. " +
            "Der Joint-by-Joint Ansatz betont die unterschiedlichen Anforderungen an die Gelenke unseres Körpers. Insbesondere benötigt die Hüfte eine gute Mobilität, während die Lendenwirbelsäule (LWS) eher stabile Eigenschaften aufweisen sollte. Wenn die Hüftmobilität eingeschränkt ist, versucht die LWS diese Einschränkung zu kompensieren, indem sie sich übermäßig bewegt. Diese Überlastung kann zu Rückenschmerzen führen. " +
            "Bist du bereit, die Rolle deiner Hüfte bei der Prävention von Rückenschmerzen zu erkunden? Dann komm mit uns auf diese spannende Reise zur Mobilität und Stabilität. Lass uns deine Hüfte befreien und deinem Rücken eine solide Basis geben! ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_2.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834164918/rendition/720p/file.mp4?loc=external&signature=45d1c93d42791c347b16796a68b2589f2afda2359c1be513a22d14be01c16499',
    'text':
        "Lösche den Brand statt die Batterie aus dem Rauchmelder zu ziehen.",
    'description':
        "Stell dir vor, dein Körper ist wie ein Haus und Rückenschmerzen sind wie ein schrillender Rauchmelder. Du könntest versucht sein, den Alarm einfach abzustellen, aber was ist mit der eigentlichen Ursache des Problems? " +
            "Wenn wir Schmerzen im Rücken verspüren, ist es wie der Alarm, der auf eine Verletzung oder ein anderes Problem hinweist. Es ist wichtig, den Schmerz nicht einfach zu ignorieren oder oberflächlich zu behandeln. Stell dir vor du schmierst eine Schmerzsalbe auf deinen Rücken oder nimmst einfach nur Schmerzmedikamente ein ohne die Hüfte oder deinen Schultergürtel zu untersuchen. Das wäre so, als würdest du die Batterie aus dem Rauchmelder entfernen, anstatt nach der eigentlichen Ursache des Alarms zu suchen. ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834168208/rendition/720p/file.mp4?loc=external&signature=bd61c59014714c30bb3c76177d0f892a53aeff8945fabe137d8b630ae6eb4ced',
    'text': "Letztes Level Stufe 1",
    'description':
        "Herzlichen Glückwunsch! Du hast die erste Stufe der motorischen Entwicklung gemeistert und begibst dich nun in eine neue Phase. Es wird Zeit sich ein Stockwerk nach oben zu Bewegen und den Vierfüßlerstand zu meistern. " +
            "Während du dich auf diese neue Etappe vorbereitest, möchten wir dich ermutigen, das Gelernte anzuwenden und deine Fortschritte zu feiern. Deine Körperbeherrschung und motorischen Fähigkeiten werden immer besser. " +
            "Mach weiter so!",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834170796/rendition/720p/file.mp4?loc=external&signature=d01fd0500cd3594b0f3cb62aef6642f9d7ffbeb93d3e6f950827c8ffed9ab49a',
    'text': "2_1",
    'description':
        "Herzlichen Glückwunsch! Du hast die erste Stufe der motorischen Entwicklung gemeistert und begibst dich nun in eine neue Phase. Es wird Zeit sich ein Stockwerk nach oben zu Bewegen und den Vierfüßlerstand zu meistern. " +
            "Während du dich auf diese neue Etappe vorbereitest, möchten wir dich ermutigen, das Gelernte anzuwenden und deine Fortschritte zu feiern. Deine Körperbeherrschung und motorischen Fähigkeiten werden immer besser. " +
            "Mach weiter so!",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834694810/rendition/720p/file.mp4?loc=external&signature=50e709051251e35f284ba73d67c35d9a8547a7615dff76a69b72129ab794f76b',
    'text': "2_2",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834697298/rendition/720p/file.mp4?loc=external&signature=7a038d31756b419cd3322d5fabee05f186cf77787a62f045b7a41d8f527c9c10',
    'text': "2_3",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834174282/rendition/720p/file.mp4?loc=external&signature=76a45c181958e2952e4ed4e308c3eb3330384d6651e01f8825290af73521a129',
    'text': "2_4",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834178314/rendition/720p/file.mp4?loc=external&signature=4b1cd078f73715c70aef6738fa0a1f1e2ad63800490a752fd632d80e1cb24e27',
    'text': "2_5",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834182013/rendition/720p/file.mp4?loc=external&signature=d48b455115b96f5456c69fa739379bea2d6f635e7944caa9e57b9743ee233a4b',
    'text': "2_6",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834185765/rendition/720p/file.mp4?loc=external&signature=a3782acb43f626a0230536755a0dd0991c05ffba28dbdef057b7920b1c8ed351',
    'text': "2_7",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834189198/rendition/720p/file.mp4?loc=external&signature=5c6a59cd918e123538058e8d7e81f59b976f2b5acc76594a27f4e5a4a360704f',
    'text': "2_8",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834192567/rendition/720p/file.mp4?loc=external&signature=adb2f230f7c11b513fd96d5a86e48308aeebf7dfdd6f89279b3b299344a1d1e0',
    'text': "2_9",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834195887/rendition/720p/file.mp4?loc=external&signature=fbe59575c124e4b9a00e49619e82925656ae1478912e7d2c0423bb4562f39787',
    'text': "2_10",
    'description': "Never gonna give you up never gonna let you down",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
];

List<Map<String, dynamic>> _levelList = [
  {
    'id': 1,
    'title': 'Level 1',
    'description': Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPlayerView(
          path: _videoList[0]['path'],
          text: _videoList[0]['text'],
          description: _videoList[0]['description'],
          overlay: _videoList[0]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[1]['path'],
          text: _videoList[1]['text'],
          description: _videoList[1]['description'],
          overlay: _videoList[1]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[2]['path'],
          text: _videoList[2]['text'],
          description: _videoList[2]['description'],
          overlay: _videoList[2]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[3]['path'],
          text: _videoList[3]['text'],
          description: _videoList[3]['description'],
          overlay: _videoList[3]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[4]['path'],
          text: _videoList[4]['text'],
          description: _videoList[4]['description'],
          overlay: _videoList[4]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[5]['path'],
          text: _videoList[5]['text'],
          description: _videoList[5]['description'],
          overlay: _videoList[5]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[6]['path'],
          text: _videoList[6]['text'],
          description: _videoList[6]['description'],
          overlay: _videoList[6]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[7]['path'],
          text: _videoList[7]['text'],
          description: _videoList[7]['description'],
          overlay: _videoList[7]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[8]['path'],
          text: _videoList[8]['text'],
          description: _videoList[8]['description'],
          overlay: _videoList[8]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[9]['path'],
          text: _videoList[9]['text'],
          description: _videoList[9]['description'],
          overlay: _videoList[9]['overlay'],
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
          path: _videoList[10]['path'],
          text: _videoList[10]['text'],
          description: _videoList[10]['description'],
          overlay: _videoList[10]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[11]['path'],
          text: _videoList[11]['text'],
          description: _videoList[11]['description'],
          overlay: _videoList[11]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[12]['path'],
          text: _videoList[12]['text'],
          description: _videoList[12]['description'],
          overlay: _videoList[12]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[13]['path'],
          text: _videoList[13]['text'],
          description: _videoList[13]['description'],
          overlay: _videoList[13]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[14]['path'],
          text: _videoList[14]['text'],
          description: _videoList[14]['description'],
          overlay: _videoList[14]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[15]['path'],
          text: _videoList[15]['text'],
          description: _videoList[15]['description'],
          overlay: _videoList[15]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[16]['path'],
          text: _videoList[16]['text'],
          description: _videoList[16]['description'],
          overlay: _videoList[16]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[17]['path'],
          text: _videoList[17]['text'],
          description: _videoList[17]['description'],
          overlay: _videoList[17]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[18]['path'],
          text: _videoList[18]['text'],
          description: _videoList[18]['description'],
          overlay: _videoList[18]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[19]['path'],
          text: _videoList[19]['text'],
          description: _videoList[19]['description'],
          overlay: _videoList[19]['overlay'],
        ),
      ],
    ),
    'isExpanded': false,
    'isPlayed': false
  }
];

getVideoList() {
  return _videoList;
}

class Levels extends StatefulWidget {
  const Levels({Key? key}) : super(key: key);

  @override
  _LevelsState createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  const VideoPlayerView({
    Key? key,
    this.order,
    required this.path,
    required this.text,
    required this.description,
    required this.overlay,
  }) : super(key: key);

  final int? order;
  final String path;
  final String text;
  final String description;
  final Widget overlay;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService();

  String? userId;

  int level = 0;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  bool isClicked = false;
  Duration? videoDuration;

  Future<void> initializeVideo() async {
    /*videoPlayerController = VideoPlayerController.asset(
      widget.path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );*/

    videoPlayerController = VideoPlayerController.network(
      widget.path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );

    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: false,
      looping: false,
    );
    setState(() {});

    userId = await getUserId();

    videoPlayerController!.addListener(videoProgressListener);
  }

  void updateLevel() async {
    int increasedOrder = widget.order! + 1;
    String levelField = 'level${increasedOrder}';
    bool completionStatus = true;
    int totalLevels = 0;

    Map<String, dynamic> leveldataUpdate = {
      levelField: completionStatus,
    };

    DocumentSnapshot leveldataSnapshot = await FirebaseFirestore.instance
        .collection('Leveldata')
        .doc(userId)
        .get();

    if (leveldataSnapshot.exists) {
      Map<String, dynamic>? levelData =
          leveldataSnapshot.data() as Map<String, dynamic>?;

      levelData!.forEach((key, value) {
        if (value == true) {
          totalLevels++;
        }
      });
    }

    Map<String, dynamic> userdataUpdate = {
      'totalLevels': totalLevels,
    };

    FirebaseFirestore.instance
        .collection('Leveldata')
        .doc(userId)
        .set(leveldataUpdate, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection('Userdata')
        .doc(userId)
        .set(userdataUpdate, SetOptions(merge: true));

    // Update local data
    //firebaseService.saveDataLocally(leveldataUpdate);
    //firebaseService.saveDataLocally(userdataUpdate);
  }

  void videoProgressListener() {
    if (chewieController != null) {
      final position = chewieController!.videoPlayerController.value.position;
      final duration = chewieController!.videoPlayerController.value.duration;

      if (position >= duration * 0.5) {
        updateLevel();
      }
    }
  }

  Future<String?> getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isClicked == false) {
      return Column(
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
                    initializeVideo();
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
        children: [
          Container(
            alignment: Alignment.center,
            height: 100,
            width: 50,
            margin: const EdgeInsets.only(top: 100.0, bottom: 100.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  MaterialColor(0xFF409AB5, color)),
            ),
          ),
          VideoText(widget.text, widget.description)
        ],
      );
    }
    return Column(
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
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}

class VideoText extends StatefulWidget {
  VideoText(this.text, this.description);

  final String text;
  final String description;

  @override
  _VideoTextState createState() => _VideoTextState();
}

class _VideoTextState extends State<VideoText> {
  bool showDescription = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showDescription = !showDescription;
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 2,
                  color: Color.fromARGB(255, 153, 152, 152),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showDescription
                          ? 'Close Description'
                          : 'Open Description',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      showDescription
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20.0,
                      color: Colors.black,
                    ),
                  ],
                ),
                if (showDescription)
                  Container(
                    constraints: BoxConstraints(maxHeight: 250),
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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

class FullView extends StatelessWidget {
  const FullView({
    Key? key,
    this.order,
    required this.path,
    required this.text,
    required this.description,
    required this.overlay,
  }) : super(key: key);

  final int? order;
  final String path;
  final String text;
  final String description;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(text),
      ),
      body: Column(
        children: [
          Center(
            child: VideoPlayerView(
              order: order,
              path: path,
              text: "",
              description: description,
              overlay: overlay,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              int increasedOrder = order! + 1;
              final firebaseService =
                  Provider.of<FirebaseService>(context, listen: false);
              final levelDataStream = firebaseService.getLevelDataStream();

              levelDataStream.listen((levelData) {
                if (levelData.containsKey('level$increasedOrder')) {
                  bool isLevelComplete =
                      levelData['level$increasedOrder'] ?? false;
                  if (isLevelComplete) {
                    showDialog(
                      context: context,
                      builder: (_) => AssetGiffDialog(
                        image: Image.asset(
                          "assets/completed.gif",
                          fit: BoxFit.fitWidth,
                          width: 90,
                        ),
                        title: Text(
                          "Level Abgeschlossen",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        description: Text(
                          "qweqweqweqweqwe",
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                        entryAnimation: EntryAnimation.top,
                        onOkButtonPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AssetGiffDialog(
                        image: Image.asset(
                          "assets/not.png",
                          fit: BoxFit.fitWidth,
                          width: 90,
                        ),
                        title: Text(
                          "Level Nicht geschafft",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        description: Text(
                          "qweqweqweqweqwe",
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                        entryAnimation: EntryAnimation.top,
                        onOkButtonPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    );
                  }
                }
              });
            },
            child: const Text('Abschließen'),
          ),
        ],
      ),
    );
  }
}
