
import 'dart:io';

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

List<Map<String, dynamic>> _IconRows = [
  {
    'image1': 'assets/achivements/3.png',
    'dialog1': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image2': 'assets/achivements/7.png',
    'dialog2': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image3': 'assets/achivements/15.png',
    'dialog3': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image4': 'assets/achivements/30.png',
    'dialog4': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
  },
  {
    'image1': 'assets/achivements/chesspawn.png',
    'dialog1': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image2': 'assets/achivements/dumbell.png',
    'dialog2': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image3': 'assets/achivements/medal.png',
    'dialog3': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image4': 'assets/achivements/championBelt.png',
    'dialog4': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
  },
  {
    'image1': 'assets/achivements/back_1.png',
    'dialog1': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image2': 'assets/achivements/back_2.png',
    'dialog2': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image3': 'assets/achivements/back_3.png',
    'dialog3': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
    'image4': 'assets/achivements/back_4.png',
    'dialog4': 'qweqweqweqweqweqweqweqweqweqweqweqwe',
  }
];

class TrophyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _IconRows.map(
        (item) => TrophyRow(
            item['image1'],
            item['image2'],
            item['image3'],
            item['image4'],
            item['dialog1'],
            item['dialog2'],
            item['dialog3'],
            item['dialog4']),
      ).toList(),
    );
  }
}

class TrophyRow extends StatelessWidget {
  TrophyRow(this.image1, this.image2, this.image3, this.image4, this.dialog1,
      this.dialog2, this.dialog3, this.dialog4);

  final String image1;
  final String image2;
  final String image3;
  final String image4;
  final String dialog1;
  final String dialog2;
  final String dialog3;
  final String dialog4;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Trophy(image: image1, dialog: dialog1),
          Trophy(image: image2, dialog: dialog2),
          Trophy(image: image3, dialog: dialog3),
          Trophy(image: image4, dialog: dialog4)
        ]);
  }
}

class Trophy extends StatefulWidget {
  const Trophy({super.key, required this.image, required this.dialog});

  final String image;
  final String dialog;

  @override
  State<Trophy> createState() => _TrophyState();
}

class _TrophyState extends State<Trophy> {
  bool dialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    margin: const EdgeInsets.only(top: 60.0, bottom: 30.0),
                    child: Text(widget.dialog)),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Image.asset(
        widget.image,
        fit: BoxFit.cover,
        width: 90, // Fixes border issues
      ),
    );
  }
}