import 'package:flutter/material.dart';

class MotivationalMessage extends StatelessWidget {
  final List<double> percentages;

  MotivationalMessage({required this.percentages});

  String getMotivationalMessage(double percentage) {
    if (percentage == 0) {
      return "We all have to start somewhere!";
    } else if (percentage < 30) {
      return "You're off to a great start!";
    } else if (percentage < 70) {
      return "Keep up the good work!";
    } else if (percentage < 100) {
      return "You're almost there! Keep pushing!";
    } else {
      return "You've reached your goal! Congratulations!";
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentPercentage = percentages.isNotEmpty ? percentages[0] : 0.0;
    String motivationalMessage = getMotivationalMessage(currentPercentage);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          motivationalMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
