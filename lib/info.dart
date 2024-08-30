import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            MaterialPageRoute(builder: (context) => TrainingDataPage()),
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

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({Key? key}) : super(key: key);

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
            title: const Text('Übungen aufrufen',
                style: TextStyle(color: Colors.white)),
          ),
          body: const Center(
            child: Text(
              'This is the Übungen aufrufen page',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class TrainingDataPage extends StatelessWidget {
  const TrainingDataPage({Key? key}) : super(key: key);

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
            title: const Text('Trainings Daten',
                style: TextStyle(color: Colors.white)),
          ),
          body: const Center(
            child: Text(
              'This is the Trainings Daten page',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
