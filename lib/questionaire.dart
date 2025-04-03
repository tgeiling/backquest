import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'services.dart';
import 'elements.dart';
import 'stats.dart';

bool questionaireDone = false;

class QuestionnaireScreen extends StatefulWidget {
  final VoidCallback checkQuestionaire;

  const QuestionnaireScreen({Key? key, required this.checkQuestionaire})
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
          decoration: const BoxDecoration(
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
            physics: const NeverScrollableScrollPhysics(),
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

  const QuestionPage1({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
        constraints: BoxConstraints.expand(),
        color: Colors.transparent,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth >= 600
                              ? screenWidth * 0.2
                              : 0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context)!
                                    .tellUsMoreAboutYou,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .personalizedBackProgram,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                                textAlign: TextAlign.left,
                              ),
                              const Spacer(),
                              PressableButton(
                                onPressed: () {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .continueButton,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ))),
                              ),
                            ],
                          ),
                        )))));
  }
}

class QuestionPage2 extends StatefulWidget {
  final PageController pageController;

  const QuestionPage2({super.key, required this.pageController});

  @override
  _QuestionPage2State createState() => _QuestionPage2State();
}

class _QuestionPage2State extends State<QuestionPage2> {
  DateTime selectedDate = DateTime.now();
  double _genderSliderValue = 1;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenHeight < 600;
    bool isMidScreen = screenHeight >= 600 && screenHeight < 800;

    double datePickerHeight;

    if (isSmallScreen) {
      datePickerHeight = 150;
    } else if (isMidScreen) {
      datePickerHeight = 250;
    } else {
      datePickerHeight = 400;
    }

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            AppLocalizations.of(context)!.personalQuestionsTitle,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.birthdateQuestion,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(
            width: double.maxFinite,
            height: datePickerHeight,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
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
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.genderQuestion,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.5),
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withAlpha(32),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
              tickMarkShape: const RoundSliderTickMarkShape(),
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
                  ? AppLocalizations.of(context)!.genderMale
                  : _genderSliderValue == 1
                      ? AppLocalizations.of(context)!.genderFemale
                      : AppLocalizations.of(context)!.genderDiverse,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionPage3 extends StatefulWidget {
  final PageController pageController;

  const QuestionPage3({super.key, required this.pageController});

  @override
  _QuestionPage3State createState() => _QuestionPage3State();
}

class _QuestionPage3State extends State<QuestionPage3> {
  int _currentHeight = 170;
  int _currentWeight = 70;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double sizedBoxTopHeight;
    double sizedBoxDivider;

    if (isSmallScreen) {
      sizedBoxTopHeight = 30;
      sizedBoxDivider = 10;
    } else {
      sizedBoxTopHeight = 80;
      sizedBoxDivider = 44;
    }

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            AppLocalizations.of(context)!.detailedQuestionsTitle,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(height: sizedBoxTopHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.heightQuestion,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              NumberPicker(
                value: _currentHeight,
                minValue: 100,
                maxValue: 220,
                textStyle: TextStyle(color: Colors.grey.shade400),
                selectedTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 24),
                onChanged: (value) => setState(() => _currentHeight = value),
              ),
            ],
          ),
          SizedBox(height: sizedBoxDivider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.weightQuestion,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              NumberPicker(
                value: _currentWeight,
                minValue: 20,
                maxValue: 200,
                textStyle: TextStyle(color: Colors.grey.shade400),
                selectedTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 24),
                onChanged: (value) => setState(() => _currentWeight = value),
              ),
            ],
          ),
          const Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text(AppLocalizations.of(context)!.continueButton,
                    style: const TextStyle(
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

  const QuestionPage4({super.key, required this.pageController});

  @override
  _QuestionPage4State createState() => _QuestionPage4State();
}

class _QuestionPage4State extends State<QuestionPage4> {
  int _selectedOption1 = 0;
  int _selectedOption2 = 0;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    // Localized options
    final List<String> options1 = [
      AppLocalizations.of(context)!.mostlySitting,
      AppLocalizations.of(context)!.sittingAndStanding,
      AppLocalizations.of(context)!.mostlyStanding,
      AppLocalizations.of(context)!.mostlyMoving,
      AppLocalizations.of(context)!.heavyLifting,
    ];

    final List<String> options2 = [
      AppLocalizations.of(context)!.frequencyRarely,
      AppLocalizations.of(context)!.frequencyMultipleMonthly,
      AppLocalizations.of(context)!.frequencyWeekly,
      AppLocalizations.of(context)!.frequencyMultipleWeekly,
      AppLocalizations.of(context)!.frequencyDaily,
    ];

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            AppLocalizations.of(context)!.everydayTitle,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 50),
          _buildRoundedSelectBox(
            AppLocalizations.of(context)!.everydaySituationLabel,
            _selectedOption1,
            options1,
            'everyDaySituation',
          ),
          const SizedBox(height: 50),
          _buildRoundedSelectBox(
            AppLocalizations.of(context)!.fitnessLevelLabel,
            _selectedOption2,
            options2,
            'fitnessLevel',
          ),
          const Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSelectBox(
      String labelText, int selectedValue, List<String> items, String prefKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            labelText,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedValue,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              isDense: true,
              isExpanded: true,
              dropdownColor: Colors.grey[800],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    switch (prefKey) {
                      case 'everyDaySituation':
                        _selectedOption1 = newValue;
                        break;
                      case 'fitnessLevel':
                        _selectedOption2 = newValue;
                        break;
                    }
                    _saveSelectedOption(prefKey, newValue);
                  });
                }
              },
              items: List.generate(
                items.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    items[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _saveSelectedOption(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}

class QuestionPage5 extends StatefulWidget {
  final PageController pageController;

  const QuestionPage5({super.key, required this.pageController});

  @override
  _QuestionPage5State createState() => _QuestionPage5State();
}

class _QuestionPage5State extends State<QuestionPage5> {
  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    final List<String> painAreaOptions = [
      AppLocalizations.of(context)!.lowerBack,
      AppLocalizations.of(context)!.upperBack,
      AppLocalizations.of(context)!.neck,
      AppLocalizations.of(context)!.knee,
      AppLocalizations.of(context)!.wrists,
      AppLocalizations.of(context)!.feet,
      AppLocalizations.of(context)!.ankle,
      AppLocalizations.of(context)!.hip,
      AppLocalizations.of(context)!.jaw,
      AppLocalizations.of(context)!.shoulder,
    ];

    // Map integer indices to selection status
    final List<bool> selectedPainAreas = List.generate(10, (index) => false);

    return Container(
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              AppLocalizations.of(context)!.painQuestion,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(
                    painAreaOptions.length ~/ 2,
                    (index) {
                      return CheckboxListTile(
                        title: Text(
                          painAreaOptions[index],
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        value: selectedPainAreas[index],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPainAreas[index] = value!;
                          });
                        },
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: List.generate(
                    painAreaOptions.length ~/ 2,
                    (index) {
                      final adjustedIndex = index + painAreaOptions.length ~/ 2;
                      return CheckboxListTile(
                        title: Text(
                          painAreaOptions[adjustedIndex],
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        value: selectedPainAreas[adjustedIndex],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPainAreas[adjustedIndex] = value!;
                          });
                        },
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 32.0, right: 32.0, left: 32.0),
            child: PressableButton(
              onPressed: () {
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );

                final selectedPainAreaIndices = selectedPainAreas
                    .asMap()
                    .entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();

                profilProvider.setHasPain(selectedPainAreaIndices);

                getAuthToken().then((token) {
                  if (token != null) {
                    updateProfile(
                      token: token,
                      painAreas: selectedPainAreaIndices,
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Center(
                  child: Text(AppLocalizations.of(context)!.next,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ))),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionPage6 extends StatefulWidget {
  final PageController pageController;

  const QuestionPage6({super.key, required this.pageController});

  @override
  _QuestionPage6State createState() => _QuestionPage6State();
}

class _QuestionPage6State extends State<QuestionPage6> {
  int _selectedGoal1 = 0;
  int _selectedGoal2 = 1;
  int _selectedGoal3 = 2;
  String _additionalPersonalGoal = "";

  final List<String> personalGoalsOptions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (personalGoalsOptions.isEmpty) {
      personalGoalsOptions.addAll([
        AppLocalizations.of(context)!.personalGoalPreventBackPain,
        AppLocalizations.of(context)!.personalGoalImproveFlexibility,
        AppLocalizations.of(context)!.personalGoalBuildHabit,
        AppLocalizations.of(context)!.personalGoalGetStronger,
        AppLocalizations.of(context)!.personalGoalMoreEnergy,
        AppLocalizations.of(context)!.personalGoalReduceStress,
        AppLocalizations.of(context)!.personalGoalImprovePosture,
      ]);
    }
  }

  _saveSelectedOption(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenHeight < 600;
    bool isMidScreen = screenHeight >= 600 && screenHeight < 800;

    double sizedBoxHeight1;
    double sizedBoxHeight2;

    if (isSmallScreen) {
      sizedBoxHeight1 = 30;
      sizedBoxHeight2 = 10;
    } else if (isMidScreen) {
      sizedBoxHeight1 = 60;
      sizedBoxHeight2 = 20;
    } else {
      sizedBoxHeight1 = 100;
      sizedBoxHeight2 = 50;
    }

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sizedBoxHeight1),
                  Text(
                    AppLocalizations.of(context)!.personalGoalsTitle,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: sizedBoxHeight2),
                  _buildRoundedSelectBox(
                    AppLocalizations.of(context)!.personalGoalsPrompt,
                    _selectedGoal1,
                    personalGoalsOptions,
                    'selectedGoal1',
                  ),
                  _buildRoundedSelectBox(
                    '',
                    _selectedGoal2,
                    personalGoalsOptions,
                    'selectedGoal2',
                  ),
                  _buildRoundedSelectBox(
                    '',
                    _selectedGoal3,
                    personalGoalsOptions,
                    'selectedGoal3',
                  ),
                  SizedBox(height: sizedBoxHeight2),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.personalGoalsHint,
                      hintStyle: const TextStyle(color: Colors.white70),
                      fillColor: Colors.grey.withOpacity(0.7),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              List<int> selectedGoals = [
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.next,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedSelectBox(
      String labelText, int selectedIndex, List<String> items, String prefKey) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenHeight < 600;
    bool isMidScreen = screenHeight >= 600 && screenHeight < 800;

    double itemPadding;

    if (isSmallScreen) {
      itemPadding = 2;
    } else if (isMidScreen) {
      itemPadding = 6;
    } else {
      itemPadding = 12;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 12.0, vertical: itemPadding),
          child: Text(
            labelText,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: itemPadding),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              isDense: true,
              isExpanded: true,
              dropdownColor: Colors.grey[800],
              onChanged: (int? newValue) {
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
              items: items.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.labelLarge,
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

  const QuestionPage7({super.key, required this.pageController});

  @override
  _QuestionPage7State createState() => _QuestionPage7State();
}

class _QuestionPage7State extends State<QuestionPage7> {
  int _weeklyGoal = 1;

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            AppLocalizations.of(context)!.weeklyGoalPrompt,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .weeklyGoalLabel(_weeklyGoal.toString()),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              NumberPicker(
                value: _weeklyGoal,
                minValue: 1,
                maxValue: 12,
                textStyle: TextStyle(color: Colors.grey.shade400),
                selectedTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 24),
                onChanged: (value) => setState(() => _weeklyGoal = value),
              ),
            ],
          ),
          const Spacer(),
          PressableButton(
            onPressed: () {
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Center(
                child: Text(AppLocalizations.of(context)!.continueButton,
                    style: const TextStyle(
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

  const QuestionPage8({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        constraints: BoxConstraints.expand(),
        color: Colors.transparent,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth >= 600
                              ? screenWidth * 0.2
                              : 0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context)!
                                    .welcomeToBackQuest,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .personalizedTrainingIntro,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                                textAlign: TextAlign.left,
                              ),
                              const Spacer(),
                              PressableButton(
                                onPressed: () {
                                  onFinish();
                                },
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .finishButton,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ))),
                              ),
                            ],
                          ),
                        )))));
  }
}

class AfterVideoView extends StatefulWidget {
  final List<String> videoIds;

  const AfterVideoView({Key? key, required this.videoIds}) : super(key: key);

  @override
  _AfterVideoViewState createState() => _AfterVideoViewState();
}

class _AfterVideoViewState extends State<AfterVideoView> {
  final PageController _pageController = PageController();

  List<String> get filteredVideoIds {
    return widget.videoIds
        .where((id) => id.compareTo("0133") < 0 || id.compareTo("0139") > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          FirstPage(
              onPressedWeiter: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut)),
          SecondPage(
            videoIds: filteredVideoIds,
          ),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  final VoidCallback onPressedWeiter;

  const FirstPage({super.key, required this.onPressedWeiter});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double bigHeaderFontSize;

    if (isSmallScreen) {
      bigHeaderFontSize = 22;
    } else {
      bigHeaderFontSize = 40;
    }

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
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
            const Spacer(),
            Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Text(
                      AppLocalizations.of(context)!.feedbackIntroduction,
                      style: TextStyle(
                        fontSize: bigHeaderFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ))),
            const SizedBox(height: 18.0),
            Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width - 70,
                    child: Text(
                      AppLocalizations.of(context)!.feedbackDetails,
                      style: Theme.of(context).textTheme.labelLarge,
                    ))),
            const Spacer(),
            Center(
              child: PressableButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 17),
                onPressed: onPressedWeiter,
                child: Text(
                  AppLocalizations.of(context)!.letsGo,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: PressableButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: Colors.grey.shade100,
                shadowColor: Colors.grey.shade300,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.skip,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
            const Spacer(),
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

    const String url = 'http://34.116.240.55:3000/feedback';
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
          content: Text(AppLocalizations.of(context)!.feedbackSuccess),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.feedbackFailure),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${AppLocalizations.of(context)!.feedbackError}: $e'),
      ));
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(97, 184, 115, 0.9),
        ),
        body: Container(
          decoration: const BoxDecoration(
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
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 36, top: 16),
                child: PressableButton(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                  onPressed: _sendFeedback,
                  child: Text(
                    AppLocalizations.of(context)!.finish,
                    style: Theme.of(context).textTheme.labelLarge,
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
  int? selectedDifficulty;
  List<int> selectedPainAreas = [];

  @override
  Widget build(BuildContext context) {
    double baseSize = MediaQuery.of(context).size.width * 0.1;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    double wrapSpacing;
    double wrapItemVerticalPadding;
    double wrapItemHorizontalPadding;
    double thumbnailDimensions;

    if (isSmallScreen) {
      wrapSpacing = 0;
      wrapItemVerticalPadding = 1;
      wrapItemHorizontalPadding = 2;
      thumbnailDimensions = 70;
    } else {
      wrapSpacing = 8;
      wrapItemVerticalPadding = 2;
      wrapItemHorizontalPadding = 4;
      thumbnailDimensions = 80;
    }

    return Card(
      color: Colors.grey.shade500.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Container(
              height: thumbnailDimensions,
              width: thumbnailDimensions,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  "assets/thumbnails/${widget.videoId}.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.exercise} ${widget.index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flash_on),
                          onPressed: _showPainLocationDialog,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: wrapSpacing,
                      children: [
                        AppLocalizations.of(context)!.difficultyEasy,
                        AppLocalizations.of(context)!.difficultyMedium,
                        AppLocalizations.of(context)!.difficultyHard,
                      ]
                          .asMap()
                          .entries
                          .map((entry) => ChoiceChip(
                                backgroundColor: Colors.grey.shade700,
                                checkmarkColor: Colors.white,
                                selectedColor: Colors.green,
                                label: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: baseSize * 0.3,
                                  ),
                                ),
                                labelPadding: EdgeInsets.symmetric(
                                    vertical: wrapItemVerticalPadding,
                                    horizontal: wrapItemHorizontalPadding),
                                selected: selectedDifficulty == entry.key,
                                onSelected: (bool selected) {
                                  setState(() => selectedDifficulty =
                                      selected ? entry.key : null);
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
    List<int> tempSelectedPainAreas = List.from(selectedPainAreas);

    final Map<int, String> painAreaTranslations = {
      0: AppLocalizations.of(context)!.lowerBack,
      1: AppLocalizations.of(context)!.upperBack,
      2: AppLocalizations.of(context)!.neck,
      3: AppLocalizations.of(context)!.knee,
      4: AppLocalizations.of(context)!.wrists,
      5: AppLocalizations.of(context)!.feet,
      6: AppLocalizations.of(context)!.ankle,
      7: AppLocalizations.of(context)!.hip,
      8: AppLocalizations.of(context)!.jaw,
      9: AppLocalizations.of(context)!.shoulder,
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Colors.green.shade800,
                    ),
              ),
              child: AlertDialog(
                backgroundColor: const Color.fromRGBO(97, 184, 115, 1),
                title: Text(AppLocalizations.of(context)!.selectPainAreasTitle),
                content: SingleChildScrollView(
                  child: Wrap(
                    spacing: 5.0,
                    children: painAreaTranslations.entries
                        .map((entry) => FilterChip(
                              selectedColor: Colors.green.shade300,
                              backgroundColor: Colors.grey.shade600,
                              label: Text(entry.value),
                              selected:
                                  tempSelectedPainAreas.contains(entry.key),
                              onSelected: (bool selected) {
                                setDialogState(() {
                                  if (selected) {
                                    tempSelectedPainAreas.add(entry.key);
                                  } else {
                                    tempSelectedPainAreas.remove(entry.key);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedPainAreas = tempSelectedPainAreas;
                        _updateFeedback();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
