import 'package:waterup/data/fake_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineGraph extends StatelessWidget {
  final List<FakeData> points;

  const LineGraph(this.points, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(LineChartData(lineBarsData: [
        LineChartBarData(
            spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
            isCurved: false,
            aboveBarData: null,
            dotData: FlDotData(show: true)),
      ])),
    );
  }
}
