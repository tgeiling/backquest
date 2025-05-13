import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'provider.dart';

class ExpandableTextBox extends StatelessWidget {
  final String text;
  final String exerciseName;
  final bool isExpanded;
  final VoidCallback onTap;

  const ExpandableTextBox({
    Key? key,
    required this.text,
    required this.exerciseName,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exerciseName,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({Key? key}) : super(key: key);

  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  late List<bool> _isExpanded;
  late List<Map<String, String>> exercises;

  @override
  void initState() {
    super.initState();
    exercises = [];
    _isExpanded = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the exercises list using localizations
    try {
      exercises = _buildExercisesList();
      // Ensure expansion state list matches exercises length
      if (_isExpanded.length != exercises.length) {
        _isExpanded = List<bool>.filled(exercises.length, false);
      }
    } catch (e) {
      // Handle error silently
      print("Error building exercises list: $e");
    }
  }

  List<Map<String, String>> _buildExercisesList() {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return [];
    }

    return [
      {
        "image": "assets/gifs/0001_scene.gif",
        "text": localizations.alternatingKneeHugsText,
        "name": localizations.alternatingKneeHugsName,
      },
      {
        "image": "assets/gifs/0002_scene.gif",
        "text": localizations.bwsRotationText,
        "name": localizations.bwsRotationName,
      },
      {
        "image": "assets/gifs/0004_scene.gif",
        "text": localizations.aufwachenderHundText,
        "name": localizations.aufwachenderHundName,
      },
      {
        "image": "assets/gifs/0005_scene.gif",
        "text": localizations.babyRollingText,
        "name": localizations.babyRollingName,
      },
      {
        "image": "assets/gifs/0010_scene.gif",
        "text": localizations.boxerCrunchText,
        "name": localizations.boxerCrunchName,
      },
      {
        "image": "assets/gifs/0013_scene.gif",
        "text": localizations.kindToCobraText,
        "name": localizations.kindToCobraName,
      },
      {
        "image": "assets/gifs/0015_scene.gif",
        "text": localizations.childPoseText,
        "name": localizations.childPoseName,
      },
      {
        "image": "assets/gifs/0016_scene.gif",
        "text": localizations.dynamicSingleArmChildPoseText,
        "name": localizations.dynamicSingleArmChildPoseName,
      },
      {
        "image": "assets/gifs/0019_scene.gif",
        "text": localizations.grosserGartenzwergText,
        "name": localizations.grosserGartenzwergName,
      },
      {
        "image": "assets/gifs/0020_scene.gif",
        "text": localizations.hipSwifelText,
        "name": localizations.hipSwifelName,
      },
      {
        "image": "assets/gifs/0021_scene.gif",
        "text": localizations.hipSwifelLehnenText,
        "name": localizations.hipSwifelLehnenName,
      },
      {
        "image": "assets/gifs/0022_scene.gif",
        "text": localizations.katzeKuhText,
        "name": localizations.katzeKuhName,
      },
      {
        "image": "assets/gifs/0028_scene.gif",
        "text": localizations.kleineCobraLiftsText,
        "name": localizations.kleineCobraLiftsName,
      },
      {
        "image": "assets/gifs/0029_scene.gif",
        "text": localizations.kneeHugText,
        "name": localizations.kneeHugName,
      },
      {
        "image": "assets/gifs/0031_scene.gif",
        "text": localizations.krabbelnMitTapText,
        "name": localizations.krabbelnMitTapName,
      },
      {
        "image": "assets/gifs/0032_scene.gif",
        "text": localizations.langsitzFusskreiseText,
        "name": localizations.langsitzFusskreiseName,
      },
      {
        "image": "assets/gifs/0033_scene.gif",
        "text": localizations.laufenderHundText,
        "name": localizations.laufenderHundName,
      },
      {
        "image": "assets/gifs/0035_scene.gif",
        "text": localizations.rlNackenrotationenText,
        "name": localizations.rlNackenrotationenName,
      },
      {
        "image": "assets/gifs/0037_scene.gif",
        "text": localizations.rolleZuSeitsitzText,
        "name": localizations.rolleZuSeitsitzName,
      },
      {
        "image": "assets/gifs/0038_scene.gif",
        "text": localizations.scapulaPushupText,
        "name": localizations.scapulaPushupName,
      },
      {
        "image": "assets/gifs/0039_scene.gif",
        "text": localizations.ruckendehnungSchneidersitzText,
        "name": localizations.ruckendehnungSchneidersitzName,
      },
      {
        "image": "assets/gifs/0041_scene.gif",
        "text": localizations.triangleStretchText,
        "name": localizations.triangleStretchName,
      },
      {
        "image": "assets/gifs/0043_scene.gif",
        "text": localizations.kaferAngewinkeltText,
        "name": localizations.kaferAngewinkeltName,
      },
      {
        "image": "assets/gifs/0044_scene.gif",
        "text": localizations.tuckedKrokodilatmungText,
        "name": localizations.tuckedKrokodilatmungName,
      },
      {
        "image": "assets/gifs/0045_scene.gif",
        "text": localizations.seitlageOberschenkeldehnungText,
        "name": localizations.seitlageOberschenkeldehnungName,
      },
      {
        "image": "assets/gifs/0047_scene.gif",
        "text": localizations.supineRotationsText,
        "name": localizations.supineRotationsName,
      },
      {
        "image": "assets/gifs/0050_scene.gif",
        "text": localizations.liegendeMeditationText,
        "name": localizations.liegendeMeditationName,
      },
      {
        "image": "assets/gifs/0058_scene.gif",
        "text": localizations.barenhockeText,
        "name": localizations.barenhockeName,
      },
      {
        "image": "assets/gifs/0063_scene.gif",
        "text": localizations.krabbePiriformisBeidseitigText,
        "name": localizations.krabbePiriformisBeidseitigName,
      },
      {
        "image": "assets/gifs/0064_scene.gif",
        "text": localizations.krabbeScapulaPushUpText,
        "name": localizations.krabbeScapulaPushUpName,
      },
      {
        "image": "assets/gifs/0067_scene.gif",
        "text": localizations.gluteBridgeText,
        "name": localizations.gluteBridgeName,
      },
      {
        "image": "assets/gifs/0068_scene.gif",
        "text": localizations.knienderSeitplankTapsText,
        "name": localizations.knienderSeitplankTapsName,
      },
      {
        "image": "assets/gifs/0084_scene.gif",
        "text": localizations.standSchulterkreiseText,
        "name": localizations.standSchulterkreiseName,
      },
      {
        "image": "assets/gifs/0085_scene.gif",
        "text": localizations.gegratschteVorbeugeSideToSideText,
        "name": localizations.gegratschteVorbeugeSideToSideName,
      },
      {
        "image": "assets/gifs/0086_scene.gif",
        "text": localizations.gegratschteVorbeugeMitRotationText,
        "name": localizations.gegratschteVorbeugeMitRotationName,
      },
      {
        "image": "assets/gifs/0087_scene.gif",
        "text": localizations.mountainPoseZuJeffersonCurlText,
        "name": localizations.mountainPoseZuJeffersonCurlName,
      },
      {
        "image": "assets/gifs/0088_scene.gif",
        "text": localizations.gegratschteVorbeugeRunterrollenText,
        "name": localizations.gegratschteVorbeugeRunterrollenName,
      },
      {
        "image": "assets/gifs/0089_scene.gif",
        "text": localizations.easyHockeZuVorbeugeText,
        "name": localizations.easyHockeZuVorbeugeName,
      },
      {
        "image": "assets/gifs/0090_scene.gif",
        "text": localizations.hockeReinkommenText,
        "name": localizations.hockeReinkommenName,
      },
      {
        "image": "assets/gifs/0091_scene.gif",
        "text": localizations.hockeRotationZuVorbeugeText,
        "name": localizations.hockeRotationZuVorbeugeName,
      },
      {
        "image": "assets/gifs/0092_scene.gif",
        "text": localizations.kniebeugeSchwingenText,
        "name": localizations.kniebeugeSchwingenName,
      },
      {
        "image": "assets/gifs/0100_scene.gif",
        "text": localizations.hufteLockernText,
        "name": localizations.hufteLockernName,
      },
      {
        "image": "assets/gifs/0101_scene.gif",
        "text": localizations.standHuftCARsText,
        "name": localizations.standHuftCARsName,
      },
      {
        "image": "assets/gifs/0107_scene.gif",
        "text": localizations.schwingendesOffnenText,
        "name": localizations.schwingendesOffnenName,
      },
      {
        "image": "assets/gifs/0109_scene.gif",
        "text": localizations.abschlussSchwingenText,
        "name": localizations.abschlussSchwingenName,
      },
      {
        "image": "assets/gifs/0110_scene.gif",
        "text": localizations.standBwsOffnenText,
        "name": localizations.standBwsOffnenName,
      },
      {
        "image": "assets/gifs/0114_scene.gif",
        "text": localizations.standArmeAuswringenText,
        "name": localizations.standArmeAuswringenName,
      },
      {
        "image": "assets/gifs/0115_scene.gif",
        "text": localizations.standHalbeNackenkreiseText,
        "name": localizations.standHalbeNackenkreiseName,
      },
      {
        "image": "assets/gifs/0120_scene.gif",
        "text": localizations.seitlicheSchwungeText,
        "name": localizations.seitlicheSchwungeName,
      },
      {
        "image": "assets/gifs/0121_scene.gif",
        "text": localizations.schwungeZurDeckeText,
        "name": localizations.schwungeZurDeckeName,
      },
    ];
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
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image fails to load
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              AppLocalizations.of(context)?.exercisesPageTitle ??
                  'Übungen aufrufen',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child:
                exercises.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                exercises[index]["image"]!,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback when image fails to load
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade800,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            ExpandableTextBox(
                              text: exercises[index]["text"]!,
                              exerciseName: exercises[index]["name"]!,
                              isExpanded: _isExpanded[index],
                              onTap: () {
                                setState(() {
                                  _isExpanded[index] = !_isExpanded[index];
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }
}
