import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import 'services.dart';
import 'elements.dart';
import 'stats.dart';

bool questionaireDone = false;

class QuestionnaireScreen extends StatefulWidget {
  final VoidCallback checkQuestionaire;

  QuestionnaireScreen({Key? key, required this.checkQuestionaire})
      : super(key: key);

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
    widget.checkQuestionaire();
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
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(97, 184, 115, 0.9),
                Color.fromRGBO(0, 59, 46, 0.9),
              ],
            ),
          ),
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              QuestionPage1(pageController: _pageController),
              QuestionPage2(pageController: _pageController),
              QuestionPage3(pageController: _pageController),
              QuestionPage4(pageController: _pageController),
              QuestionPage5(pageController: _pageController),
              QuestionPage6(pageController: _pageController),
              QuestionPage7(pageController: _pageController),
              QuestionPage8(onFinish: _finishQuestionnaire),
            ],
          )),
    );
  }
}

class QuestionPage1 extends StatelessWidget {
  final PageController pageController;

  QuestionPage1({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Text(
            'Erzähle uns ein wenig mehr über Dich,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            'damit wir das Rückenprogramm individuell auf Dich zuschneiden können.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
            textAlign: TextAlign.left,
          ),
          Spacer(),
          PressableButton(
            onPressed: () {
              pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }
}

class QuestionPage2 extends StatefulWidget {
  final PageController pageController;

  QuestionPage2({required this.pageController});

  @override
  _QuestionPage2State createState() => _QuestionPage2State();
}

class _QuestionPage2State extends State<QuestionPage2> {
  DateTime selectedDate = DateTime.now();
  double _genderSliderValue = 1;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Text(
            'Erst einmal zwei persönliche Fragen.',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 32),
          Text(
            'Wann bist du geboren?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Container(
              width: double.maxFinite,
              height: 400,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.dark,
                ),
                child: CupertinoDatePicker(
                  dateOrder: DatePickerDateOrder.dmy,
                  initialDateTime: selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              )),
          SizedBox(height: 24),
          Text(
            'Was ist Dein Geschlecht?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.5),
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
              tickMarkShape: RoundSliderTickMarkShape(),
              activeTickMarkColor: Colors.white,
              inactiveTickMarkColor: Colors.white.withOpacity(0.5),
            ),
            child: Slider(
              value: _genderSliderValue,
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (value) {
                setState(() {
                  _genderSliderValue = value;
                });
              },
            ),
          ),
          Center(
            child: Text(
              _genderSliderValue == 0
                  ? 'Männlich'
                  : _genderSliderValue == 1
                      ? 'Weiblich'
                      : 'Divers',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              profilProvider.setBirthdate(selectedDate);
              String gender = _genderSliderValue == 0
                  ? "male"
                  : (_genderSliderValue == 1 ? "female" : "other");
              profilProvider.setGender(gender);

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    birthdate: selectedDate,
                    gender: gender,
                  ).then((success) {
                    if (success) {
                      print("Profile updated successfully.");
                    } else {
                      print("Failed to update profile.");
                    }
                  });
                } else {
                  print("No auth token available.");
                }
              });
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }
}

class QuestionPage3 extends StatefulWidget {
  final PageController pageController;

  QuestionPage3({required this.pageController});

  @override
  _QuestionPage3State createState() => _QuestionPage3State();
}

class _QuestionPage3State extends State<QuestionPage3> {
  int _currentHeight = 170;
  int _currentWeight = 70;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Text(
            'Nun gehen wir mehr ins Detail.',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wie groß bist Du? (cm)',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              NumberPicker(
                value: _currentHeight,
                minValue: 100,
                maxValue: 220,
                textStyle: TextStyle(color: Colors.grey.shade400),
                selectedTextStyle: TextStyle(color: Colors.white, fontSize: 24),
                onChanged: (value) => setState(() => _currentHeight = value),
              ),
            ],
          ),
          SizedBox(height: 44),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wieviel wiegst Du? (kg)',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              NumberPicker(
                value: _currentWeight,
                minValue: 20,
                maxValue: 200,
                textStyle: TextStyle(color: Colors.grey.shade400),
                selectedTextStyle: TextStyle(color: Colors.white, fontSize: 24),
                onChanged: (value) => setState(() => _currentWeight = value),
              ),
            ],
          ),
          Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              profilProvider.setHeight(_currentHeight);
              profilProvider.setWeight(_currentWeight);

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    height: _currentHeight,
                    weight: _currentWeight,
                  ).then((success) {
                    if (success) {
                      print("Profile updated successfully.");
                    } else {
                      print("Failed to update profile.");
                    }
                  });
                } else {
                  print("No auth token available.");
                }
              });
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }
}

class QuestionPage4 extends StatefulWidget {
  final PageController pageController;

  QuestionPage4({required this.pageController});

  @override
  _QuestionPage4State createState() => _QuestionPage4State();
}

class _QuestionPage4State extends State<QuestionPage4> {
  String _selectedOption1 = "meistens sitzend";
  String _selectedOption2 = "Garkein Sport";

  final List<String> options1 = [
    'meistens sitzend',
    'häufig sitzend',
    'fast immer stehend'
  ];

  final List<String> options2 = [
    'Garkein Sport',
    'Anfänger',
    'Fortgeschritten',
    'Experte'
  ];

  @override
  void initState() {
    super.initState();
  }

  _saveSelectedOption(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Text(
            'Weiter zu Deinem Alltag.',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 50),
          _buildRoundedSelectBox('Was trifft auf Deinen Arbeitsalltag zu?',
              _selectedOption1, options1, 'everyDaySituation'),
          SizedBox(height: 50),
          _buildRoundedSelectBox('Wie ist Dein aktuelles Fitnesslevel?',
              _selectedOption2, options2, 'fitnessLevel'),
          Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              profilProvider.setWorkplaceEnvironment(_selectedOption1);
              profilProvider.setFitnessLevel(_selectedOption2);

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    workplaceEnvironment: _selectedOption1,
                    fitnessLevel: _selectedOption2,
                  ).then((success) {
                    if (success) {
                      print("Profile updated successfully.");
                    } else {
                      print("Failed to update profile.");
                    }
                  });
                } else {
                  print("No auth token available.");
                }
              });
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSelectBox(String labelText, String? selectedValue,
      List<String> items, String prefKey) {
    selectedValue ??= items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            labelText,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              isDense: true,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  switch (prefKey) {
                    case 'everyDaySituation':
                      _selectedOption1 = newValue!;
                      break;
                    case 'fitnessLevel':
                      _selectedOption2 = newValue!;
                      break;
                  }
                  _saveSelectedOption(prefKey, newValue!);
                });
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class QuestionPage5 extends StatefulWidget {
  final PageController pageController;

  QuestionPage5({required this.pageController});

  @override
  _QuestionPage5State createState() => _QuestionPage5State();
}

class _QuestionPage5State extends State<QuestionPage5> {
  Map<String, bool> painAreas = {
    'Unterer Rücken': false,
    'Oberer Rücken': false,
    'Linke Schulter': false,
    'Rechte Schulter': false,
    'Linker Arm': false,
    'Rechter Arm': false,
    'Thorax': false,
    'Steuerboard': false,
    'Yomama': false,
    'Yoiceborndragon': false,
  };

  @override
  Widget build(BuildContext context) {
    List<String> keys = painAreas.keys.toList();
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        children: [
          Spacer(),
          Text(
            'Jetzt werden wir noch spezifischer für das Programm.',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: keys.take(5).map((String key) {
                    return CheckboxListTile(
                      title: Text(key, style: TextStyle(color: Colors.white)),
                      value: painAreas[key],
                      onChanged: (bool? value) {
                        setState(() {
                          painAreas[key] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Column(
                  children: keys.skip(5).map((String key) {
                    return CheckboxListTile(
                      title: Text(key, style: TextStyle(color: Colors.white)),
                      value: painAreas[key],
                      onChanged: (bool? value) {
                        setState(() {
                          painAreas[key] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              profilProvider.setHasPain(painAreas.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList());

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    painAreas: painAreas.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList(),
                  ).then((success) {
                    if (success) {
                      print("Profile updated successfully.");
                    } else {
                      print("Failed to update profile.");
                    }
                  });
                } else {
                  print("No auth token available.");
                }
              });
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }
}

class QuestionPage6 extends StatefulWidget {
  final PageController pageController;

  QuestionPage6({required this.pageController});

  @override
  _QuestionPage6State createState() => _QuestionPage6State();
}

class _QuestionPage6State extends State<QuestionPage6> {
  String _selectedExpectation = "Better Posture";
  String _selectedPersonalGoal = "Yoga Master";
  String _additionalPersonalGoal = "";

  final List<String> expectationsOptions = [
    'Better Posture',
    'Pain Relief',
    'More Flexibility'
  ];

  final List<String> personalGoalsOptions = [
    'Run a Marathon',
    'Lift Weights',
    'Yoga Master'
  ];

  _saveSelectedOption(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'Zum Schluss noch etwas Persönliches von Dir.',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  SizedBox(height: 50),
                  _buildRoundedSelectBox(
                      'Was sind deine 3 Ziele die du durch die App erwartest?',
                      _selectedExpectation,
                      expectationsOptions,
                      'selectedExpectation'),
                  SizedBox(height: 50),
                  _buildRoundedSelectBox(
                      'Ergänze noch ein persönliches Ziel bei Bedarf.',
                      _selectedPersonalGoal,
                      personalGoalsOptions,
                      'selectedPersonalGoal'),
                  SizedBox(height: 50),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Schreibe Dein Ziel",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (value) {
                      _additionalPersonalGoal = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              profilProvider.setExpectation(_selectedExpectation);
              profilProvider.setGoal(_selectedPersonalGoal);

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    expectation: _selectedExpectation,
                    personalGoal: _selectedPersonalGoal,
                  ).then((success) {
                    if (success) {
                      print("Profile updated successfully.");
                    } else {
                      print("Failed to update profile.");
                    }
                  });
                } else {
                  print("No auth token available.");
                }
              });
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSelectBox(String labelText, String selectedValue,
      List<String> items, String prefKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            labelText,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              isDense: true,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  switch (prefKey) {
                    case 'selectedExpectation':
                      _selectedExpectation = newValue!;
                      break;
                    case 'selectedPersonalGoal':
                      _selectedPersonalGoal = newValue!;
                      break;
                  }
                  _saveSelectedOption(prefKey, newValue!);
                });
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class QuestionPage7 extends StatefulWidget {
  final PageController pageController;

  QuestionPage7({required this.pageController});

  @override
  _QuestionPage7State createState() => _QuestionPage7State();
}

class _QuestionPage7State extends State<QuestionPage7> {
  int _weeklyGoal = 1;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Text(
            'Als letztes, setzte deine Ziele Fest!',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wöchentliches Ziel: ',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              NumberPicker(
                value: _weeklyGoal,
                minValue: 1,
                maxValue: 12,
                textStyle: TextStyle(color: Colors.grey.shade400),
                selectedTextStyle: TextStyle(color: Colors.white, fontSize: 24),
                onChanged: (value) => setState(() => _weeklyGoal = value),
              ),
            ],
          ),
          Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              profilProvider.setWeeklyGoal(_weeklyGoal);

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    weeklyGoal: _weeklyGoal,
                  ).then((success) {
                    if (success) {
                      print("Profile updated successfully.");
                    } else {
                      print("Failed to update profile.");
                    }
                  });
                } else {
                  print("No auth token available.");
                }
              });
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Weiter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ))),
          ),
        ],
      ),
    );
  }
}

class QuestionPage8 extends StatelessWidget {
  final VoidCallback onFinish;

  QuestionPage8({required this.onFinish});

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
                    Navigator.of(context).pop();
                    onFinish();
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 12),
            Center(
              child: PressableButton(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: Colors.grey.shade100,
                shadowColor: Colors.grey.shade300,
                onPressed: () {
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
                minimumSize: Size(double.infinity, 36),
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
        width: 40.0,
        height: 30.0,
      ),
    );
  }

  void _showPainLocationDialog() {
    String? selectedBodyPart;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
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
