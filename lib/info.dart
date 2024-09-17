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
      "text": """Bedeutung: 
Erinnerst du dich, wie du als Baby unbeschwert gerollt bist? Diese Übung ist mehr als nur Spaß: Sie verbessert die Verbindung zwischen Ober- und Unterkörper und fördert die segmentale Bewegung der Wirbelsäule. Sie sorgt für mehr Beweglichkeit und Koordination im gesamten Körper. Diese Übung sorgt für eine funktionelle Beweglichkeit, die vielen Erwachsenen fehlt.

Ausführung:
1.	Lege dich auf den Rücken, strecke Arme und Beine aus, als wärst du bereit für einen Mittagsschlaf.
2.	Nutze nur einen Arm, um dich langsam auf den Bauch zu rollen, ohne die Beine zu bewegen. Danach dasselbe Spiel rückwärts – nur mit den Beinen, während die Arme ruhig bleiben.
3.	Achte darauf, dass die Bewegung sanft und kontrolliert erfolgt – ganz so, wie ein Baby das tun würde!
""",
      "name": "Baby Rolling"
    },
    {
      "image": "assets/gifs/0010_scene.gif",
      "text": """Bedeutung: 
Stell dir vor, du bist im Boxring, aber anstelle eines Gegners kämpfst du gegen Bauchfett und Instabilität! Diese Übung kombiniert die Kraft eines Crunches mit einer dynamischen Rotationsbewegung, die vor allem deine schrägen Bauchmuskeln anspricht.

Ausführung:
1.	Stell deine Beine. Mache nun einen Crunch und führe dabei mit der gegenüberliegenden Hand eine Boxbewegung aus. Als ob du einem unsichtbaren Gegner den finalen Schlag verpassen möchtest!
2.	Wechsle die Seite bei jedem Crunch und halte die Bewegung kontrolliert. Achte darauf, dass deine Bauchmuskeln arbeiten, nicht der Schwung.
""",
      "name": "Boxer Crunch"
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
      "text": """Bedeutung: 
Du mobilisierst deine Hüftbeuger und kräftigst gleichzeitig deine Bauchmuskulatur. Gleichzeitig löst du Verspannungen im unteren Rücken und wirst wieder fit für deinen Alltag. Prävention: Indem du regelmäßig Hüfte und unteren Rücken mobilisierst, kannst du steife Hüftbeuger und verspannten Muskeln im unteren Rücken vorbeugen – zwei der Möglichen Ursachen für Rückenschmerzen.

Ausführung:
1. Lege dich entspannt auf den Rücken und ziehe ein Knie zur Brust, als ob du deinem Bein einen kurzen, freundlichen Gruß schickst.
2. Halte das andere Bein gestreckt und wechsle dann die Seite. Du kannst die Bewegung etwas schneller ausführen um gleichzeitig deine Bauchmuskulatur zu kräftigen.
        """,
      "name": "Alternating Knee Hugs"
    },
    {
      "image": "assets/gifs/0002_scene.gif",
      "text": """Bedeutung: 
Deine Brustwirbelsäule (BWS) ist oft ein vergessener Held, wenn es um Mobilität geht. Wenn wir viel sitzen, wird die BWS steif und unbeweglich, was zu Verspannungen im oberen Rücken und Nacken führen kann. Diese Rotation hilft dir, die Beweglichkeit in diesem Bereich zu verbessern 

Übungsausführung:
1.	Gehe in den Vierfüßlerstand, die Knie unter den Hüften und die Hände direkt unter den Schultern.
2.	Lege eine Hand hinter den Kopf und führe eine sanfte Rotationsbewegung durch, wobei du den Ellenbogen zur gegenüberliegenden Hand führst und dann nach oben öffnest.
3.	Stell dir vor, du öffnest einen alten, festgefahrenen Schrank – langsam und gezielt. Dein Blick folgt dabei der Hand.
        """,
      "name": "4 Füßler BWS Rotation"
    },
    {
      "image": "assets/gifs/0004_scene.gif",
      "text": """Bedeutung: 
Diese Übung ist eine leichtere Variante des Herabschauenden Hundes. Die Bewegung verlängert die Wirbelsäule, öffnet den Brustkorb und aktiviert die Rückenmuskeln – eine wahre Wohltat nach langem Sitzen.

Ausführung:
1.	Starte im Vierfüßlerstand, die Knie unter den Hüften und die Hände direkt unter den Schultern.
2.	Drücke dich durch die Hände nach oben, schiebe deine Hüfte zum Himmel und deinen Brustkorb zu den Knien.
3.	Komme wieder zurück in den Vierfüßlerstand und beginne von neuem.
""",
      "name": "Aufwachender Hund"
    },
    {
      "image": "assets/gifs/0005_scene.gif",
      "text": """Bedeutung: 
Erinnerst du dich, wie du als Baby unbeschwert gerollt bist? Diese Übung ist mehr als nur Spaß: Sie verbessert die Verbindung zwischen Ober- und Unterkörper und fördert die segmentale Bewegung der Wirbelsäule. Sie sorgt für mehr Beweglichkeit und Koordination im gesamten Körper. Diese Übung sorgt für eine funktionelle Beweglichkeit, die vielen Erwachsenen fehlt.

Ausführung:
1.	Lege dich auf den Rücken, strecke Arme und Beine aus, als wärst du bereit für einen Mittagsschlaf.
2.	Nutze nur einen Arm, um dich langsam auf den Bauch zu rollen, ohne die Beine zu bewegen. Danach dasselbe Spiel rückwärts – nur mit den Beinen, während die Arme ruhig bleiben.
3.	Achte darauf, dass die Bewegung sanft und kontrolliert erfolgt – ganz so, wie ein Baby das tun würde!
""",
      "name": "Baby Rolling"
    },
    {
      "image": "assets/gifs/0010_scene.gif",
      "text": """Bedeutung: 
Stell dir vor, du bist im Boxring, aber anstelle eines Gegners kämpfst du gegen Bauchfett und Instabilität! Diese Übung kombiniert die Kraft eines Crunches mit einer dynamischen Rotationsbewegung, die vor allem deine schrägen Bauchmuskeln anspricht.

Ausführung:
1.	Stell deine Beine. Mache nun einen Crunch und führe dabei mit der gegenüberliegenden Hand eine Boxbewegung aus. Als ob du einem unsichtbaren Gegner den finalen Schlag verpassen möchtest!
2.	Wechsle die Seite bei jedem Crunch und halte die Bewegung kontrolliert. Achte darauf, dass deine Bauchmuskeln arbeiten, nicht der Schwung.
""",
      "name": "Boxer Crunch"
    },
    {
      "image": "assets/gifs/0013_scene.gif",
      "text": """Bedeutung: 
Diese Abfolge aus Kind- und Kobra-Position bietet dir das Beste aus zwei Welten: Tiefe Entspannung und aktive Dehnung. Während die Kind-Position den unteren Rücken und die Hüften sanft dehnt, öffnet die Kobra den Brustkorb und im Wechsel mobilisierst du sanft deine Wirbelsäule.

Ausführung:
1.	Starte in der Kind-Position: Knie am Boden, Gesäß auf den Fersen, Arme nach vorne ausgestreckt.
2.	Gleite in die Kobra-Position, indem du den Oberkörper nach vorne schiebst und dann deine Brust nach oben öffnest. Deine Hüften bleiben am Boden, während du den Rücken streckst.
3.	Wechsle zwischen beiden Positionen hin und her, spüre, wie du Spannung loslässt und gleichzeitig deine Wirbelsäule mobilisierst. Atme tief ein und aus, als ob du dich sanft wie eine Welle bewegst.
""",
      "name": "Kind zu Cobra"
    },
    {
      "image": "assets/gifs/0015_scene.gif",
      "text": """Bedeutung: 
Die Kind-Position ist die ultimative Entspannungspose. Sie dehnt sanft deinen Rücken und öffnet die Hüften. Perfekt, um nach einem langen Tag (oder einem harten Workout) in die Entspannung zu gleiten.

Ausführung:
1.	Knie dich auf den Boden, die großen Zehen berühren sich, die Knie leicht auseinander.
2.	Setz dich mit dem Gesäß auf die Fersen und strecke die Arme nach vorne, während du deinen Oberkörper sanft in Richtung Boden sinken lässt.
3.	Deine Stirn berührt den Boden (oder eine Decke, wenn du es dir richtig gemütlich machen willst), und du atmest tief ein und aus. Entspanne den gesamten Rücken – als ob du dich in einen kuscheligen Kokon einhüllst.
""",
      "name": "Child Pose"
    },
    {
      "image": "assets/gifs/0016_scene.gif",
      "text": """Bedeutung: 
Dies ist die mobilere Version der klassischen Kind-Position. Durch die einseitige Armstreckung wird der gesamte Brust und Rückenmuskulatur auf der jeweiligen Seite gedehnt. Dies kann Verspannungen im Nacken- und Schulterbereich reduzieren und die Beweglichkeit im Oberkörper verbessern – optimal zur Prävention von Schulterschmerzen.

Ausführung:
1.	Beginne im Vierfüßlerstand, lasse einen Arm am Boden und winkle den anderen ab. Schieb deine Hüfte nach Hinten und spüre die Dehnung.
2.	Dann wechselst du dynamisch die Seite: Von einem Arm auf den anderen, sodass du sanft in die Bewegung hineinwippst.
""",
      "name": "Dynamisch Einarmige Child Pose"
    },
    {
      "image": "assets/gifs/0019_scene.gif",
      "text": """Bedeutung: 
Diese Mobilisationsübung für die Hüften und Sprunggelenke kommt aus dem Bereich der kindlichen Entwicklung. Eine gute Hüftmobilität ist der Schlüssel zu einem stabilen und Schmerzfreien Rücken.

Ausführung:
1.	Du startest in Bauchlage. Komme hoch auf eine Seite und stell deinen Fuß vor dem Knie ab.
2.	Spüre die Dehnung in der hinteren Hüfte und halte den Rücken lang. Halte diese Pose für einen Moment und wechsle dann zur anderen Seite.
""",
      "name": "Großer Gartenzwerg"
    },
    {
      "image": "assets/gifs/0020_scene.gif",
      "text": """Bedeutung: 
Diese Übung mobilisiert das Hüftgelenk und fördert die Rotationsbewegung – ein echter Allrounder für die Mobilität der Hüftregion. Stell dir vor, du schmierst dein Hüftgelenk mit einer ordentlichen Portion Bewegungsöl. Wenn die Hüfte frei rotieren kann, wird der Druck von der Lendenwirbelsäule genommen, was Rückenschmerzen und Hüftbeschwerden verhindert.

Ausführung:
1.	Setze dich auf den Boden, Beine angewinkelt und breit auseinandergestellt. 
2.	Nun lass beide Knie zu einer Seite fallen. Deine Knie und Schienbeine liegen flach auf dem Boden. Lass deiner Hüfte weiter zum Boden sinken.
3.	Dann öffne im Knie und rotiere langsam zur anderen Seite. Halte den Oberkörper aufrecht und spüre die sanfte Rotation in deinen Hüften. 
""",
      "name": "Hip Swifel"
    },
    {
      "image": "assets/gifs/0021_scene.gif",
      "text": """Bedeutung: 
Hier geht es noch eine Stufe tiefer in die Hüftmobilisation – nur diesmal lehnst du dich dabei vor, um noch mehr Bewegungsfreiheit zu bekommen. Diese Variation der Hip Swifel-Übung intensiviert die Dehnung und bringt zusätzlichen Raum in das Hüftgelenk. Die erhöhte Mobilität in der Hüfte sorgt dafür, dass Bewegungen, die sonst vielleicht im unteren Rücken kompensiert würden, wieder direkt in der Hüfte stattfinden. 

Ausführung:
1.	Setze dich wie beim normalen Hip Swifel auf den Boden, Beine angewinkelt und breit aufgestellt.
2.	Deine Knie fallen nun zu einer Seite. Knie und Schienbeine liegen auf dem Boden. Nun lehnst du dich mit langem Rücken nach vorne. Versuche den Brustkorb Richtung Fuß zu bringen.
3.	Dann wechselst du zur anderen Seite und startest von vorne.
""",
      "name": "Hip Swifel lehnen"
    },
    {
      "image": "assets/gifs/0025_scene.gif",
      "text": """Bedeutung: 
Diese klassische Bewegung aus dem Yoga fördert die Mobilität der gesamten Wirbelsäule – von der Hals- bis zur Lendenwirbelsäule. Durch das Wechselspiel von Beugung und Streckung mobilisiert du den Rücken und förderst die Versorgung deiner Bandscheiben mit Nährstoffen.

Ausführung:
1.	Starte im Vierfüßlerstand: Knie unter den Hüften, Hände unter den Schultern.
2.	Atme ein und wölbe deinen Rücken wie eine glückliche Katze – Kopf und Steißbein zeigen nach oben.
3.	Atme aus und mach einen Rundrücken, als würdest du dich wie eine Katze beim Strecken einrollen. Dein Kopf sinkt in Richtung Brust, und dein Steißbein rollt ein.
4.	Wechsle im Atemrhythmus zwischen diesen beiden Positionen und spüre, wie sich deine Wirbelsäule langsam entspannt und geschmeidiger wird
""",
      "name": "Katze Kuh"
    },
    {
      "image": "assets/gifs/0028_scene.gif",
      "text": """Bedeutung: 
Die kleinen Cobra Lifts sind perfekt, als Einsteigerübung zur Cobra. Du öffnest deine ganze Körperseite von den Fußspitzen bis zur Stirn. Wenn du dabei Schmerzen hast markiere diese Übung. Einige Personen reagieren negativ auf Extensionen der Wirbelsäule. Gebe deinem Coach ein Feedback, um dein Training anzupassen.

Ausführung:
1.	Lege dich auf den Bauch und setze die Ellbogen unter die Schultern.
2.	Schiebe die Ellbogen in den Boden. Hebe sanft den Oberkörper nur ein kleines Stück vom Boden ab, und schaue hoch zur Decke – stell dir vor, du bist eine kleine Kobra, die sich vorsichtig aus ihrem Versteck erhebt.
3.	Atme tief Richtung Bauchnabel ein und entspanne die Vorderseite deines Körpers. Dann lasse dich wieder absinken und starte von vorne.
""",
      "name": "Kleine Cobra Lifts"
    },
    {
      "image": "assets/gifs/0029_scene.gif",
      "text": """Bedeutung: 
Diese Übung sieht nicht nur aus wie eine Umarmung, sie fühlt sich auch so an – allerdings für deine Hüften und den unteren Rücken. Sie verbessert die Beweglichkeit deiner Hüften und dehnt gleichzeitig die Muskeln im unteren Rücken, um Verspannungen zu lösen.

Ausführung:
1.	Lege dich auf den Rücken, strecke die Beine aus und ziehe dann ein Knie zur Brust, als ob du es liebevoll umarmen möchtest.
2.	Halte die Position einige Sekunden. Achte darauf, dass dein unterer Rücken flach auf dem Boden bleibt. Atme ganz locker und entspanne dich in die Position. Dann wechsle langsam die Seite.
""",
      "name": "Knee Hug"
    },
    {
      "image": "assets/gifs/0031_scene.gif",
      "text": """Bedeutung: 
Hier kommt Bewegung ins Spiel! Krabbeln mit Tap ist eine Ganzkörperübung, die nicht nur die Rumpfstabilität fördert, sondern auch die Koordination verbessert. Stell dir vor, du bist ein aufmerksamer Bär, der durch den Wald krabbelt, dabei jedoch dynamisch seine Hand zum gegenüberliegenden Knie führt – für Extra-Stabilität. Diese Übung stärkt die Core-Muskulatur, die dafür sorgt, dass die Wirbelsäule stabil bleibt. Das hilft, Überlastungen im unteren Rücken vorzubeugen.

Ausführung:
1.	Gehe in die Krabbelposition (Vierfüßlerstand), hebe die Knie leicht vom Boden ab, sodass nur deine Hände und Zehen den Boden berühren.
2.	Krabbele langsam vorwärts und tippe dabei mit einer Hand leicht auf das gegenüberliegende Knie – ein koordinierter Wechsel von links nach rechts.
3.	Halte dabei den Rücken stabil und den Bauch fest angespannt. Der Tap ist sanft, aber effektiv, um deinen Core und deine Beweglichkeit zu trainieren.
""",
      "name": "Krabbeln mit Tap"
    },
    {
      "image": "assets/gifs/0032_scene.gif",
      "text": """Bedeutung: 
Dies ist eine Übung für die Details – die Mobilisierung deiner Fußgelenke. Bewegliche Sprunggelenke sind entscheidend, um eine gesunde Kinematik in den unteren Extremitäten zu gewährleisten. Sie helfen, Druck von den Knien und Hüften zu nehmen, indem sie eine natürliche Bewegungsdynamik beim Gehen und Laufen ermöglichen. 

Ausführung:
1.	Setze dich aufrecht hin, die Beine gestreckt vor dir.
2.	Kreise beide Füße langsam und kontrolliert im Uhrzeigersinn, dann in die andere Richtung.
""",
      "name": "Langsitz Fußkreise"
    },
    {
      "image": "assets/gifs/0033_scene.gif",
      "text": """Bedeutung: 
Eine Variation des „Herabschauenden Hundes“ aus dem Yoga, bei der du die Beine abwechselnd beugst und streckst. Diese Übung zielt darauf ab, die Flexibilität der Beinrückseiten zu fördern. Gleichzeitig wird durch die aktive Streckung des Oberkörpers die Schulterbeweglichkeit verbessert, was Verspannungen im Nacken- und Schulterbereich vorbeugt.

Ausführung:
1.	Beginne im „Herabschauenden Hund“: Hände fest auf dem Boden, Hüften schiebt zum Himmel, Brustkorb zu den knien.
2.	Jetzt beginnst du, ein Bein nach dem anderen zu beugen, während du das andere Bein streckst – wie ein Hund, der auf der Stelle "läuft".
3.	Wechsle in einem fließenden Rhythmus ab und spüre die Dehnung in den Beinen und Schultern. Bleib locker und genieße den dynamischen Flow.
""",
      "name": "Laufender Hund"
    },
    {
      "image": "assets/gifs/0035_scene.gif",
      "text": """Bedeutung: 
Eine simple, aber äußerst effektive Übung zur Mobilisation des Nackens, durchgeführt in Rückenlage. Du drehst deinen Kopf langsam von einer Seite zur anderen und bringst so wieder Bewegung in die oft verspannte Nackenmuskulatur. Durch das sanfte Rotieren des Nackens kannst du nach langem starren aufs Handy wieder Bewegung in die Nackenmuskulatur bringen.

Ausführung:
1.	Lege dich bequem auf den Rücken, die Arme entspannt neben dem Körper.
2.	Drehe deinen Kopf langsam zur einen Seite, als würdest du dich neugierig umsehen, und dann zur anderen Seite.
3.	Bewege deinen Kopf ruhig und kontrolliert, ohne zu reißen. Der Nacken sollte sich dabei langsam entspannen – perfekt, um den Tag hinter dir zu lassen.
""",
      "name": "RL Nackenrotationen"
    },
    {
      "image": "assets/gifs/0037_scene.gif",
      "text": """Bedeutung: 
Diese Übung kombiniert Dynamik und Mobilität, indem du dich aus der Rückenlage in den Seitsitz rollst. Du mobilisierst dabei deine Hüftmuskulatur und benutzt den Boden als Faszienrolle für deinen Rücken.

Ausführung:
1.	Lege dich entspannt auf den Rücken, die Arme ausgestreckt zur Seite.
2.	Dann rolle dich hoch auf eine Seite in den Seitsitz, dein Knie liegt vor der Fußsohle.
3.	Halte die Position kurz und rolle dann zurück in die Rückenlage. Wechsle die Seiten und genieße den fließenden Bewegungsablauf.
""",
      "name": "Rolle zu Seitsitz"
    },
    {
      "image": "assets/gifs/0038_scene.gif",
      "text": """Bedeutung: 
Dieser Push-Up ist eine spezielle Variante, die gezielt auf die Mobilität und Stabilität der Schulterblätter (Scapulae) abzielt. Du trainierst dabei die Protraktion und Retraktion der Schulterblätter, was deine Schultergesundheit langfristig fördert. Durch die gezielte Aktivierung der Muskeln rund um die Schulterblätter stabilisierst du deine Schultern und beugst Überlastungen und Fehlhaltungen vor.

Ausführung:
1.	Du startest im Vierfüßlerstand: Hände unter den Schultern, Knie unter der Hüfte
2.	Anstatt deine Arme zu beugen, lässt du deine Schulterblätter zusammenkommen und dann auseinanderdriften – stell dir vor, deine Schultern wären Flügel, die sich erst zusammenfalten und dann ausbreiten.
3.	Deine Arme bleiben gestreckt dabei
""",
      "name": "Scapula PushUp"
    },
    {
      "image": "assets/gifs/0039_scene.gif",
      "text": """Bedeutung: 
In dieser Pose im Schneidersitz fokussierst du streckst du deinen Arm zur Seite um deinen Latissimus den großen Rückenmuskel zu dehnen. Dabei öffnest du deine ganze Körperseite und beugst Rückenschmerzen vor.

Ausführung:
1.	Setze dich im Schneidersitz auf den Boden, dann streck einen Arm hoch zur Decke.
2.	Spüre die Dehnung in deinem Rücken und atme entspannt weiter. Dann wechsle die Seite.
""",
      "name": "Rückendehnung Schneidersitz"
    },
    {
      "image": "assets/gifs/0041_scene.gif",
      "text": """Bedeutung: 
Der Triangle Stretch ist eine klassische Yoga-Position, die eine seitliche Dehnung des Oberkörpers und eine Aktivierung der Beinmuskulatur kombiniert. Diese Übung verbessert die Flexibilität der Körperseiten und stärkt gleichzeitig die Standfestigkeit.

Wie beugt diese Übung Schmerzen vor: 
Die Dreiecksdehnung fördert die Beweglichkeit der seitlichen Rumpfmuskulatur und der Hüften. Indem du die Körperseiten regelmäßig dehnst, beugst du Rückenschmerzen vor, die oft durch Verkürzungen in der seitlichen Muskulatur entstehen.

Übungsausführung:
1.	Stelle dich breitbeinig hin, die Arme gestreckt zur Seite, als würdest du dir ein großes "T" vorstellen.
2.	Beuge dich zu einer Seite, lass die Hand am Bein entlang gleiten, während du den anderen Arm Richtung Himmel streckst.
3.	Halte deinen Körper in einer Linie und spüre die intensive Dehnung an der Seite. Wiederhole auf der anderen Seite – stell dir vor, du wirst lang und leicht, wie ein Dreieck in Bewegung.
""",
      "name": "Triangle Stretch"
    },
    {
      "image": "assets/gifs/0043_scene.gif",
      "text": """Bedeutung: 
Der angewinkelte Käfer trainiert die tiefen Bauchmuskeln und fördert die Stabilität der Wirbelsäule, während du Arme und Beine abwechselnd bewegst. Stell dir vor, du bist ein Käfer auf dem Rücken, der versucht, sich zu koordinieren. Durch die gezielte Aktivierung der Core-Muskulatur hilft diese Übung, Rückenschmerzen vorzubeugen, besonders bei Bewegungen, die eine stabile Körpermitte erfordern.

Ausführung:
1.	Lege dich auf den Rücken, hebe die Beine an und beuge sie in einem 90-Grad-Winkel. Die Arme streckst du nach oben.
2.	Senke langsam einen Arm und das gegenüberliegende angewinkelte Bein, bis sie knapp über dem Boden schweben, dann bringe sie zurück in die Ausgangsposition.
3.	Wechsle die Seiten und halte dabei deinen Core fest angespannt. Dein unterer Rücken bleibt flach auf dem Boden – der Käfer darf nicht umkippen!
""",
      "name": "Käfer angewinkelt"
    },
    {
      "image": "assets/gifs/0044_scene.gif",
      "text": """Bedeutung: 
Diese Atemübung, fördert die Zwerchfellatmung und hilft, dir mit jedem Atemzug eine natürliche Stabilität im Rumpf aufzubauen. Durch die Ausbreitung deines Zwerchfells im ganzen Bauchraum erzeugt dein Atem einen intraabdominalen Druck, der deiner Wirbelsäule Stabilität verleiht und dir ermöglicht schwere Gegenstände besser heben zu können

Ausführung:
1.	Du startest in Rückenlage und bringst die Beine im 90° Winkel in die Luft. Setz nun deine Hände wie Zangen direkt unter deinen Brustkorb.
2.	Atme tief durch die Nase in deinen Bauch, sodass deine Hände auseinander Bewegen und deine Finger nach vorne und hinten gedrückt werden. Spüre die volle 360° Ausweitung deines Zwerchfells.
""",
      "name": "Tucked Krokodilatmung"
    },
    {
      "image": "assets/gifs/0045_scene.gif",
      "text": """Bedeutung: 
In dieser Position dehnst du die Vorderseite des Oberschenkels (Quadrizeps). Eine perfekte Übung, um die Hüfte zu öffnen und die Flexibilität in der Oberschenkelmuskulatur zu verbessern. Die regelmäßige Dehnung dieser Muskulatur beugst du Rücken- und Kniebeschwerden vorzubeugen.

Ausführung:
1.	Lege dich auf die Seite, stütze deinen Kopf auf deinem Arm ab, damit du entspannt bleibst.
2.	Greife mit der oberen Hand deinen Fußknöchel und ziehe den Fuß sanft in Richtung Gesäß, bis du eine angenehme Dehnung an der Vorderseite des Oberschenkels spürst.
3.	Achte darauf, dass dein Becken neutral bleibt und du nicht ins Hohlkreuz gehst. Halte diese Position und atme ruhig ein und aus – als ob du deine Muskeln liebevoll strecken würdest.
""",
      "name": "Seitlage Oberschenkeldehnung"
    },
    {
      "image": "assets/gifs/0047_scene.gif",
      "text": """Bedeutung: 
Diese Übung bringt eine wunderbare Rotation in deine Wirbelsäule und mobilisiert die gesamte Rumpf- und Lendenregion. Die Bewegung ist sanft, aber tiefwirkend – perfekt, um den unteren Rücken und die Hüften zu lockern. Regelmäßige Rotationen der Wirbelsäule helfen, Verspannungen im unteren Rücken zu lösen und die Mobilität zu verbessern. 

Ausführung:
1.	Lege dich auf den Rücken, die Arme seitlich ausgestreckt wie ein „T“.
2.	Beuge die Knie und lass sie langsam und kontrolliert zu einer Seite kippen, während du den Oberkörper auf dem Boden lässt.
3.	Kehre zurück zur Mitte und wiederhole die Bewegung auf der anderen Seite. Atme tief ein, während du die Rotation ausführst, und spüre, wie dein Rücken sanft nachgibt – wie ein gemütliches Ausstrecken nach dem Aufwachen.
""",
      "name": "Supine Rotations"
    },
    {
      "image": "assets/gifs/0050_scene.gif",
      "text": """Bedeutung: 
Stress und Anspannung können oft die Ursache für körperliche Schmerzen sein, insbesondere im Rücken und Nacken. Durch bewusste Entspannung und Atemkontrolle kann diese Meditation helfen, Muskelverspannungen zu lösen, mentale Ruhe zu finden und Schmerzen vorzubeugen.

Ausführung:
1.	Lege dich flach auf den Rücken, die Arme entspannt neben dem Körper, die Handflächen nach oben gerichtet.
2.	Schließe die Augen und konzentriere dich auf deine Atmung. Lass deine Atmung ganz entspannt durch die Nase tief in deinen Bauch fließen.
3.	Lass jeden Teil deines Körpers in den Boden sinken – wie eine Feder, die sanft zur Ruhe kommt.
""",
      "name": "Liegende Meditation"
    },
    {
      "image": "assets/gifs/0058_scene.gif",
      "text": """Bedeutung: 
Diese dynamische Übung mobilisiert die Hüften und Füße, stärkt gleichzeitig die Beinmuskulatur und verbessert die Rumpfstabilität. Eine gut mobilisierte Hüfte und stabile Beinmuskulatur sind entscheidend, um Knie- und Rückenbeschwerden zu verhindern. 

Ausführung:
1.	Du startest im Fersensitz mit den Zehen aufgestellt und den Händen auf dem Boden.
2.	Heb dann deine Knie auf und schieb deine Fersen zum Boden um eine Dehnung über die ganze Unterseite deiner Füße zu spüren.
""",
      "name": "Bärenhocke"
    },
    {
      "image": "assets/gifs/0063_scene.gif",
      "text": """Bedeutung: 
Diese Übung dehnt den Piriformis-Muskel, der tief in der Hüfte sitzt und oft für Schmerzen im unteren Rücken und der Hüfte verantwortlich ist. Ein entspannter und gut gedehnter Piriformis verhindert, dass Druck auf den Ischiasnerv ausgeübt wird und beugt Schmerzen vor.

Ausführung:
1.	Setze dich auf den Boden, stütze dich mit den Händen hinter dir ab, die Beine sind vor dir angewinkelt.
2.	Hebe das Gesäß leicht vom Boden ab, bringe einen Fuß auf das gegenüberliegende Knie und lass die Hüfte zur Seite sinken, um den Piriformis zu dehnen.
3.	Halte die Position, atme tief und wechsle dann die Seite. Dein Körper wird sich entspannt und beweglicher anfühlen, als hätte er gerade eine Auszeit bekommen!
""",
      "name": "Krabbe Piriformis beidseitig"
    },
    {
      "image": "assets/gifs/0064_scene.gif",
      "text": """Bedeutung: 
Diese Variation des Scapula Push-Ups (Schulterblatt-Liegestütze) findet in der Krabbenposition statt. Schulterstabilität ist essenziell, um Nacken- und Schulterschmerzen zu verhindern. Durch die Stärkung der Muskeln um die Schulterblätter sorgst du dafür, dass deine Schultern bei alltäglichen Bewegungen stabil bleiben und Überlastungen vermieden werden.

Ausführung:
1.	Setze dich in die Krabbenposition: Hände hinter dir auf dem Boden, Füße flach aufgestellt, und hebe dein Gesäß leicht an.
2.	Lass nun deine Arme gestreckt und schieb deine Schultern weg von den Ohren. Lass dich danach einsinken, bis deine Schultern fast an den Ohren sind.
3.	Spüre dabei wann deine Schultern wirklich weg von den Ohren sind und merke dir diese Position für den Alltag.
""",
      "name": "Krabbe Scapula PushUp"
    },
    {
      "image": "assets/gifs/0067_scene.gif",
      "text": """Bedeutung: 
Die Glute Bridge ist eine großartige Übung zur Aktivierung und Kräftigung der Gesäßmuskulatur und der hinteren Oberschenkel. Sie stärkt den gesamten hinteren Kettenbereich – von der Lendenwirbelsäule über den Po bis hin zu den Beinen.

Ausführung:
1.	Lege dich auf den Rücken, die Knie angewinkelt, die Füße hüftbreit aufgestellt.
2.	Drücke die Fersen in den Boden und hebe das Becken, bis dein Körper eine gerade Linie von den Knien bis zu den Schultern bildet.
3.	Halte die Position für ein paar Sekunden und senke das Becken dann wieder ab. Spanne dein Gesäß oben richtig fest an – stell dir vor, du zerdrückst eine Walnuss!
""",
      "name": "Glute Bridge"
    },
    {
      "image": "assets/gifs/0068_scene.gif",
      "text": """Bedeutung: 
Diese Übung trainiert deine seitliche Rumpfmuskulatur und stabilisiert die Schultern. Starke seitliche Rumpfmuskeln schützen die Wirbelsäule vor unerwünschten Bewegungen und helfen dabei, die Stabilität zu erhöhen. 

Ausführung:
1.	Gehe in die seitliche Plank-Position auf deinen Knien, stütze dich auf deinen Unterarm und bringe den freien Arm nach oben.
2.	Hebe das Becken an, bis dein Körper eine gerade Linie bildet. Bringe dann Ellbogen und Knie vom oberen Arm und Bein zusammen und streck dich wieder lang.
""",
      "name": "Kniender Seitplank Taps"
    },
    {
      "image": "assets/gifs/0084_scene.gif",
      "text": """Bedeutung: 
Steife Schultern? Nicht mehr mit dieser Übung! Schulterkreise helfen, Verspannungen und Steifheit zu lösen, die durch lange Phasen des Sitzens entstehen. Sie fördern die Durchblutung und verbessern die Schultergesundheit, was Schulterschmerzen vorbeugen kann.

Ausführung:
1.	Stelle dich aufrecht hin, die Arme entspannt an den Seiten.
2.	Führe nun sanfte, kreisende Bewegungen mit den Schultern nach vorne und dann nach hinten aus, als würdest du langsam ein Rad drehen.
3.	Spüre die Mobilisierung in deinem Schulterbereich und achte darauf, dass der Nacken entspannt bleibt. Diese Übung ist wie eine kleine Massage für deine Schultern!
""",
      "name": "Stand Schulterkreise"
    },
    {
      "image": "assets/gifs/0085_scene.gif",
      "text":
          """Bedeutung: Diese Übung zielt auf die Beweglichkeit der Hüften und Oberschenkel ab, indem du von einer Seite zur anderen in einer breitbeinigen Vorbeuge kommst. Durch die Mobilisierung der Hüften und die Dehnung der Beinrückseiten kannst du die Spannung im unteren Rücken reduzieren. 
Ausführung:
1.	Stelle dich breitbeinig hin und beuge dich mit geradem Rücken nach vorne, die Hände auf den Boden gestützt.
2.	Lauf nun mit deinen Händen zu einem Fuß rüber und spüre dabei auch die Dehnung im Rücken.
3.	Dann komm langsam zu anderen Seite .
""",
      "name": "Gegrätschte Vorbeuge Side to Side"
    },
    {
      "image": "assets/gifs/0086_scene.gif",
      "text": """Bedeutung: 
Diese Variante der Vorbeuge fügt eine Rotation des Oberkörpers hinzu. Durch die Rotation der Wirbelsäule werden Verspannungen im Rücken gelöst, und die Mobilität der Brustwirbelsäule verbessert. Dies hilft, Rückenschmerzen zu verhindern, die oft durch eine steife Wirbelsäule entstehen.

Ausführung:
1.	Stelle dich wie in der gegrätschten Vorbeuge breitbeinig hin und beuge dich mit geradem Rücken nach vorne.
2.	Strecke eine Hand nach oben, während die andere den Boden berührt oder sich auf dem Bein abstützt. Drehe den Oberkörper dabei sanft zur Seite.
3.	Halte die Rotation, spüre die Dehnung entlang der seitlichen Rumpfmuskulatur, und wechsle dann die Seite. Du wirst dich fühlen, als würdest du deinen Rücken sanft auswringen – wie ein frisches Handtuch nach dem Waschen!
""",
      "name": "Gegrätschte Vorbeuge mit Rotation"
    },
    {
      "image": "assets/gifs/0087_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese Bewegung verbessert die Beweglichkeit der Wirbelsäule und der Beinrückseiten. Der Jefferson Curl dehnt und stärkt den unteren Rücken, was Rückenschmerzen vorbeugt, die durch Steifheit in der Wirbelsäule und den Hamstrings entstehen.

Ausführung:
1.	Beginne in der Mountain Pose: Füße hüftbreit, Arme an den Seiten, stehe aufrecht und richte dich auf – wie ein Berg, der fest in der Erde verankert ist. 
2.	Rolle dich dann Wirbel für Wirbel nach vorne in den Jefferson Curl, lasse den Kopf zuletzt hängen und spüre die Dehnung entlang der gesamten Wirbelsäule und Beinrückseiten.
3.	Rolle dich langsam wieder auf, und führe die Bewegung kontrolliert aus, als ob du jeden Wirbel einzeln bewegst. Dein Rücken wird sich dabei locker und entspannt anfühlen, wie ein biegsamer Ast im Wind.
""",
      "name": "Mountain Pose zu Jefferson Curl"
    },
    {
      "image": "assets/gifs/0088_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese Übung kombiniert das langsame, kontrollierte Runterrollen mit einer Vorbeuge aus einer breitbeinigen Position. Durch das langsame Runterrollen und die Dehnung der Beinrückseiten werden Verspannungen im unteren Rücken gelöst und verbessert gleichzeitig deine Beweglichkeit in der Hüfte.

Ausführung:
1.	Stelle dich breitbeinig hin, die Beine etwa doppelt schulterbreit auseinander.
2.	Beginne, dich langsam Wirbel für Wirbel nach unten zu rollen, beginnend mit dem Kopf. Lass deinen Oberkörper schwer hängen, während du in die Vorbeuge gleitest.
3.	Halte unten kurz inne, lass den Kopf locker und spüre die Dehnung in den Beinrückseiten. Rolle dich dann kontrolliert wieder auf, als würdest du deine Wirbelsäule wie ein sanftes Seil ab- und wieder aufrollen.
""",
      "name": "Gegrätschte Vorbeuge runterrollen"
    },
    {
      "image": "assets/gifs/0089_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Durch den Wechsel zwischen Hocke und Vorbeuge mobilisierst du die Hüften und dehnst die Beinmuskulatur, was Spannung im unteren Rücken löst. Die Übergänge sind fließend und mobilisieren die gesamte hintere Kette. Mit dieser Übung bereitest du dich perfekt auf schwierigere Varianten der Tiefen Hocke vor.

Ausführung:
1.	Starte im Stand, die Füße schulterbreit, die Fersen auf dem Boden.
2.	Beuge jetzt leicht deine Beine und komm in eine leichte Hocke. Dein Blick zeigt nach vorne.
3.	Streck jetzt deine Beine und lass den Kopf leicht Richtung Boden hängen. Spüre die Mobilisierung in den Hüften und wiederhole das Ganze mehrmals. Achte darauf, die Bewegung kontrolliert und im Rhythmus deines Atems durchzuführen.
""",
      "name": "Easy Hocke zu Vorbeuge"
    },
    {
      "image": "assets/gifs/0090_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Eine tiefe, stabile Hocke ist der Schlüssel zu gesunden Hüften und Knien. Wenn du die Beweglichkeit in diesen Bereichen verbesserst, beugst du Schmerzen vor, die durch Steifheit oder Überlastung in den Gelenken entstehen können. Sie ist ein wahrer Allrounder und verbessert die Beweglichkeit der Hüftgelenke, Beine und Knöchel.

Ausführung:
1.	Stelle dich schulterbreit hin, die Füße leicht nach außen gedreht.
2.	Senke dich langsam in die tiefe Hocke, indem du die Hüften nach hinten schiebst und die Knie beugst, während du den Oberkörper aufrecht hältst.
3.	Komm jetzt locker von einer zur anderen Seite. Deine Fersen dürfen im Wechsel abheben, um die Übung etwas zu vereinfachen.
""",
      "name": "Hocke reinkommen"
    },
    {
      "image": "assets/gifs/0091_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Durch die Rotation in der Wirbelsäule beugst du Verspannungen im ganzen Rücken vor. Der Übergang zur Vorbeuge mobilisiert die ganze hintere Kette und fördert die Beweglichkeit deines Körpers.

Ausführung:
1.	Beginne in einer tiefen Hocke, die Füße etwas weiter als schulterbreit auseinander.
2.	Drehe den Oberkörper sanft zu einer Seite und strecke den Arm nach oben, während du den anderen Arm auf den Boden stützt.
3.	Gehe fließend in eine Vorbeuge, indem du die Beine streckst, und wechsle dann wieder in die Hocke, bevor du die Seite der Rotation wechselst. Halte die Bewegung geschmeidig, als würdest du durch Wasser gleiten.
""",
      "name": "Hocke Rotation zu Vorbeuge"
    },
    {
      "image": "assets/gifs/0092_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese Übung ist eine dynamische Variante der Kniebeuge, bei der du mit den Armen leicht schwingst, während du dich aufrichtest und absenkst. Die schwingende Bewegungen sind ein einfacher Weg um deine Faszien zu lockern und Verklebungen zu lösen.

Ausführung:
1.	Stehe aufrecht, die Füße schulterbreit auseinander.
2.	Beuge die Knie und senke dich in die Kniebeuge, während du die Arme nach vorne schwingst.
3.	Wenn du dich wieder aufrichtest, schwingen die Arme sanft nach oben. Nutze die Bewegung, um einen fließenden Rhythmus zu finden, als ob du sanft durch die Luft schwingen würdest.
""",
      "name": "Kniebeuge Schwingen"
    },
    {
      "image": "assets/gifs/0100_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese sanfte Bewegungsübung zielt darauf ab, die Hüften in alle Richtungen zu mobilisieren. Bewegliche Hüftgelenke sind entscheidend, um Druck von den Knien und dem unteren Rücken zu nehmen. Diese Übung hilft, Verspannungen zu lösen und die Beweglichkeit in den Hüften zu verbessern, was Schmerzen in diesen Bereichen vorbeugen kann.

Ausführung:
1.	Stelle dich aufrecht hin, die Füße hüftbreit auseinander.
2.	Beginne, deine immer ein Knie nach außen zu öffnen und hebe dabei dein Bein ab.
3.	Wechsle nun die Seite und öffne deine andere Seite.
""",
      "name": "Hüfte lockern"
    },
    {
      "image": "assets/gifs/0101_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Controlled Articular Rotations (CARs) sind gezielte, kontrollierte Rotationsbewegungen, die die Mobilität des Hüftgelenks verbessern. Hüft-CARs helfen, die Beweglichkeit zu erhalten und verhindern so Schmerzen im unteren Rücken und in den Knien, die oft durch eingeschränkte Hüftmobilität entstehen.

Ausführung:
1.	Stehe aufrecht und stütze dich bei Bedarf mit einer Hand an einer Wand ab.
2.	Hebe ein Bein angewinkelt , öffne dein Knie dann zur Seite. Deine Hüfte zeigt weiter nach vorne. Hebe nun leicht deine Ferse nach oben und komm wieder mit den Knien zusammen.
3.	Wiederhole die Kreise in beide Richtungen. Konzentriere dich darauf, die Bewegung aus der Hüfte herauszuführen und nimm gern die Hände an die Hüften um deinen Oberkörper stabil zu halten.
""",
      "name": "Stand Hüft CARs"
    },
    {
      "image": "assets/gifs/0107_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Das schwingende Öffnen der Hüfte lockert deine Faszien im Oberkörper und den Armen. Die dynamische Bewegung bringt deine Brust, Schulter und Rückenmuskulatur wieder in Schwung und hält deine Faszien geschmeidig.

Ausführung:
1.	Stehe aufrecht und schwinge nun beide Arme seitlich nach außen, öffne dabei deinen Brustkorb.
2.	Dann schwing die Arme zusammen und tipp dir mit den Händen hinten an die Schultern.
3.	Achte darauf, dass du die Bewegung kontrolliert ausführst und sie fließend bleibt – du sollst deinen Brustkorb sanft und locker „öffnen“.
""",
      "name": "Schwingendes öffnen"
    },
    {
      "image": "assets/gifs/0109_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Durch das sanfte Schwingen entspannst du die Muskeln und Gelenke und verbesserst die Durchblutung, was den Körper dabei unterstützt, sich nach dem Training zu erholen. Spür wie sich die Entspannung durch deinen ganzen Körper ausbreitet und du das Training ausklingen lässt.

Ausführung:
1.	Stehe aufrecht und lasse deine Arme nun um deinen Körper rumschwingen. Deine Hände tippen an der Hüfte auf.
2.	Halte die Bewegungen locker und leicht, als würdest du dich sanft auspendeln. Dies gibt dem Körper die Chance, Spannung loszulassen und in die Entspannung zu finden.
""",
      "name": "Abschluss schwingen"
    },
    {
      "image": "assets/gifs/0110_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese Übung zielt auf die Brustwirbelsäule (BWS) ab, indem du die Rotation der Wirbelsäule im Stehen förderst. Sie verbessert die Beweglichkeit im oberen Rücken und hilft, die Schultern zu öffnen.
Eine steife BWS kann zu Überlastungen im unteren Rücken oder Nacken führen. Indem du die BWS regelmäßig mobilisierst, beugst du Schmerzen in diesen Bereichen vor und verbesserst gleichzeitig deine Haltung.

Ausführung:
1.	Stehe aufrecht und halte die Hände vor der Brust zusammen.
2.	Drehe den Oberkörper langsam zur einen Seite und öffne dabei einen Arm nach hinten, als würdest du den Brustkorb „öffnen“.
3.	Kehre zur Mitte zurück und wiederhole die Rotation zur anderen Seite. Die Bewegung sollte kontrolliert und in deinem Atemrhythmus erfolgen – dein Rücken wird es dir danken!
""",
      "name": "Stand BWS öffnen"
    },
    {
      "image": "assets/gifs/0114_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Verspannte Schultern? Nicht mehr nach dieser Übung! Indem du die Schultern und Arme „auswringst“, löst du Verspannungen und förderst die Beweglichkeit, was Nacken- und Schulterschmerzen vorbeugt.

Ausführung:
1.	Stelle dich aufrecht hin, die Arme seitlich ausgestreckt.
2.	Drehe die Arme, sodass die Handflächen erst nach oben und dann nach unten zeigen, wie bei einer Auswringbewegung. Schau dabei immer im Wechsel auf die jeweils nach oben zeigende Handfläche
3.	Achte darauf, dass die Bewegung langsam und kontrolliert bleibt. Spüre, wie sich deine Schultern und Oberarme entspannen und beweglicher werden.
""",
      "name": "Stand Arme auswringen"
    },
    {
      "image": "assets/gifs/0115_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese Übung mobilisiert sanft den Nacken, indem du halbe Kreise mit dem Kopf zeichnest. Sie hilft, Verspannungen im Nackenbereich zu lösen und fördert die Beweglichkeit der Halswirbelsäule. Eine flexible Halswirbelsäule reduziert das Risiko von Nacken- und Spannungskopfschmerzen.

Ausführung:
1.	Stehe aufrecht und bring dein Kinn runter zum Brustkorb. Dreh ein Ohr nun hoch zur Decke und spüre die Dehnung in der Nackenmuskulatur.
2.	Bewege den Kopf in einem halben Kreis sanft von einer Schulter zur anderen.
3.	Halte deinen Kiefer und Gesicht entspannt und führe die Bewegung kontrolliert durch, um den Nacken zu mobilisieren, ohne zu viel Druck auszuüben.
""",
      "name": "Stand Halbe Nackenkreise"
    },
    {
      "image": "assets/gifs/0120_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese dynamische Bewegung bringt deinen ganzen Oberkörper in Schwung. Besonders durch die Drehung der Brustwirbelsäule wirkst unser oft steifen Haltung entgegen und beugst Rückenschmerzen vor.

Ausführung:
1.	Stelle dich aufrecht hin, die Beine etwa hüftbreit auseinander.
2.	Schwing nun beide Arme gemeinsam von Seite zu Seite. Dein Blick folgt den Händen
3.	Deine Hüfte können locker mitschwingen.
""",
      "name": "Seitliche Schwünge"
    },
    {
      "image": "assets/gifs/0121_scene.gif",
      "text": """Wie beugt diese Übung Schmerzen vor: 
Diese Übung kombiniert eine Aufwärtsbewegung mit einem dynamischen Schwung der Arme. Sie fördert die Beweglichkeit der Schultern und Brustwirbelsäule. Besonders das Öffnen deiner Körperseite hilft dir Rückenschmerzen vorzubeugen.

Ausführung:
1.	Stelle dich aufrecht hin, die Füße schulterbreit auseinander.
2.	Schwinge nun deine Arme seitlich hoch zur Decke und schieb deine Hüfte raus, um deine ganze Körperseite zu öffnen.
3.	Schwing deine Arme so von Seite zu Seite. Dein ganzer Körper streckt sich bei jedem Schwung in die Länge – fühl dich dabei, als würdest du nach den Sternen greifen!
""",
      "name": "Schwünge zur Decke"
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
