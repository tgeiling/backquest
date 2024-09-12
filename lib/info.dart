import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'stats.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title:
            const Text("Informationen", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/settingsbg.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: const [
                InfoTile(
                  title: 'Übungen aufrufen',
                  icon: Icons.fitness_center,
                ),
                InfoTile(
                  title: 'Trainings Daten',
                  icon: Icons.data_usage,
                ),
              ],
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const InfoTile({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        if (title == 'Übungen aufrufen') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExercisesPage()),
          );
        } else if (title == 'Trainings Daten') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileAnalyticsPage()),
          );
        }
      },
    );
  }
}

class DetailView extends StatelessWidget {
  final String title;

  const DetailView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Information for $title'),
      ),
    );
  }
}

class ExpandableTextBox extends StatelessWidget {
  final String text;
  final String exerciseName;
  final bool isExpanded;

  const ExpandableTextBox({
    Key? key,
    required this.text,
    required this.exerciseName,
    required this.isExpanded, // Add the isExpanded parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              exerciseName,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ],
    );
  }
}

class ExercisesPage extends StatefulWidget {
  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final List<Map<String, String>> exercises = [
    {
      "image": "assets/gifs/0001_scene.gif",
      "text":
          "Exercise 1: Start with a basic warm-up to get your blood flowing.",
      "name": "Warm-up Routine"
    },
    {
      "image": "assets/gifs/0002_scene.gif",
      "text":
          "Exercise 2: Engage in core-strengthening exercises to build stability.",
      "name": "Core Stability"
    },
    {
      "image": "assets/gifs/0004_scene.gif",
      "text":
          "Exercise 3: Focus on lower body strength with this leg exercise.",
      "name": "Leg Strengthener"
    },
    {
      "image": "assets/gifs/0005_scene.gif",
      "text": "Exercise 4: Work on your flexibility with these stretches.",
      "name": "Flexibility Stretches"
    },
    {
      "image": "assets/gifs/0010_scene.gif",
      "text": "Exercise 5: Enhance your balance with this simple routine.",
      "name": "Balance Enhancer"
    },
    {
      "image": "assets/gifs/0013_scene.gif",
      "text": "Exercise 6: Boost your endurance with these moves.",
      "name": "Endurance Builder"
    },
    {
      "image": "assets/gifs/0015_scene.gif",
      "text": "Exercise 7: Focus on upper body strength in this workout.",
      "name": "Upper Body Strength"
    },
    {
      "image": "assets/gifs/0016_scene.gif",
      "text": "Exercise 8: Improve your posture with this back exercise.",
      "name": "Posture Improver"
    },
    {
      "image": "assets/gifs/0019_scene.gif",
      "text": "Exercise 9: Strengthen your arms with these targeted exercises.",
      "name": "Arm Strength"
    },
    {
      "image": "assets/gifs/0020_scene.gif",
      "text":
          "Exercise 10: Increase your cardiovascular health with this session.",
      "name": "Cardio Boost"
    },
    {
      "image": "assets/gifs/0021_scene.gif",
      "text": "Exercise 11: Enhance your core with this focused exercise.",
      "name": "Core Enhancer"
    },
    {
      "image": "assets/gifs/0022_scene.gif",
      "text": "Exercise 12: Boost your flexibility with this stretch routine.",
      "name": "Flexibility Boost"
    },
    {
      "image": "assets/gifs/0025_scene.gif",
      "text":
          "Exercise 13: Build your leg muscles with this effective exercise.",
      "name": "Leg Builder"
    },
    {
      "image": "assets/gifs/0028_scene.gif",
      "text": "Exercise 14: Strengthen your shoulders with these moves.",
      "name": "Shoulder Strength"
    },
    {
      "image": "assets/gifs/0029_scene.gif",
      "text":
          "Exercise 15: Improve your endurance with this full-body routine.",
      "name": "Full-body Endurance"
    },
    {
      "image": "assets/gifs/0031_scene.gif",
      "text": "Exercise 16: Focus on your core stability with this exercise.",
      "name": "Core Stability Focus"
    },
    {
      "image": "assets/gifs/0032_scene.gif",
      "text": "Exercise 17: Increase your flexibility with these stretches.",
      "name": "Flexibility Increase"
    },
    {
      "image": "assets/gifs/0033_scene.gif",
      "text": "Exercise 18: Boost your lower body strength with this routine.",
      "name": "Lower Body Boost"
    },
    {
      "image": "assets/gifs/0035_scene.gif",
      "text": "Exercise 19: Strengthen your back with this focused workout.",
      "name": "Back Strength"
    },
    {
      "image": "assets/gifs/0037_scene.gif",
      "text": "Exercise 20: Enhance your arm muscles with these exercises.",
      "name": "Arm Muscle Enhancer"
    },
    {
      "image": "assets/gifs/0038_scene.gif",
      "text": "Exercise 21: Improve your balance with this sequence.",
      "name": "Balance Sequence"
    },
    {
      "image": "assets/gifs/0039_scene.gif",
      "text":
          "Exercise 22: Focus on your cardiovascular health with this routine.",
      "name": "Cardio Focus"
    },
    {
      "image": "assets/gifs/0041_scene.gif",
      "text": "Exercise 23: Engage your core with this powerful exercise.",
      "name": "Core Engagement"
    },
    {
      "image": "assets/gifs/0043_scene.gif",
      "text": "Exercise 24: Strengthen your legs with this workout.",
      "name": "Leg Strengthener"
    },
    {
      "image": "assets/gifs/0044_scene.gif",
      "text": "Exercise 25: Improve flexibility with this series of stretches.",
      "name": "Flexibility Series"
    },
    {
      "image": "assets/gifs/0045_scene.gif",
      "text": "Exercise 26: Boost upper body strength with these exercises.",
      "name": "Upper Body Boost"
    },
    {
      "image": "assets/gifs/0047_scene.gif",
      "text": "Exercise 27: Work on your posture with this back exercise.",
      "name": "Posture Exercise"
    },
    {
      "image": "assets/gifs/0050_scene.gif",
      "text":
          "Exercise 28: Increase your cardiovascular endurance with this session.",
      "name": "Cardio Endurance"
    },
    {
      "image": "assets/gifs/0058_scene.gif",
      "text": "Exercise 29: Focus on shoulder strength with this routine.",
      "name": "Shoulder Strength Focus"
    },
    {
      "image": "assets/gifs/0063_scene.gif",
      "text": "Exercise 30: Strengthen your legs and improve stability.",
      "name": "Leg Stability"
    },
    {
      "image": "assets/gifs/0064_scene.gif",
      "text": "Exercise 31: Enhance your core with these exercises.",
      "name": "Core Enhancement"
    },
    {
      "image": "assets/gifs/0067_scene.gif",
      "text": "Exercise 32: Improve flexibility with these stretches.",
      "name": "Flexibility Stretch"
    },
    {
      "image": "assets/gifs/0068_scene.gif",
      "text":
          "Exercise 33: Build your endurance with this challenging routine.",
      "name": "Endurance Builder"
    },
    {
      "image": "assets/gifs/0084_scene.gif",
      "text":
          "Exercise 34: Work on your upper body strength with these exercises.",
      "name": "Upper Body Workout"
    },
    {
      "image": "assets/gifs/0085_scene.gif",
      "text": "Exercise 35: Improve your balance with these movements.",
      "name": "Balance Movements"
    },
    {
      "image": "assets/gifs/0086_scene.gif",
      "text": "Exercise 36: Strengthen your back with this focused workout.",
      "name": "Back Focus"
    },
    {
      "image": "assets/gifs/0087_scene.gif",
      "text": "Exercise 37: Boost your core stability with this sequence.",
      "name": "Core Stability Sequence"
    },
    {
      "image": "assets/gifs/0088_scene.gif",
      "text":
          "Exercise 38: Increase your cardiovascular fitness with this session.",
      "name": "Cardio Fitness"
    },
    {
      "image": "assets/gifs/0089_scene.gif",
      "text": "Exercise 39: Enhance your flexibility with this routine.",
      "name": "Flexibility Routine"
    },
    {
      "image": "assets/gifs/0090_scene.gif",
      "text": "Exercise 40: Focus on arm strength with these exercises.",
      "name": "Arm Strength Focus"
    },
    {
      "image": "assets/gifs/0091_scene.gif",
      "text": "Exercise 41: Improve your endurance with this workout.",
      "name": "Endurance Workout"
    },
    {
      "image": "assets/gifs/0092_scene.gif",
      "text": "Exercise 42: Work on your core stability with this exercise.",
      "name": "Core Stability"
    },
    {
      "image": "assets/gifs/0100_scene.gif",
      "text":
          "Exercise 43: Strengthen your legs with this series of exercises.",
      "name": "Leg Strength Series"
    },
    {
      "image": "assets/gifs/0101_scene.gif",
      "text": "Exercise 44: Improve your posture with this back routine.",
      "name": "Posture Routine"
    },
    {
      "image": "assets/gifs/0107_scene.gif",
      "text":
          "Exercise 45: Boost your cardiovascular health with this session.",
      "name": "Cardio Health Boost"
    },
    {
      "image": "assets/gifs/0109_scene.gif",
      "text": "Exercise 46: Focus on shoulder strength with these exercises.",
      "name": "Shoulder Focus"
    },
    {
      "image": "assets/gifs/0110_scene.gif",
      "text": "Exercise 47: Enhance your core with this focused workout.",
      "name": "Core Workout"
    },
    {
      "image": "assets/gifs/0114_scene.gif",
      "text": "Exercise 48: Build endurance with this routine.",
      "name": "Endurance Routine"
    },
    {
      "image": "assets/gifs/0115_scene.gif",
      "text": "Exercise 49: Strengthen your legs with these moves.",
      "name": "Leg Strength Moves"
    },
    {
      "image": "assets/gifs/0120_scene.gif",
      "text": "Exercise 50: Improve your flexibility with these stretches.",
      "name": "Flexibility Moves"
    },
    {
      "image": "assets/gifs/0121_scene.gif",
      "text":
          "Exercise 51: Boost your upper body strength with these exercises.",
      "name": "Upper Body Boost"
    },
    {
      "image": "assets/gifs/0129_scene.gif",
      "text": "Exercise 52: Enhance your balance with this exercise.",
      "name": "Balance Enhancer"
    },
  ];
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    // Initialize the expansion state for each exercise
    _isExpanded = List<bool>.filled(exercises.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background image
        Image.asset(
          "assets/settingsbg.PNG",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            title: const Text(
              'Übungen aufrufen',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded[index] =
                            !_isExpanded[index]; // Toggle expanded state
                      });
                    },
                    child: Image.asset(exercises[index]["image"]!),
                  ),
                  const SizedBox(height: 8),
                  ExpandableTextBox(
                    text: exercises[index]["text"]!,
                    exerciseName: exercises[index]["name"]!,
                    isExpanded: _isExpanded[index], // Pass the expanded state
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExercisesPageMainScreen extends StatefulWidget {
  @override
  _ExercisesPageMainScreenState createState() =>
      _ExercisesPageMainScreenState();
}

class _ExercisesPageMainScreenState extends State<ExercisesPageMainScreen> {
  final List<Map<String, String>> exercises = [
    {
      "image": "assets/gifs/0001_scene.gif",
      "text":
          "Exercise 1: Start with a basic warm-up to get your blood flowing.",
      "name": "Warm-up Routine"
    },
    {
      "image": "assets/gifs/0002_scene.gif",
      "text":
          "Exercise 2: Engage in core-strengthening exercises to build stability.",
      "name": "Core Stability"
    },
    {
      "image": "assets/gifs/0004_scene.gif",
      "text":
          "Exercise 3: Focus on lower body strength with this leg exercise.",
      "name": "Leg Strengthener"
    },
    {
      "image": "assets/gifs/0005_scene.gif",
      "text": "Exercise 4: Work on your flexibility with these stretches.",
      "name": "Flexibility Stretches"
    },
    {
      "image": "assets/gifs/0010_scene.gif",
      "text": "Exercise 5: Enhance your balance with this simple routine.",
      "name": "Balance Enhancer"
    },
    {
      "image": "assets/gifs/0013_scene.gif",
      "text": "Exercise 6: Boost your endurance with these moves.",
      "name": "Endurance Builder"
    },
    {
      "image": "assets/gifs/0015_scene.gif",
      "text": "Exercise 7: Focus on upper body strength in this workout.",
      "name": "Upper Body Strength"
    },
    {
      "image": "assets/gifs/0016_scene.gif",
      "text": "Exercise 8: Improve your posture with this back exercise.",
      "name": "Posture Improver"
    },
    {
      "image": "assets/gifs/0019_scene.gif",
      "text": "Exercise 9: Strengthen your arms with these targeted exercises.",
      "name": "Arm Strength"
    },
    {
      "image": "assets/gifs/0020_scene.gif",
      "text":
          "Exercise 10: Increase your cardiovascular health with this session.",
      "name": "Cardio Boost"
    },
    {
      "image": "assets/gifs/0021_scene.gif",
      "text": "Exercise 11: Enhance your core with this focused exercise.",
      "name": "Core Enhancer"
    },
    {
      "image": "assets/gifs/0022_scene.gif",
      "text": "Exercise 12: Boost your flexibility with this stretch routine.",
      "name": "Flexibility Boost"
    },
    {
      "image": "assets/gifs/0025_scene.gif",
      "text":
          "Exercise 13: Build your leg muscles with this effective exercise.",
      "name": "Leg Builder"
    },
    {
      "image": "assets/gifs/0028_scene.gif",
      "text": "Exercise 14: Strengthen your shoulders with these moves.",
      "name": "Shoulder Strength"
    },
    {
      "image": "assets/gifs/0029_scene.gif",
      "text":
          "Exercise 15: Improve your endurance with this full-body routine.",
      "name": "Full-body Endurance"
    },
    {
      "image": "assets/gifs/0031_scene.gif",
      "text": "Exercise 16: Focus on your core stability with this exercise.",
      "name": "Core Stability Focus"
    },
    {
      "image": "assets/gifs/0032_scene.gif",
      "text": "Exercise 17: Increase your flexibility with these stretches.",
      "name": "Flexibility Increase"
    },
    {
      "image": "assets/gifs/0033_scene.gif",
      "text": "Exercise 18: Boost your lower body strength with this routine.",
      "name": "Lower Body Boost"
    },
    {
      "image": "assets/gifs/0035_scene.gif",
      "text": "Exercise 19: Strengthen your back with this focused workout.",
      "name": "Back Strength"
    },
    {
      "image": "assets/gifs/0037_scene.gif",
      "text": "Exercise 20: Enhance your arm muscles with these exercises.",
      "name": "Arm Muscle Enhancer"
    },
    {
      "image": "assets/gifs/0038_scene.gif",
      "text": "Exercise 21: Improve your balance with this sequence.",
      "name": "Balance Sequence"
    },
    {
      "image": "assets/gifs/0039_scene.gif",
      "text":
          "Exercise 22: Focus on your cardiovascular health with this routine.",
      "name": "Cardio Focus"
    },
    {
      "image": "assets/gifs/0041_scene.gif",
      "text": "Exercise 23: Engage your core with this powerful exercise.",
      "name": "Core Engagement"
    },
    {
      "image": "assets/gifs/0043_scene.gif",
      "text": "Exercise 24: Strengthen your legs with this workout.",
      "name": "Leg Strengthener"
    },
    {
      "image": "assets/gifs/0044_scene.gif",
      "text": "Exercise 25: Improve flexibility with this series of stretches.",
      "name": "Flexibility Series"
    },
    {
      "image": "assets/gifs/0045_scene.gif",
      "text": "Exercise 26: Boost upper body strength with these exercises.",
      "name": "Upper Body Boost"
    },
    {
      "image": "assets/gifs/0047_scene.gif",
      "text": "Exercise 27: Work on your posture with this back exercise.",
      "name": "Posture Exercise"
    },
    {
      "image": "assets/gifs/0050_scene.gif",
      "text":
          "Exercise 28: Increase your cardiovascular endurance with this session.",
      "name": "Cardio Endurance"
    },
    {
      "image": "assets/gifs/0058_scene.gif",
      "text": "Exercise 29: Focus on shoulder strength with this routine.",
      "name": "Shoulder Strength Focus"
    },
    {
      "image": "assets/gifs/0063_scene.gif",
      "text": "Exercise 30: Strengthen your legs and improve stability.",
      "name": "Leg Stability"
    },
    {
      "image": "assets/gifs/0064_scene.gif",
      "text": "Exercise 31: Enhance your core with these exercises.",
      "name": "Core Enhancement"
    },
    {
      "image": "assets/gifs/0067_scene.gif",
      "text": "Exercise 32: Improve flexibility with these stretches.",
      "name": "Flexibility Stretch"
    },
    {
      "image": "assets/gifs/0068_scene.gif",
      "text":
          "Exercise 33: Build your endurance with this challenging routine.",
      "name": "Endurance Builder"
    },
    {
      "image": "assets/gifs/0084_scene.gif",
      "text":
          "Exercise 34: Work on your upper body strength with these exercises.",
      "name": "Upper Body Workout"
    },
    {
      "image": "assets/gifs/0085_scene.gif",
      "text": "Exercise 35: Improve your balance with these movements.",
      "name": "Balance Movements"
    },
    {
      "image": "assets/gifs/0086_scene.gif",
      "text": "Exercise 36: Strengthen your back with this focused workout.",
      "name": "Back Focus"
    },
    {
      "image": "assets/gifs/0087_scene.gif",
      "text": "Exercise 37: Boost your core stability with this sequence.",
      "name": "Core Stability Sequence"
    },
    {
      "image": "assets/gifs/0088_scene.gif",
      "text":
          "Exercise 38: Increase your cardiovascular fitness with this session.",
      "name": "Cardio Fitness"
    },
    {
      "image": "assets/gifs/0089_scene.gif",
      "text": "Exercise 39: Enhance your flexibility with this routine.",
      "name": "Flexibility Routine"
    },
    {
      "image": "assets/gifs/0090_scene.gif",
      "text": "Exercise 40: Focus on arm strength with these exercises.",
      "name": "Arm Strength Focus"
    },
    {
      "image": "assets/gifs/0091_scene.gif",
      "text": "Exercise 41: Improve your endurance with this workout.",
      "name": "Endurance Workout"
    },
    {
      "image": "assets/gifs/0092_scene.gif",
      "text": "Exercise 42: Work on your core stability with this exercise.",
      "name": "Core Stability"
    },
    {
      "image": "assets/gifs/0100_scene.gif",
      "text":
          "Exercise 43: Strengthen your legs with this series of exercises.",
      "name": "Leg Strength Series"
    },
    {
      "image": "assets/gifs/0101_scene.gif",
      "text": "Exercise 44: Improve your posture with this back routine.",
      "name": "Posture Routine"
    },
    {
      "image": "assets/gifs/0107_scene.gif",
      "text":
          "Exercise 45: Boost your cardiovascular health with this session.",
      "name": "Cardio Health Boost"
    },
    {
      "image": "assets/gifs/0109_scene.gif",
      "text": "Exercise 46: Focus on shoulder strength with these exercises.",
      "name": "Shoulder Focus"
    },
    {
      "image": "assets/gifs/0110_scene.gif",
      "text": "Exercise 47: Enhance your core with this focused workout.",
      "name": "Core Workout"
    },
    {
      "image": "assets/gifs/0114_scene.gif",
      "text": "Exercise 48: Build endurance with this routine.",
      "name": "Endurance Routine"
    },
    {
      "image": "assets/gifs/0115_scene.gif",
      "text": "Exercise 49: Strengthen your legs with these moves.",
      "name": "Leg Strength Moves"
    },
    {
      "image": "assets/gifs/0120_scene.gif",
      "text": "Exercise 50: Improve your flexibility with these stretches.",
      "name": "Flexibility Moves"
    },
    {
      "image": "assets/gifs/0121_scene.gif",
      "text":
          "Exercise 51: Boost your upper body strength with these exercises.",
      "name": "Upper Body Boost"
    },
    {
      "image": "assets/gifs/0129_scene.gif",
      "text": "Exercise 52: Enhance your balance with this exercise.",
      "name": "Balance Enhancer"
    },
  ];

  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    // Initialize the expansion state for each exercise
    _isExpanded = List<bool>.filled(exercises.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: exercises.length + 1, // Add 1 for the header
            itemBuilder: (context, index) {
              if (index == 0) {
                // This is the header item
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Text(
                        "Alle unsere Übungen",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }

              // Subtract 1 from index for exercises because index 0 is now the header
              final exerciseIndex = index - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded[exerciseIndex] = !_isExpanded[
                            exerciseIndex]; // Toggle expanded state
                      });
                    },
                    child: Image.asset(exercises[exerciseIndex]["image"]!),
                  ),
                  const SizedBox(height: 8),
                  ExpandableTextBox(
                    text: exercises[exerciseIndex]["text"]!,
                    exerciseName: exercises[exerciseIndex]["name"]!,
                    isExpanded:
                        _isExpanded[exerciseIndex], // Pass the expanded state
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfileAnalyticsPage extends StatelessWidget {
  final List<String> options2 = [
    'Nicht so oft',
    'Einmal pro Woche',
    'Mehrmals pro Woche',
    'Täglich'
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/settingsbg.PNG",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            title:
                const Text('Analytics', style: TextStyle(color: Colors.white)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<ProfilProvider>(
              builder: (context, profilProvider, child) {
                // Calculate consistency based on weekly goal and weekly done
                double consistencyRate = (profilProvider.weeklyGoal > 0)
                    ? (profilProvider.weeklyDone / profilProvider.weeklyGoal) *
                        100
                    : 0;

                // Calculate BMI
                double? bmi;
                if (profilProvider.weight != null &&
                    profilProvider.height != null) {
                  bmi = profilProvider.weight! /
                      ((profilProvider.height! / 100) *
                          (profilProvider.height! / 100));
                }

                // Calculate average exercises per week over the subscription period
                double avgExercisesPerWeek = 0;
                if (profilProvider.subStarted != null) {
                  final weeksSinceSub = DateTime.now()
                          .difference(profilProvider.subStarted!)
                          .inDays /
                      7;
                  avgExercisesPerWeek =
                      profilProvider.weeklyDone / weeksSinceSub;
                }

                // Calculate the goal achievement rate
                double goalAchievementRate = (profilProvider.goals.isNotEmpty)
                    ? (profilProvider.weeklyStreak /
                            profilProvider.goals.length) *
                        100
                    : 0;

                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0, // Smaller spacing between grid items
                  mainAxisSpacing: 8.0, // Smaller spacing between grid items
                  childAspectRatio: 2, // Makes the grid items smaller
                  children: [
                    _buildColumnWithText(
                      context: context,
                      dynamicText: "Einheiten",
                      dynamicText1: "${profilProvider.completedLevelsTotal}",
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: "Schmerzbereiche",
                      dynamicText1: "${profilProvider.hasPain.length}",
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: "Fitness",
                      dynamicText1:
                          "${options2.indexOf(profilProvider.fitnessLevel)}",
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Ziel',
                      dynamicText1: '${profilProvider.weeklyGoal}',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Konsistenz',
                      dynamicText1: '${consistencyRate.toStringAsFixed(1)}%',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'BMI',
                      dynamicText1:
                          bmi != null ? '${bmi.toStringAsFixed(1)}' : 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Durchschn. Übungen',
                      dynamicText1: avgExercisesPerWeek > 0
                          ? '${avgExercisesPerWeek.toStringAsFixed(1)}'
                          : 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Zielerreichung',
                      dynamicText1:
                          '${goalAchievementRate.toStringAsFixed(1)}%',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Serie',
                      dynamicText1: '${profilProvider.weeklyStreak} W.',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Abo-Status',
                      dynamicText1: profilProvider.payedSubscription != null &&
                              profilProvider.payedSubscription!
                          ? 'Aktiv'
                          : 'Inaktiv',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Schmerzberichte',
                      dynamicText1: profilProvider.hasPain.isNotEmpty
                          ? '${profilProvider.hasPain.length}'
                          : 'Keine',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Geburtsdatum',
                      dynamicText1: profilProvider.birthdate != null
                          ? '${profilProvider.birthdate!.toLocal()}'
                              .split(' ')[0]
                          : 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Geschlecht',
                      dynamicText1: profilProvider.gender ?? 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Gewicht',
                      dynamicText1: profilProvider.weight != null
                          ? '${profilProvider.weight} kg'
                          : 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Größe',
                      dynamicText1: profilProvider.height != null
                          ? '${profilProvider.height} cm'
                          : 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Fragebogen',
                      dynamicText1: profilProvider.questionnaireDone != null
                          ? profilProvider.questionnaireDone!
                              ? 'Ja'
                              : 'Nein'
                          : 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Abo-Typ',
                      dynamicText1: profilProvider.subType ?? 'N/A',
                    ),
                    _buildColumnWithText(
                      context: context,
                      dynamicText: 'Abo-Start',
                      dynamicText1: profilProvider.subStarted != null
                          ? '${profilProvider.subStarted!.toLocal()}'
                              .split(' ')[0]
                          : 'N/A',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnWithText({
    required BuildContext context,
    required String dynamicText,
    required String dynamicText1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The title or label outside the box, in white
        Text(
          dynamicText,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0), // Space between the label and the box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFf5f2f2),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFb3b3b3),
                offset: Offset(0, 5),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dynamicText1,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.lime[900],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
