import 'package:waterup/data/fake_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final List<FakeData> data;
  const BarGraph(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 2,
        child: BarChart(
          BarChartData(
              barGroups: data
                  .map((e) => BarChartGroupData(
                          x: (e.x).toInt(),
                          barsSpace: 1,
                          barRods: [
                            BarChartRodData(toY: e.y, color: Colors.black)
                          ]))
                  .toList()),
        ));
  }
}
