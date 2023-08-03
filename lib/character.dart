import 'package:flutter/material.dart';
import 'data_provider.dart';
import 'package:provider/provider.dart';

class CharacterBox extends StatefulWidget {
  @override
  static List<IconData> staticAchievements = [
    Icons.star,
    Icons.favorite,
    Icons.gamepad,
  ];

  _CharacterBoxState createState() => _CharacterBoxState();
}

class _CharacterBoxState extends State<CharacterBox> {
  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    return StreamBuilder<Map<String, dynamic>>(
        stream: firebaseService.getCharacterDataStream(),
        builder: (context, snapshot) {
          print('Connection State: ${snapshot.connectionState}');
          print('Data: ${snapshot.data}');

          if (snapshot.hasData) {
            final characterData = snapshot.data!;

            final List<IconData> achievements = CharacterBox.staticAchievements;

            var name = characterData['name'];
            var health = characterData['health'];
            var maxHealth = characterData['maxHealth'];
            double healthPercentage = health / maxHealth;
            var energy = characterData['energy'];
            var maxEnergy = characterData['maxEnergy'];
            double energyPercentage = energy / maxEnergy;

            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/character/example.png",
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 8),
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      for (IconData iconData in achievements) Icon(iconData),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 200 * healthPercentage,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Center(
                          child: Text('${health}/${maxHealth}'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 200 * energyPercentage,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Center(
                          child: Text('${energy}/${maxEnergy}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
