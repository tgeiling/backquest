import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'elements.dart';

bool questionaireDone = false;

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_updatePage);
  }

  void _updatePage() {
    if (_pageController.page!.toInt() != _currentPage) {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    }
  }

  void _finishQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('questionnaireCompleted', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainScaffold()),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          QuestionPage1(),
          QuestionPage2(),
          QuestionPage3(),
          QuestionPage4(onFinish: _finishQuestionnaire),
        ],
      ),
      floatingActionButton: _currentPage < 3
          ? FloatingActionButton(
              backgroundColor: Colors.black,
              child: Icon(Icons.navigate_next),
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class QuestionPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Page 1 Content"));
    // Add your custom widgets for Page 1 here
  }
}

class QuestionPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Page 2 Content"));
    // Add your custom widgets for Page 2 here
  }
}

class QuestionPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Page 3 Content"));
    // Add your custom widgets for Page 3 here
  }
}

class QuestionPage4 extends StatelessWidget {
  final VoidCallback onFinish;

  QuestionPage4({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Congratulations!"),
              content: Text("You're all set to start."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    onFinish(); // Call the onFinish callback
                  },
                  child: Text("Start"),
                ),
              ],
            ),
          );
        },
        child: Text("Finish"),
      ),
    );
  }
}

class AfterVideoView extends StatefulWidget {
  @override
  _AfterVideoViewState createState() => _AfterVideoViewState();
}

class _AfterVideoViewState extends State<AfterVideoView> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          FirstPage(
              onPressedWeiter: () => _pageController.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut)),
          SecondPage(onPressedAbschliessen: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  final VoidCallback onPressedWeiter;

  FirstPage({required this.onPressedWeiter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Spacer(),
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Text(
                      'Gib deinem Coach jetzt ein kurzes Feedback zu deinen Übungen.',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ))),
            SizedBox(height: 18.0),
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Text(
                      'Damit kann das Trainingsprogramm noch besser auf dich zugeschnitten werden.',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ))),
            Spacer(),
            Center(
              child: PressableButton(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 17),
                onPressed: onPressedWeiter,
                child: Text(
                  "Los geht's",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12), // Add some space between the buttons
            Center(
              child: PressableButton(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: Colors.grey.shade100,
                shadowColor: Colors.grey.shade300,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Überspringen',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final VoidCallback onPressedAbschliessen;

  SecondPage({required this.onPressedAbschliessen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback zu Deinen Übungen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ExerciseFeedbackTile(index: index + 1);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onPressedAbschliessen,
              child: Text('Abschließen'),
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(double.infinity, 36), // make width as wide as possible
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseFeedbackTile extends StatefulWidget {
  final int index;

  ExerciseFeedbackTile({required this.index});

  @override
  _ExerciseFeedbackTileState createState() => _ExerciseFeedbackTileState();
}

class _ExerciseFeedbackTileState extends State<ExerciseFeedbackTile> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text('Übung ${widget.index}'),
          ),
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: _showPainLocationDialog,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ChoiceChip(
            label: Text('Einfach'),
            selected: selectedOption == 'Einfach',
            onSelected: (bool selected) {
              setState(() {
                selectedOption = 'Einfach';
              });
            },
          ),
          ChoiceChip(
            label: Text('Ok'),
            selected: selectedOption == 'Ok',
            onSelected: (bool selected) {
              setState(() {
                selectedOption = 'Ok';
              });
            },
          ),
          ChoiceChip(
            label: Text('Schwer'),
            selected: selectedOption == 'Schwer',
            onSelected: (bool selected) {
              setState(() {
                selectedOption = 'Schwer';
              });
            },
          ),
        ],
      ),
      leading: Image.asset(
        "assets/fragen/birddogwippenlinks.jpg",
        width: 40.0, // Set width to 30
        height: 30.0, // Set height to 40
      ),
    );
  }

  void _showPainLocationDialog() {
    // Define the variable for selected body part in the state class, not inside the showDialog method
    String? selectedBodyPart;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Add this StatefulBuilder to manage the state of the selected body part
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Wo haben Sie bei der Übung Schmerzen gehabt?'),
              content: DropdownButton<String>(
                isExpanded: true,
                value: selectedBodyPart,
                items: <String>[
                  'Rücken',
                  'Schulter',
                  'Knie',
                  'Hüfte',
                  'Handgelenk'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  // Update the selected body part within the StatefulBuilder
                  setState(() {
                    selectedBodyPart = newValue;
                  });
                },
              ),
              actions: [
                PressableButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Abbrechen'),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                PressableButton(
                  onPressed: () {
                    //hier muss wert in Provider eingetragen werden
                    Navigator.of(context).pop();
                  },
                  child: Text('Speichern'),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                )
              ],
            );
          },
        );
      },
    );
  }
}
