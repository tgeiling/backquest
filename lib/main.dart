import 'package:flutter/material.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stroke_text/stroke_text.dart';

import 'stats.dart';
import 'video.dart';
import 'questionaire.dart';
import 'elements.dart';
import 'auth.dart';

class LevelNotifier with ChangeNotifier {
  Map<int, Level> _levels = {};

  Map<int, Level> get levels => _levels;

  int get completedLevels =>
      _levels.values.where((level) => level.isDone).length;

  LevelNotifier() {
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Define your levels here
    Map<int, Level> tempLevels = {
      1: Level(id: 1, description: "Description for level 1", minutes: 13),
      2: Level(id: 2, description: "Description for level 2", minutes: 12),
      3: Level(id: 3, description: "Description for level 3", minutes: 14),
      4: Level(id: 4, description: "Description for level 4", minutes: 11),
      5: Level(
          id: 5,
          description: "Description for level 5",
          reward: "Gold Coin",
          minutes: 6),
      6: Level(id: 6, description: "Description for level 6", minutes: 6),
      7: Level(id: 7, description: "Description for level 7", minutes: 6),
      8: Level(id: 8, description: "Description for level 8", minutes: 6),
      9: Level(id: 9, description: "Description for level 9", minutes: 6),
      10: Level(
          id: 10,
          description: "Description for level 10",
          reward: "Gold Coin",
          minutes: 6),
      11: Level(id: 11, description: "Description for level 11", minutes: 6),
      12: Level(id: 12, description: "Description for level 12", minutes: 6),
      13: Level(id: 13, description: "Description for level 13", minutes: 6),
      14: Level(id: 14, description: "Description for level 14", minutes: 6),
      15: Level(
          id: 15,
          description: "Description for level 15",
          reward: "Gold Coin",
          minutes: 6),
      16: Level(id: 16, description: "Description for level 16", minutes: 6),
      17: Level(id: 17, description: "Description for level 17", minutes: 6),
      18: Level(id: 18, description: "Description for level 18", minutes: 6),
      19: Level(id: 19, description: "Description for level 19", minutes: 6),
      20: Level(
          id: 20,
          description: "Description for level 20",
          reward: "Gold Coin",
          minutes: 6),
    };

    // Load isDone status from SharedPreferences and update tempLevels
    _levels = {
      for (var entry in tempLevels.entries)
        entry.key: Level(
          id: entry.value.id,
          description: entry.value.description,
          minutes: entry.value.minutes,
          reward: entry.value.reward,
          isDone: prefs.getBool('level_${entry.value.id}_isDone') ?? false,
        ),
    };

    notifyListeners();
  }

  void updateLevelStatus(int levelId, bool isDone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${levelId}_isDone', isDone);
    await prefs.setInt('completedLevels', completedLevels + 1);

    _levels[levelId]?.isDone = isDone;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LevelNotifier()),
        ChangeNotifierProvider(create: (context) => ProfilProvider()),
      ],
      child: MyApp(), // Your main app widget
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _authenticated = false;

  void _setAuthenticated(bool value) {
    setState(() {
      _authenticated = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duolingo Levels',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _authenticated
          ? MainScaffold()
          : LoginScreen(setAuthenticated: _setAuthenticated),
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent, // Removes the semi-transparent overlay
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.5 - 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ButtonTestScreen(),
            ),
            SizedBox(height: 90),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkQuestionnaireCompletion();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ProfilProvider>(context, listen: false)
          .loadInitialData();
    });
  }

  Future<void> _checkQuestionnaireCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final bool questionnaireCompleted =
        prefs.getBool('questionnaireCompleted') ?? false;

    if (!questionnaireCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => QuestionnaireScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        titleSpacing: 0,
        title: CompletedLevelsAppBar(),
      ), */
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Container(
            color: Color.fromRGBO(0, 59, 46, 0.9),
            child: LevelSelectionScreen(),
          ),
          ProfilPage(), // Ensure this widget is defined elsewhere
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        child: Column(
          children: [
            Container(
              // Grey line container
              height: 1, // Height of the line
              color: Colors.grey, // Color of the line
            ),
            Expanded(
              // SalomonBottomBar needs to be wrapped with Expanded inside Column
              child: SalomonBottomBar(
                currentIndex: _currentIndex,
                onTap: (i) {
                  _pageController.jumpToPage(i);
                },
                items: [
                  SalomonBottomBarItem(
                    icon: Image.asset(
                      'assets/homeIcon.png',
                      width: 40,
                      height: 40,
                    ),
                    title: Text("Main"),
                    selectedColor: Colors.blue,
                  ),
                  SalomonBottomBarItem(
                    icon: Image.asset(
                      'assets/barchartIcon.png',
                      width: 44,
                      height: 44,
                    ),
                    title: Text("Stats"),
                    selectedColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
          child: GestureDetector(
        onTap: () {
          _showModalBottomSheet(context);
        }, // Call this method to show the overlay
        child: PressableButton(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Icon(
            Icons.arrow_upward,
            color: Colors.white,
            size: 24,
          ),
        ),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Position the button at the bottom end
    );
  }
}

class ButtonTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Passen Sie Ihr Training an",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 1, // Adjust based on your button size
                children: <Widget>[
                  PressableButton(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Center(
                        child: Text("Fokus",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ))),
                  ),
                  PressableButton(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Center(
                        child: Text("Dauer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ))),
                  ),
                  PressableButton(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Center(
                        child: Text("Art",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ))),
                  ),
                  PressableButton(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Center(
                        child: Text("Ort",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ))),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            PressableButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoCombinerScreen(
                      levelId: 0, // Use the correct level ID here
                      levelNotifier:
                          Provider.of<LevelNotifier>(context, listen: false),
                      profilProvider:
                          Provider.of<ProfilProvider>(context, listen: false),
                    ),
                  ),
                );
              },
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Center(
                  child: Text("Jetzt starten",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedLevelsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    // Use a Container to wrap AppBar content and add a bottom border
    return Container(
      decoration: BoxDecoration(
        // Add a bottom border
        border: Border(
          bottom: BorderSide(
              color: Colors.grey, width: 2.0), // Grey line with 1.0 thickness
        ),
      ),
      child: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo on the left
            Image.asset('assets/logo.png',
                height: 20), // Adjust the height as needed

            Consumer<LevelNotifier>(
              builder: (context, levelNotifier, child) {
                // Calculate the number of completed levels
                int completedLevels = levelNotifier.completedLevels;

                return Row(
                  children: [
                    Image.asset('assets/crownIcon.png', height: 24),
                    SizedBox(width: 8),
                    Text("$completedLevels", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 20),
                    Image.asset('assets/fireIcon.png', height: 24),
                    SizedBox(width: 8),
                    Text("$completedLevels", style: TextStyle(fontSize: 20)),
                  ],
                );
              },
            ),
          ],
        ),
        centerTitle: false, // Align the title to the start
        elevation: 0, // Remove shadow if not needed
        backgroundColor: Colors
            .transparent, // Make AppBar background transparent to blend with Container
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + 1.0); // Default AppBar height + grey line height
}

class Level {
  final int id;
  final String description;
  final int minutes;
  final String reward;
  bool isDone;

  Level(
      {required this.id,
      required this.description,
      this.minutes = 15,
      this.reward = '',
      this.isDone = false});
}

class LevelSelectionScreen extends StatefulWidget {
  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final levelNotifier = Provider.of<LevelNotifier>(context);
    final levels = levelNotifier.levels;

    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemCount: levels.length,
      itemBuilder: (context, index) {
        int levelId = levels.keys.toList()[index];
        Level level = levels[levelId]!;

        int row = index % 4; // Adjust to 4 items per row
        int group =
            index ~/ 4; // Group index changes because of 4 items per group

        // Calculate padding for the snake pattern and 4 items per row
        bool isEvenGroup = group % 2 == 0;
        double startPadding, endPadding;
        if (isEvenGroup) {
          startPadding = MediaQuery.of(context).size.width / 8 * row;
          endPadding = MediaQuery.of(context).size.width / 8 * (3 - row);
        } else {
          startPadding = MediaQuery.of(context).size.width / 8 * (3 - row);
          endPadding = MediaQuery.of(context).size.width / 8 * row;
        }

        // Determine if this level is the next to be actionable
        bool isNext = false;
        if (!level.isDone) {
          // Find the highest 'done' level
          int? maxDoneLevelId = levels.entries
              .where((entry) => entry.value.isDone)
              .map((entry) => entry.key)
              .fold<int?>(
                  null,
                  (prev, element) => prev != null
                      ? (element > prev ? element : prev)
                      : element);

          // If no level is done yet, mark the first level as isNext
          if (maxDoneLevelId == null) {
            isNext =
                levelId == levels.keys.first; // true only for the first level
          } else {
            // If the current level is immediately after the last 'done' level
            if (levelId == maxDoneLevelId + 1) {
              isNext = true;
            }
          }
        }

        return Padding(
          padding: EdgeInsets.only(left: startPadding, right: endPadding),
          child: LevelCircle(
            level: level.id,
            onTap: () => _showLevelDialog(context, level),
            isTreasureLevel: level.id % 4 == 0,
            isDone: level.isDone,
            isNext: isNext, // Pass the isNext status
          ),
        );
      },
    );
  }

  void _showLevelDialog(BuildContext context, Level level) {
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
                              builder: (context) => VideoCombinerScreen(
                                    levelId: level.id,
                                    levelNotifier: Provider.of<LevelNotifier>(
                                        context,
                                        listen: false),
                                    profilProvider: Provider.of<ProfilProvider>(
                                        context,
                                        listen: false),
                                  )),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          "assets/thumbnails/${level.id}.gif",
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
                      "${level.description}",
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer,
                                size: 64,
                                color: Colors
                                    .grey.shade800), // Increased icon size
                            SizedBox(
                                width: 20), // Increased spacing between icons
                            Image.asset(
                              "assets/icons/yoga.png",
                              width: 60, // Adjust the image size as needed
                              height: 60, // Adjust the image size as needed
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Added spacing between rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${level.minutes} min',
                                style: TextStyle(
                                    fontSize: 20)), // Increased text size
                            SizedBox(
                                width: 20), // Increased spacing between text
                            Text('Matte',
                                style: TextStyle(
                                    fontSize: 20)), // Increased text size
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  PressableButton(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCombinerScreen(
                            levelId: level.id,
                            levelNotifier: Provider.of<LevelNotifier>(context,
                                listen: false),
                            profilProvider: Provider.of<ProfilProvider>(context,
                                listen: false),
                          ),
                        ),
                      );
                    },
                    child: Text("Starten",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  SizedBox(height: 30.0),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class LevelCircle extends StatelessWidget {
  final int level;
  final VoidCallback onTap;
  final bool isTreasureLevel;
  final bool isDone;
  final bool isNext; // Indicates if this is the next level to start

  LevelCircle({
    required this.level,
    required this.onTap,
    this.isTreasureLevel = false,
    this.isDone = false,
    this.isNext = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    String imageName;
    if (isDone) {
      imageName = 'assets/button_green.png';
    } else if (isNext) {
      imageName = 'assets/button_grey.png';
    } else {
      imageName = 'assets/button_locked.png';
    }

    return Material(
      type: MaterialType.transparency, // Use transparent material
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent, // Ensure no splash is shown
        highlightColor: Colors.transparent, // Ensure no highlight is shown
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageName),
                  fit: BoxFit.contain,
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(right: 0, bottom: 15),
                child: Center(
                  child: StrokeText(
                    text: "$level",
                    textStyle: TextStyle(
                        fontSize: 34,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    strokeColor: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
            if (isNext)
              Positioned(
                top: 65, // Adjust as necessary
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "START",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
