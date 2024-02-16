import 'package:flutter/material.dart';

class StatsWidget extends StatefulWidget {
  @override
  _StatsWidgetState createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  // Define your progress percentages here
  final List<double> progressPercentages = [0.5, 0.4, 0.3, 0.2, 0.1, 0.05];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: progressPercentages.length,
      itemBuilder: (BuildContext context, int index) {
        return CustomProgressIndicator(
          progressPercentage: progressPercentages[index],
          iconData: Icons.ac_unit, // Replace with your own icons
        );
      },
    );
  }
}

class CustomProgressIndicator extends StatelessWidget {
  final double progressPercentage;
  final IconData iconData;

  const CustomProgressIndicator({
    Key? key,
    required this.progressPercentage,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey.shade300,
            color: Theme.of(context).primaryColor,
            strokeWidth: 6,
          ),
        ),
        Icon(
          iconData,
          size: 50,
        ),
      ],
    );
  }
}
