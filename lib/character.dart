import 'package:flutter/material.dart';
import 'data_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class CharacterBox extends StatefulWidget {
  static List<IconData> staticAchievements = [
    Icons.star,
    Icons.favorite,
    Icons.gamepad,
  ];

  const CharacterBox({super.key});

  @override
  _CharacterBoxState createState() => _CharacterBoxState();
}

class _CharacterBoxState extends State<CharacterBox> {
  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    return StreamBuilder<Map<String, dynamic>>(
        stream: firebaseService.getUserDataStream(),
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
            var questsDone = characterData['questsDone'];
            var questsGoal = characterData['questsGoal'];
            double questsDonePercentage = questsDone / questsGoal;

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 32),
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              for (IconData iconData in achievements)
                                Icon(iconData),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                                  child: Text('$health/$maxHealth'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 140,
                        height: 140,
                        padding: EdgeInsets.only(
                            left: 8.0, bottom: 12.0), // Add top padding
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/character/example.png",
                          width: 140, // Adjust the image size as needed
                          height: 140, // Adjust the image size as needed
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height:
                          24), // Add spacing between character info and progress bar
                  Center(
                    child: Text(
                      'Quests erledigt',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                      child: Container(
                    width: MediaQuery.of(context).size.width -
                        40, // Adjust the width as needed
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: (MediaQuery.of(context).size.width - 40) *
                              questsDonePercentage,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Center(
                          child: Text('$questsDone/$questsGoal'),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(height: 16),
                  QuestListWidget(active: true),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuestFullView(),
                        ),
                      );
                    },
                    child: Text('View Quest Details'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class QuestListWidget extends StatelessWidget {
  final bool active;

  QuestListWidget({
    required this.active, // Add the 'active' parameter to the constructor
  });

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    return StreamBuilder<Map<String, dynamic>>(
      stream: firebaseService.getQuestProgressDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final questData = snapshot.data!;

          final List<Map<String, dynamic>> quests = [
            {
              'id': 'quest1',
              'name': 'Quest 1',
              'icon': Icons.star,
              'currentProgress': questData['quest1']['stepsDone'],
              'active': questData['quest1']['active'],
              'goal': 10,
            },
            {
              'id': 'quest2',
              'name': 'Quest 2',
              'icon': Icons.favorite,
              'currentProgress': questData['quest2']['stepsDone'],
              'active': questData['quest1']['active'],
              'goal': 15,
            },
            {
              'id': 'quest3',
              'name': 'Quest 3',
              'icon': Icons.gamepad,
              'currentProgress': questData['quest3']['stepsDone'],
              'active': questData['quest1']['active'],
              'goal': 8,
            },
            {
              'id': 'quest4',
              'name': 'Quest 4',
              'icon': Icons.gamepad,
              'currentProgress': questData['quest4']['stepsDone'],
              'active': questData['quest1']['active'],
              'goal': 8,
            },
          ];

          final activeQuests =
              quests.where((quest) => quest['active']).toList();

          final Iterable<Map<String, dynamic>> questsToIterate =
              active ? activeQuests : quests;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Quests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (var quest in questsToIterate)
                  _QuestItem(
                    id: quest['id'],
                    name: quest['name'],
                    icon: quest['icon'],
                    currentProgress: quest['currentProgress'],
                    goal: quest['goal'],
                    active: active,
                  ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _QuestItem extends StatefulWidget {
  final String name;
  final IconData icon;
  final int currentProgress;
  final int goal;

  final String id;
  final bool active;

  const _QuestItem({
    required this.name,
    required this.icon,
    required this.currentProgress,
    required this.goal,
    required this.id,
    required this.active,
  });

  @override
  _QuestItemState createState() => _QuestItemState();
}

class _QuestItemState extends State<_QuestItem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseService firebaseService = FirebaseService();

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.active;
  }

  @override
  Widget build(BuildContext context) {
    final double progressPercentage = widget.currentProgress / widget.goal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (!widget.active) // Use !active instead of active == false
            Checkbox(
              value: !_isChecked,
              onChanged: (newValue) {
                setState(() {
                  // Checkbox state changed, update Firebase data
                  final Map<String, dynamic> questUpdateData = {
                    'active': newValue, // Toggle the active state
                    'stepsDone': widget.currentProgress
                  };
                  _firestore
                      .collection('QuestProgressdata')
                      .doc(FirebaseAuth
                          .instance.currentUser!.uid) // Use your user ID
                      .update({
                    widget.id:
                        questUpdateData, // Use widget.id to specify the quest field
                  }).then((_) {
                    // Firebase update successful
                    setState(() {
                      // Update the local checkbox state
                      _isChecked = newValue!;
                    });
                  }).catchError((error) {
                    // Handle any errors during the Firebase update
                    print('Error updating quest data: $error');
                  });
                });
              },
            ),
          Icon(widget.icon),
          SizedBox(width: 8),
          Text(widget.name),
          Spacer(),
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
                  width: 200 * progressPercentage,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Center(
                  child: Text('${widget.currentProgress}/${widget.goal}'),
                ),
              ],
            ),
          ),
          if (widget.active) // Use !active instead of active == false
            Icon(Icons.delete),
        ],
      ),
    );
  }
}

class QuestFullView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Quest List'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: QuestListWidget(active: false),
        ),
      ),
    );
  }
}
