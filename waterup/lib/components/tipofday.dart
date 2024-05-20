import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WaterIntakeTip extends StatelessWidget {

  WaterIntakeTip();

  String getTipOfTheDay(String day) {
    switch (day) {
      case 'Sunday':
        return "Remember to drink water before and after exercise to stay hydrated.";
      case 'Monday':
        return "Replace sugary drinks with water to cut down on empty calories.";
      case 'Tuesday':
        return "Keep a reusable water bottle with you throughout the day for easy access.";
      case 'Wednesday':
        return "Try adding slices of lemon, cucumber, or mint to your water for flavor without added sugar.";
      case 'Thursday':
        return "Set reminders on your phone or use an app to track your water intake throughout the day.";
      case 'Friday':
        return "Drink a glass of water as soon as you wake up to kickstart your metabolism.";
      case 'Saturday':
        return "Listen to your body's cues – drink water when you feel thirsty.";
      default:
        return "Remember to stay hydrated and drink plenty of water every day!";
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String dateFormat = DateFormat('EEEE').format(date);
    String tipOfTheDay = getTipOfTheDay(dateFormat);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Tip of the Day:\n$tipOfTheDay',
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
