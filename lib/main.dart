import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';

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

void main() {
  return runApp(MyApp());
}

final scakey = new GlobalKey<_MyStatefulWidgetState>();

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text("002"),
        Container(
          width: 40,
          height: 100,
          decoration: BoxDecoration(
              image: new DecorationImage(
            alignment: Alignment.centerLeft,
            image: new AssetImage('assets/fireIcon.png'),
          )),
        )
      ],
    );
  }
}

class IconRow extends StatefulWidget {
  const IconRow({
    super.key,
    this.activeItem = false,
  });

  final bool activeItem;

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
            child: Image.asset(
              'assets/homeIcon.png',
              fit: BoxFit.cover, // Fixes border issues
            ),
          ),
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(1);
            }, // Image tapped
            child: Image.asset(
              'assets/bookIcon.png',
              fit: BoxFit.cover, // Fixes border issues
            ),
          ),
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(2);
            }, // Image tapped
            child: Image.asset(
              'assets/trophyIcon.png',
              fit: BoxFit.cover, // Fixes border issues
            ),
          ),
          GestureDetector(
            onTap: () {
              scakey.currentState!._onItemTapped(3);
            }, // Image tapped
            child: Image.asset(
              'assets/userIcon.png',
              fit: BoxFit.cover, // Fixes border issues
            ),
          ),
        ]);
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      color: MaterialColor(0xFF409AB5, color),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: GameLevelsScrollingMap.scrollable(
        imageUrl: "assets/map.jpg",
        direction: Axis.vertical,
        reverseScrolling: true,
        pointsPositionDeltaX: 25,
        pointsPositionDeltaY: 25,
        svgUrl: 'assets/map1.svg',
        points: points,
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    fillTestData();
  }

  List<PointModel> points = [];

  void fillTestData() {
    for (int i = 0; i < 16; i++) {
      points.add(PointModel(16, testWidget(i)));
    }
  }

  Widget testWidget(int order) {
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/map_point.png",
            fit: BoxFit.fitWidth,
            width: 90,
          ),
          Text("$order",
              style: const TextStyle(color: Colors.white, fontSize: 30))
        ],
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Point $order"),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({required Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  final scaKey = new GlobalKey<_MyStatefulWidgetState>();

  List<Widget> _widgetOptions = <Widget>[
    MapVerticalExample(),
    PageTwo(),
    PageThree(),
    PageFour(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaKey,
      appBar: AppBar(
        leading: Image.asset('assets/bqlogo2.jpeg'),
        leadingWidth: 250,
        title: Scoring(),
        actions: [
          Icon(Icons.menu),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text('Go page 1'),
        onPressed: () {
          scakey.currentState!._onItemTapped(1);
        },
      ),
    );
  }
}

class PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text('Go page 2'),
        onPressed: () {
          scakey.currentState!._onItemTapped(1);
        },
      ),
    );
  }
}

class PageFour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text('Go page 3'),
        onPressed: () {
          scakey.currentState!._onItemTapped(2);
        },
      ),
    );
  }
}
