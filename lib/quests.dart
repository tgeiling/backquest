import 'package:flutter/material.dart';
import 'data_provider.dart';
import 'package:provider/provider.dart';

class Questbar extends StatefulWidget {
  const Questbar({super.key});

  @override
  State<Questbar> createState() => _QuestbarState();
}

class _QuestbarState extends State<Questbar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 200 * 20,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Center(
          child: Text('30/70'),
        ),
      ],
    );
  }
}

class Questview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      child: ProgressBar(),
    );
  }
}

class ProgressBar extends StatefulWidget {
  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  double _progressValue = 0.0;

  void _updateProgress() {
    setState(() {
      if (_progressValue < 10.0) {
        _progressValue += 1.0;
      } else {
        _progressValue = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Progress: ${_progressValue.toInt()} / 10',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 16),
        LinearProgressIndicator(
          value: _progressValue /
              10.0, // Scale the progress to a value between 0 and 1
          minHeight: 20,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _updateProgress,
          child: Text('Update Progress'),
        ),
      ],
    );
  }
}
