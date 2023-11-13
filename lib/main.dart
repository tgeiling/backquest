import 'dart:developer';
import 'dart:io';

import 'package:backquest/character.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_provider.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';
import 'package:giff_dialog/giff_dialog.dart';
import 'videos.dart' as videos;
import 'character.dart';
import 'users.dart';
import 'trophy.dart';
import 'videos.dart';
import 'form.dart';
import 'quests.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_icon_shadow/flutter_icon_shadow.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

List<Map<String, dynamic>> _videoList = videos.getVideoList();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(
    ChangeNotifierProvider(
      create: (context) => FirebaseService(),
      child: MyApp(),
    ),
  );
}

final scakey = new GlobalKey<_MyStatefulWidgetState>();

class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF409AB5, color),
      ),
      home: MyStatefulWidget(key: scakey),
    );
  }
}

class Scoring extends StatefulWidget {
  const Scoring({
    super.key,
    this.scoringCount = "000",
  });

  final String scoringCount;

  @override
  State<Scoring> createState() => _ScoringState();
}

class _ScoringState extends State<Scoring> {
  late String value;
  late bool check;

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    return StreamBuilder<Map<String, dynamic>>(
      stream: firebaseService.getUserDataStream(),
      builder: (context, snapshot) {
        print('Connection State: ${snapshot.connectionState}');
        print('Data: ${snapshot.data}');

        if (snapshot.hasData) {
          final userData = snapshot.data!;

          var totalLevels = userData['totalLevels'];
          if (totalLevels is int) {
            check = totalLevels >= 10;
          } else if (totalLevels is String) {
            check = int.parse(totalLevels) >= 10;
          }

          value = check
              ? "0${userData['totalLevels']}"
              : "00${userData['totalLevels']}";

          return Row(
            children: <Widget>[
              Text("00${userData['totalLevels'] ?? 0}"),
              Container(
                width: 40,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.centerLeft,
                    image: AssetImage('assets/fireIcon.png'),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class IconRow extends StatefulWidget {
  const IconRow({super.key});

  @override
  State<IconRow> createState() => _IconRowState();
}

class _IconRowState extends State<IconRow> {
  _MyStatefulWidgetState qwe = _MyStatefulWidgetState();

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(0);
            },
            child: CustomIcon(
                active: scakey.currentState!._selectedIndex == 0 ? true : false,
                icon: Icons.home_outlined),
          ),
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(1);
            }, // Image tapped
            child: CustomIcon(
                active: scakey.currentState!._selectedIndex == 1 ? true : false,
                icon: Icons.timeline_outlined),
          ),
          /*GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(2);
            }, // Image tapped
            child: Image.asset(
              'assets/questsIcon.png',
              fit: BoxFit.cover, // Fixes border issues
            ),
          ),*/
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(2);
              scakey.currentState!._selectedIndex;
            }, // Image tapped
            child: CustomIcon(
                active: scakey.currentState!._selectedIndex == 2 ? true : false,
                icon: Icons.feedback_outlined),
          ),
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(3);
            }, // Image tapped
            child: CustomIcon(
                active: scakey.currentState!._selectedIndex == 3 ? true : false,
                icon: Icons.person_outline),
          ),
        ]);
  }
}

class CustomIcon extends StatelessWidget {
  final bool active;
  final IconData icon;

  CustomIcon({required this.active, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: active
          ? IconShadow(
              Icon(
                icon,
                size: 48,
                color: Colors.grey.shade300,
              ),
              shadowColor: Colors.black,
            )
          : Icon(
              icon,
              size: 48,
              color: Colors.grey.shade300,
            ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: MaterialColor(0xFF409AB5, color),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            offset: Offset(
                0, -2), // Offset for the shadow (0, -2) moves it 2 pixels up
            blurRadius: 4, // Spread of the shadow
            spreadRadius: 0, // Spread radius of the shadow
          ),
        ],
      ),
      child: IconRow(),
    );
  }
}

class MapVerticalExample extends StatefulWidget {
  const MapVerticalExample({Key? key}) : super(key: key);

  @override
  State<MapVerticalExample> createState() => _MapVerticalExampleState();
}

class _MapVerticalExampleState extends State<MapVerticalExample> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseService? firebaseService;

  void _showWelcomeDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dialogShown = prefs.getBool('welcomeDialogShown') ?? false;

    if (!dialogShown) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hier Klicken \n zum Starten',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Transform.rotate(
                    angle: -45 * 3.14159265 / 180,
                    child: Icon(
                      Icons.arrow_downward,
                      size: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Update SharedPreferences to mark the welcome dialog as shown
      prefs.setBool('welcomeDialogShown', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: GameLevelsScrollingMap.scrollable(
        imageUrl: "assets/levelmap.png",
        direction: Axis.vertical,
        reverseScrolling: true,
        pointsPositionDeltaX: 25,
        pointsPositionDeltaY: 25,
        svgUrl: 'assets/levelmap.svg',
        points: points,
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firebaseService = Provider.of<FirebaseService>(context, listen: false);
      fillTestData();
    });
    _showWelcomeDialog();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

List<PointModel> points = [];

void fillTestData() {
  for (int i = 1; i < 26; i++) {
    points.add(PointModel(26, testWidget(i)));
  }
}

Widget testWidget(int order) {
  return Consumer<FirebaseService>(builder: (context, firebaseService, _) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: firebaseService.getLevelDataStream(),
      builder: (context, snapshot) {
        print('Connection State: ${snapshot.connectionState}');
        print('Data: ${snapshot.data}');

        if (snapshot.hasData) {
          final levelData = snapshot.data!;
          int totalLevels = 3;

          levelData.forEach((key, value) {
            if (value == true) {
              totalLevels++;
            }
          });

          // Decrease the value of order by one
          int decreasedOrder = order - 1;
          bool complete = levelData['level$order'] ?? false;
          bool locked = order > totalLevels;

          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasError) {
              //firebaseService.refreshData();
            } else {
              // Connection error occurred

              // Check if it's a network connectivity issue
              if (snapshot.error is SocketException) {
                firebaseService.refreshData();
              } else {
                // Handle other types of connection errors
              }
            }
          }

          return InkWell(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  complete
                      ? "assets/map_point_green.png"
                      : locked || order > 19
                          ? "assets/map_point_locked.png" // Image for locked state
                          : "assets/map_point.png",
                  fit: BoxFit.fitWidth,
                  width: 90,
                ),
                Container(
                    padding: const EdgeInsets.only(bottom: 33.0),
                    child: Stack(
                      children: <Widget>[
                        Text(
                          "$order",
                          style: TextStyle(
                            fontSize: 36,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          "$order",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 36),
                        ),
                      ],
                    ))
              ],
            ),
            onTap: () {
              if (!locked && order <= 20) {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10.0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullView(
                                          order: decreasedOrder,
                                          path: _videoList[decreasedOrder]
                                              ['path'],
                                          text: _videoList[decreasedOrder]
                                              ['text'],
                                          shortDescription:
                                              _videoList[decreasedOrder]
                                                  ['shortDescription'],
                                          description:
                                              _videoList[decreasedOrder]
                                                  ['description'],
                                          overlay: _videoList[decreasedOrder]
                                              ['overlay'],
                                          numberDone: levelData[
                                              'levelNumberDone$order'],
                                          lastDone:
                                              levelData['levelLastDone$order'],
                                          complete: complete,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      "assets/thumbnails/$order.gif",
                                      fit: BoxFit.cover,
                                      width: 300,
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _videoList[decreasedOrder]['text'],
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.timer,
                                            size: 64,
                                            color: Colors.grey
                                                .shade800), // Increased icon size
                                        SizedBox(
                                            width:
                                                20), // Increased spacing between icons
                                        Icon(Icons.sports_tennis,
                                            size: 64,
                                            color: Colors.grey
                                                .shade800), // Increased icon size
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Added spacing between rows
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            '${_videoList[decreasedOrder]["duration"]} min',
                                            style: TextStyle(
                                                fontSize:
                                                    20)), // Increased text size
                                        SizedBox(
                                            width:
                                                20), // Increased spacing between text
                                        Text('Matte',
                                            style: TextStyle(
                                                fontSize:
                                                    20)), // Increased text size
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullView(
                                              order: decreasedOrder,
                                              path: _videoList[decreasedOrder]
                                                  ['path'],
                                              text: _videoList[decreasedOrder]
                                                  ['text'],
                                              shortDescription:
                                                  _videoList[decreasedOrder]
                                                      ['shortDescription'],
                                              description:
                                                  _videoList[decreasedOrder]
                                                      ['description'],
                                              overlay:
                                                  _videoList[decreasedOrder]
                                                      ['overlay'],
                                              numberDone: levelData[
                                                  'levelNumberDone$order'],
                                              lastDone: levelData[
                                                  'levelLastDone$order'],
                                              complete: complete,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        color: Colors
                                            .white, // Set the background color of the container
                                        child: Image.asset(
                                          'assets/button_start.png',
                                          width:
                                              100, // Adjust the width and height as needed
                                          height: 100,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Image.asset(
                                  'assets/close.png',
                                  width: 40,
                                  height: 40,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  });
}

//Video tracker um zu erkennen ob der Nutzer das Video geguckt hat.

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  bool _videoCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController?.addListener(_videoPlayerListener);
  }

  void _videoPlayerListener() {
    if (_videoPlayerController!.value.position >=
        _videoPlayerController!.value.duration) {
      _videoCompleted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Video Player'),
        ),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
            ElevatedButton(
              onPressed: () {
                if (_videoCompleted) {
                } else {}
              },
              child: Text(_videoCompleted ? 'Continue' : 'Retry'),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({required Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  final scaKey = GlobalKey<_MyStatefulWidgetState>();
  bool isLoggedIn = false;

  List<Widget> _widgetOptions = <Widget>[
    MapVerticalExample(),
    videos.Levels(),
    FeedbackFormWidget(),
    UserTabWidget()
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    if (firebaseService.user != null) {
      return Scaffold(
        key: scaKey,
        appBar: AppBar(
          leading: Image.asset('assets/bqlogo2.jpeg'),
          leadingWidth: 250,
          title: Scoring(),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: Footer(),
      );
    }
    return LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationMessage;
  String? _errorMessage;

  bool _isRegistration = false;
  bool _acceptPrivacyPolicy = false;
  bool _agreeToTerms = false;

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _verificationMessage = 'Login successful.';
        _errorMessage = null;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _verificationMessage = null;
        _errorMessage = e.message;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _registerWithEmailAndPassword() async {
    if (!_acceptPrivacyPolicy || !_agreeToTerms) {
      // Show an error message or take appropriate action
      return;
    }

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final String userId = userCredential.user!.uid;

      final ageDateFormat = DateFormat('d. MMMM y');
      final ageDateTime = ageDateFormat.parse(_ageController.text);

      await _firestore.collection('Userdata').doc(userId).set({
        'Age': DateFormat('dd. MMMM y').format(ageDateTime),
        'Firstname': _firstNameController.text,
        'Lastname': _lastNameController.text,
        'totalLevels': 0,
        'acceptedAGB': _acceptPrivacyPolicy,
        'acceptedDatenschutz': _agreeToTerms,
      });

      Map<String, dynamic> levels = {};
      for (int i = 1; i <= 30; i++) {
        levels['level$i'] = false;
        levels['levelNumberDone$i'] = 0;
        levels['levelLastDone$i'] = 0;
      }

      await _firestore.collection('Leveldata').doc(userId).set(levels);

      setState(() {
        _verificationMessage =
            'Registration successful. Please login with your new account.';
        _errorMessage = null;
        _isRegistration = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _verificationMessage = null;
        _errorMessage = e.message;
      });
    } catch (e) {
      print(e);
    }
  }

  void _switchForm() {
    setState(() {
      _isRegistration = !_isRegistration;
      _verificationMessage = null;
      _errorMessage = null;
    });
  }

  _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistration ? 'Registration' : 'Login'),
        leading: _isRegistration
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _switchForm,
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gebe deine E-Mail ein';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Passwort",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gebe dein Passwort ein';
                  }
                  return null;
                },
              ),
              if (_isRegistration) ...[
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Vorname",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gebe deinen Vornamen ein';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Nachname",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gebe deinen Nachnamen ein';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Alter",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        enabled: false, // Disable manual input
                      ),
                    ),
                    SizedBox(
                        width:
                            10), // Add spacing between the TextFormField and the button
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );

                        if (selectedDate != null) {
                          setState(() {
                            _ageController.text =
                                DateFormat('dd. MMMM y').format(selectedDate);
                          });
                        }
                      },
                      child: Icon(
                          Icons.calendar_today), // You can use any icon here
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptPrivacyPolicy,
                      onChanged: (value) {
                        setState(() {
                          _acceptPrivacyPolicy = value ?? false;
                        });
                      },
                    ),
                    Text('Datenschutzbestimmung akzeptieren'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Text('AGB zustimmen'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _launchURL('https://backquest.online/privacy-policy/');
                  },
                  child: Text(
                    'Datenschutzerklärung',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                if (!_acceptPrivacyPolicy || !_agreeToTerms)
                  Text(
                    'Bitte akzeptiere die Datenschutzbestimmung und AGB.',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
              ],
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isRegistration
                    ? _registerWithEmailAndPassword
                    : _signInWithEmailAndPassword,
                child: Text(_isRegistration ? 'Registrieren' : 'Login'),
              ),
              SizedBox(height: 16.0),
              if (!_isRegistration)
                ElevatedButton(
                  onPressed: _switchForm,
                  child: Text('Registrieren'),
                ),
              if (_verificationMessage != null)
                Text(
                  _verificationMessage!,
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  _launchURL('https://backquest.online/privacy-policy/');
                },
                child: Text(
                  'Datenschutzerklärung',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
