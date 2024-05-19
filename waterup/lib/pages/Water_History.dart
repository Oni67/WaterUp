import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waterup/backend/AddWaterPage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterHistoryPage extends StatelessWidget {
  const WaterHistoryPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WaterHistory(),
    );
  }
}

class WaterHistory extends StatefulWidget {
  const WaterHistory({Key? key});

  @override
  WaterHistoryState createState() => WaterHistoryState();
}

class BudgetList {
  List<String> waterHistory;

  BudgetList() : waterHistory = [];

  BudgetList.withInitialValues(List<String> initialValues)
      : waterHistory = initialValues;

  String? get first => null;
}

class WaterHistoryState extends State<WaterHistory> {
  late List<bool> _selected;
  late DateTime _currentWeek;
  final int listLength = BudgetList().waterHistory.length;

  @override
  void initState() {
    super.initState();
    _currentWeek = DateTime.now();
    initializeSelection();
  }

  void initializeSelection() {
    _selected = List<bool>.generate(listLength, (_) => false);
  }

  void _previousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
    });
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
        children: [
          Expanded(
            child: ListBuilder(
              selectedList: _selected,
              onSelectionChange: (bool x) {
                setState(() {});
              },
              buildWeekNavigation: _buildWeekNavigation(),
              buildBarChart: _buildBarChart(),
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
    return FutureBuilder(
      future: _fetchWeeklyData(),
      builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

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
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 5000, // Adjust this value to match the maximum expected value
                  color: Colors.grey[300]!,
                ),
              ),
            ],
          );
        }).toList();

        return SizedBox(
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
                      final days = [
                        'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                      ];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(days[value.toInt()]),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
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
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, double>> _fetchWeeklyData() async {
    final startOfWeek = _currentWeek.subtract(Duration(days: _currentWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final querySnapshot = await FirebaseFirestore.instance
        .collection('WaterHistory')
        .where('Data do registo', isGreaterThanOrEqualTo: DateFormat('yyyy/MM/dd').format(startOfWeek))
        .where('Data do registo', isLessThanOrEqualTo: DateFormat('yyyy/MM/dd').format(endOfWeek))
        .get();

    // Initialize all days with 0.0
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
      final quantity = (doc['Quantidade de água (mL)'] as num).toDouble();

      if (data.containsKey(day)) {
        data[day] = data[day]! + quantity;
      }
    }

    return data;
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
}

class ListBuilder extends StatefulWidget {
  const ListBuilder({
    Key? key,
    required this.selectedList,
    required this.onSelectionChange,
    required this.buildWeekNavigation,
    required this.buildBarChart,
  }) : super(key: key);

  final List<bool> selectedList;
  final ValueChanged<bool>? onSelectionChange;
  final Widget buildWeekNavigation;
  final Widget buildBarChart;

  @override
  State<ListBuilder> createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
  List<DocumentSnapshot> entries = [];
  List<String> names = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<DocumentSnapshot> fetchedData = await getWaterHistoryList();
    setState(() {
      entries = fetchedData;
    });
  }

  void _toggle(int index) {
    setState(() {
      widget.selectedList[index] = !widget.selectedList[index];
      widget.onSelectionChange!(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    names.clear();
    for (DocumentSnapshot document in entries) {
      String temp = document['Data do registo'] +
          ": " +
          document['Quantidade de água (mL)'].toString() +
          "mL";
      names.add(temp);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(236, 201, 198, 198),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WaterUp',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          widget.buildWeekNavigation,
          widget.buildBarChart,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (_, int index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                      onTap: () => _toggle(index),
                      title: Text(
                        names[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 10,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteTransaction(entries[index].id);
                              _loadData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddWaterScreen(
                                    transactionData: entries[index].data()
                                        as Map<String, dynamic>,
                                    control: true,
                                    controlDocId: entries[index].id,
                                    budgets: [],
                                  ),
                                ),
                              ).then((_) => _loadData());
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
