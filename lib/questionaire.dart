import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
    await prefs.setBool('questionnaireDone', true);
    widget.checkQuestionaire();

    getAuthToken().then((token) {
      if (token != null) {
        updateProfile(
          token: token,
          questionnaireDone: true,
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
  String _selectedOption1 = "Größtenteils Sitzend (z.B. Schreibtischjob)";
  String _selectedOption2 = "Nicht so oft";

  final List<String> options1 = [
    'Größtenteils Sitzend (z.B. Schreibtischjob)',
    'Sitzend und Stehend (z.B. Büro mit Stehschreibtisch)',
    'Überwiegend stehend (z.B. Lehrer/in)',
    'Größtenteils in Bewegung (z.B. Erzieher/in)',
    'Schwer Hebend (z.B. Umzugshelfer/in)'
  ];

  final List<String> options2 = [
    'Nicht so oft',
    'Mehrmals im Monat',
    'Einmal pro Woche',
    'Mehrmals pro Woche',
    'Täglich',
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
          _buildRoundedSelectBox('Wie oft treibst du Sport?', _selectedOption2,
              options2, 'fitnessLevel'),
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
    // Ensure that a value is selected, defaulting to the first item if none is selected
    selectedValue ??= items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            labelText,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.7), // Darker background color
            borderRadius: BorderRadius.circular(10.0), // Less-rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2), // Slight shadow to create depth
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              isDense: true,
              isExpanded: true,
              dropdownColor:
                  Colors.grey[800], // Background color of the dropdown menu
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
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Colors.white), // White text for visibility
                  ),
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
    'Nacken': false,
    'Knie': false,
    'Hand gelenke': false,
    'Füße': false,
    'Sprung gelenk': false,
    'Hüfte': false,
    'Kiefer': false,
    'Schulter': false,
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
                      checkColor: Colors.white,
                      activeColor: Colors.green,
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
                      checkColor: Colors.white,
                      activeColor: Colors.green,
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
  String _selectedGoal1 = 'Rückenschmerzen vorbeugen';
  String _selectedGoal2 = 'Beweglicher werden';
  String _selectedGoal3 = 'Gewohnheit bilden';
  String _additionalPersonalGoal = "";

  final List<String> personalGoalsOptions = [
    'Rückenschmerzen vorbeugen',
    'Beweglicher werden',
    'Gewohnheit bilden',
    'Stärker werden',
    'Mehr Energie',
    'Stressabbau',
    'Haltung verbessern'
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
                      _selectedGoal1,
                      personalGoalsOptions,
                      'selectedGoal1'),
                  SizedBox(height: 10),
                  _buildRoundedSelectBox('', _selectedGoal2,
                      personalGoalsOptions, 'selectedGoal2'),
                  _buildRoundedSelectBox('', _selectedGoal3,
                      personalGoalsOptions, 'selectedGoal3'),
                  SizedBox(height: 50),
                  TextField(
                    style: TextStyle(
                        color: Colors.white), // Sets the text color to white
                    decoration: InputDecoration(
                      hintText: "Schreibe Dein Ziel",
                      hintStyle: TextStyle(
                          color: Colors
                              .white70), // Hint text in a semi-transparent white color
                      fillColor: Colors.grey.withOpacity(
                          0.7), // Background color similar to the select boxes
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0), // Padding for additional height
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Matches the corner radius of the select boxes
                        borderSide: BorderSide
                            .none, // Removes the border to make it seamless
                      ),
                    ),
                    onChanged: (value) {
                      _additionalPersonalGoal = value;
                    },
                  )
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

              List<String> selectedGoals = [
                _selectedGoal1,
                _selectedGoal2,
                _selectedGoal3
              ];

              profilProvider.setGoals(selectedGoals);

              getAuthToken().then((token) {
                if (token != null) {
                  updateProfile(
                    token: token,
                    personalGoal: selectedGoals,
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.7), // Darker background color
            borderRadius: BorderRadius.circular(10.0), // Less-rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2), // Slight shadow to create depth
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              isDense: true,
              isExpanded: true,
              dropdownColor:
                  Colors.grey[800], // Background color of the dropdown menu
              onChanged: (String? newValue) {
                setState(() {
                  switch (prefKey) {
                    case 'selectedGoal1':
                      _selectedGoal1 = newValue!;
                      break;
                    case 'selectedGoal2':
                      _selectedGoal2 = newValue!;
                      break;
                    case 'selectedGoal3':
                      _selectedGoal3 = newValue!;
                      break;
                  }
                  _saveSelectedOption(prefKey, newValue!);
                });
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Colors.white), // White text for visibility
                  ),
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
    return Container(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Text(
            'Fast Fertig!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            'In der App bekommst du dein eigenes Trainings Video passend auf deine Bedürfnisse geschnitten. Du kannst die Level hochklettern um schwierigere Übungen Freizuschalten oder erstmal Entspannt Übungen starten über den Pfeil in der Ecke.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
            textAlign: TextAlign.left,
          ),
          Spacer(),
          PressableButton(
            onPressed: () {
              onFinish();
            },
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text("Fertigstellen",
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

class AfterVideoView extends StatefulWidget {
  final List<String> videoIds;

  AfterVideoView({Key? key, required this.videoIds}) : super(key: key);

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
          SecondPage(
            videoIds: widget.videoIds,
          ),
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
      child: Padding(
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
                        color: Colors.white,
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
                        color: Colors.white,
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
    ));
  }
}

class SecondPage extends StatefulWidget {
  final List<String> videoIds;

  const SecondPage({Key? key, required this.videoIds}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<ExerciseFeedback> feedbackList = [];

  void _handleFeedbackUpdated(ExerciseFeedback feedback) {
    setState(() {
      int index = feedbackList.indexWhere((f) => f.videoId == feedback.videoId);
      if (index != -1) {
        feedbackList[index].update(
            newDifficulty: feedback.difficulty,
            newPainAreas: feedback.painAreas);
      } else {
        feedbackList.add(feedback);
      }
    });
  }

  Future<void> _sendFeedback() async {
    final feedbackData = feedbackList.map((f) => f.toJson()).toList();

    const String url = 'http://135.125.218.147:3000/feedback';
    final token = await getAuthToken();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'feedback': feedbackData}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Feedback sent successfully!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send feedback.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error sending feedback: $e'),
      ));
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(97, 184, 115, 0.9),
        ),
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
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.videoIds.length,
                  itemBuilder: (context, index) => ExerciseFeedbackTile(
                    index: index,
                    videoId: widget.videoIds[index],
                    onFeedbackUpdated: _handleFeedbackUpdated,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, bottom: 36, top: 16),
                child: PressableButton(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                  onPressed: _sendFeedback,
                  child: Text(
                    'Abschließen',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class ExerciseFeedbackTile extends StatefulWidget {
  final String videoId;
  final int index;
  final Function(ExerciseFeedback) onFeedbackUpdated;

  const ExerciseFeedbackTile({
    Key? key,
    required this.index,
    required this.videoId,
    required this.onFeedbackUpdated,
  }) : super(key: key);

  @override
  _ExerciseFeedbackTileState createState() => _ExerciseFeedbackTileState();
}

class _ExerciseFeedbackTileState extends State<ExerciseFeedbackTile> {
  String? selectedDifficulty;
  List<String> selectedPainAreas = [];

  @override
  Widget build(BuildContext context) {
    double baseSize = MediaQuery.of(context).size.width * 0.1;

    return Card(
      color: Colors.grey.shade500.withOpacity(0.3),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Container(
              height: 80.0,
              width: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  "assets/thumbnails/${widget.videoId}.PNG",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Übung ${widget.index + 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(Icons.flash_on),
                          onPressed: _showPainLocationDialog,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: ['Einfach', 'Ok', 'Schwer']
                          .map((difficulty) => ChoiceChip(
                                backgroundColor: Colors.grey.shade700,
                                checkmarkColor: Colors.white,
                                selectedColor: Colors.green,
                                label: Text(
                                  difficulty,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: baseSize * 0.3,
                                  ),
                                ),
                                selected: selectedDifficulty == difficulty,
                                onSelected: (bool selected) {
                                  setState(() => selectedDifficulty =
                                      selected ? difficulty : null);
                                  _updateFeedback();
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFeedback() {
    final feedback = ExerciseFeedback(
      videoId: widget.videoId,
      difficulty: selectedDifficulty,
      painAreas: selectedPainAreas,
    );
    widget.onFeedbackUpdated(feedback);
  }

  void _showPainLocationDialog() {
    List<String> tempSelectedPainAreas = List.from(selectedPainAreas);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: Colors.green
                            .shade800, // This sets the primary color used in button text, focus colors in the dialog
                      ),
                ),
                child: AlertDialog(
                  title: Text('Schmerzbereiche wählen'),
                  content: SingleChildScrollView(
                    child: Wrap(
                      spacing: 5.0,
                      children: [
                        'Unterer Rücken',
                        'Oberer Rücken',
                        'Nacken',
                        'Knie',
                        'Hand gelenke',
                        'Füße',
                        'Sprung gelenk',
                        'Hüfte',
                        'Kiefer',
                        'Schulter',
                      ]
                          .map((area) => FilterChip(
                                selectedColor: Colors.green.shade300,
                                label: Text(area),
                                selected: tempSelectedPainAreas.contains(area),
                                onSelected: (bool selected) {
                                  setDialogState(() {
                                    if (selected) {
                                      tempSelectedPainAreas.add(area);
                                    } else {
                                      tempSelectedPainAreas.remove(area);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Abbrechen'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Speichern'),
                      onPressed: () {
                        setState(() {
                          selectedPainAreas = tempSelectedPainAreas;
                          _updateFeedback();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
          },
        );
      },
    );
  }
}
