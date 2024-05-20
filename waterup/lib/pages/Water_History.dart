import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waterup/backend/AddWaterPage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterHistoryPage extends StatelessWidget {
  const WaterHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WaterHistory(),
    );
  }
}

class WaterHistory extends StatefulWidget {
  const WaterHistory({Key? key}) : super(key: key);

  @override
  WaterHistoryState createState() => WaterHistoryState();
}

class WaterHistoryState extends State<WaterHistory> {
  late Future<Map<String, double>> _weeklyDataFuture;
  late Future<List<DocumentSnapshot>> _listDataFuture;
  late DateTime _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentWeek = DateTime.now();
    _weeklyDataFuture = _fetchWeeklyData();
    _listDataFuture = _fetchListData();
  }

  void _previousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
      _weeklyDataFuture = _fetchWeeklyData();
      _listDataFuture = _fetchListData();
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
      _weeklyDataFuture = _fetchWeeklyData();
      _listDataFuture = _fetchListData();
    });
  }

  void _editEntry(DocumentSnapshot entry) async {
    final defaultData = {
      'Data do registo': entry['Data do registo'],
      'Quantidade de água (mL)': entry['Quantidade de água (mL)'],
    };
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWaterScreen(
          transactionData: defaultData,
          control: true,
          controlDocId: entry.id,
          budgets: [],
        ),
      ),
    );
    setState(() {
      _weeklyDataFuture = _fetchWeeklyData();
      _listDataFuture = _fetchListData();
    });
  }

  void _removeEntry(DocumentSnapshot entry) async {
    await FirebaseFirestore.instance
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('2024')
        .doc(entry.id)
        .delete();
    setState(() {
      _weeklyDataFuture = _fetchWeeklyData();
      _listDataFuture = _fetchListData();
    });
  }

  void _showDayData(String day, double amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Water Intake on $day'),
          content: Text('You drank ${amount.toStringAsFixed(2)} mL of water.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(236, 201, 198, 198),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Map<String, dynamic> defaultData = {
            'Data do registo': '',
            'Quantidade de água (mL)': '',
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWaterScreen(
                transactionData: defaultData,
                control: false,
                controlDocId: '',
                budgets: [],
              ),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 0, 174, 255),
        elevation: 2.0,
        child: const Icon(Icons.add, size: 35, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The missing banner
          Container(
            color: Colors.blue, // Set the color of the banner to blue
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WaterUp',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          // Rest of the content
          _buildWeekNavigation(),
          _buildBarChart(),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _listDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No data available for this week.');
                } else {
                  return _buildList(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousWeek,
        ),
        Text(
          'Week of ${DateFormat.yMMMd().format(_currentWeek)}',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _nextWeek,
        ),
      ],
    );
  }

  Widget _buildBarChart() {
  return FutureBuilder<Map<String, double>>(
    future: _weeklyDataFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No data available for this week.');
      } else {
        final data = snapshot.data!;
        final barGroups = data.entries.map((entry) {
          int dayIndex = _getDayIndex(entry.key);
          return BarChartGroupData(
            x: dayIndex,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
                width: 22,
                borderRadius: BorderRadius.circular(0),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 3000, // Adjusting the maximum y-value
                  color: Colors.grey[300]!,
                ),
              ),
            ],
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(days[value.toInt()]),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 200 == 0) { // Adjusting the interval for y-axis labels
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text('${value.toInt()}', style: const TextStyle(fontSize: 12)),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                gridData: FlGridData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 0,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (event is FlTapUpEvent &&
                        barTouchResponse != null &&
                        barTouchResponse.spot != null) {
                      final tappedGroup = barTouchResponse.spot!.touchedBarGroup;
                      final day = _getDayName(tappedGroup.x.toInt());
                      final amount = tappedGroup.barRods[0].toY;
                      _showDayData(day, amount);
                    }
                  },
                  touchExtraThreshold: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),
        );
      }
    },
  );
}

  Future<Map<String, double>> _fetchWeeklyData() async {
    final startOfWeek = _currentWeek.subtract(Duration(days: _currentWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final querySnapshot = await FirebaseFirestore.instance
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('2024')
        .where('Data do registo', isGreaterThanOrEqualTo: DateFormat('yyyy/MM/dd').format(startOfWeek))
        .where('Data do registo', isLessThanOrEqualTo: DateFormat('yyyy/MM/dd').format(endOfWeek))
        .get();

    final data = {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    };

    for (var doc in querySnapshot.docs) {
      final dateString = doc['Data do registo'];
      final date = DateFormat('yyyy/MM/dd').parse(dateString);
      final day = DateFormat('EEE').format(date);
      final quantityString = doc['Quantidade de água (mL)'];
      final quantity = double.tryParse(quantityString) ?? 0.0;

      if (data.containsKey(day)) {
        data[day] = data[day]! + quantity;
      }
    }

    return data;
  }

  Future<List<DocumentSnapshot>> _fetchListData() async {
    final startOfWeek = _currentWeek.subtract(Duration(days: _currentWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final querySnapshot = await FirebaseFirestore.instance
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('2024')
        .where('Data do registo', isGreaterThanOrEqualTo: DateFormat('yyyy/MM/dd').format(startOfWeek))
        .where('Data do registo', isLessThanOrEqualTo: DateFormat('yyyy/MM/dd').format(endOfWeek))
        .get();
    return querySnapshot.docs;
  }

  Widget _buildList(List<DocumentSnapshot> entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        DocumentSnapshot entry = entries[index];
        return Card(
          color: Colors.white,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.opacity,
              color: Color.fromARGB(255, 0, 174, 255),
            ),
            title: Text(entry['Data do registo']),
            subtitle: Text('${entry['Quantidade de água (mL)']} mL'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editEntry(entry),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeEntry(entry),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getDayIndex(String day) {
    switch (day) {
      case 'Mon':
        return 0;
      case 'Tue':
        return 1;
      case 'Wed':
        return 2;
      case 'Thu':
        return 3;
      case 'Fri':
        return 4;
      case 'Sat':
        return 5;
      case 'Sun':
        return 6;
      default:
        return 0;
    }
  }

  String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return '';
    }
  }
}
