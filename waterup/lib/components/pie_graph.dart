import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PieGraph extends StatelessWidget {
  final List<double> data;
  final List<Color> predefinedColors = [
    const Color.fromARGB(255, 2, 132, 238),
  ];

  final Color lastElementColor = Color.fromARGB(255, 128, 127, 119); // Set the color for the last element
  final Random random = Random();

  PieGraph(this.data, {Key? key}) : super(key: key);

  Color getColorForIndex(int index) {
    if (index == data.length - 1) {
      return lastElementColor; // Use the last element color for the last index
    } else {
      return predefinedColors[index % predefinedColors.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: PieChart(PieChartData(
        borderData: FlBorderData(
          show: false,
        ),
        sections: data
            .asMap()
            .entries
            .map(
              (entry) => PieChartSectionData(
                color: getColorForIndex(entry.key),
                value: entry.value,
                title: '${entry.value}%', // Convert the double value to a string
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff),
                ),
              ),
            )
            .toList(),
      )),
    );
  }
}
