import 'package:flutter/material.dart';

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

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World Demo Application',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF409AB5, color),
      ),
      home: MyHomePage(title: 'Home page'),
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
        Text("000"),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Image.asset('assets/homeIcon.png'),
        Image.asset('assets/bookIcon.png'),
        Image.asset('assets/trophyIcon.png'),
        Image.asset('assets/userIcon.png'),
      ],
    );
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/bqlogo2.jpeg'),
        leadingWidth: 250,
        title: Scoring(),
        actions: [
          Icon(Icons.menu),
        ],
      ),
      body: Center(
          child: Text(
        'Hello World',
      )),
      bottomNavigationBar: Footer(),
    );
  }
}
