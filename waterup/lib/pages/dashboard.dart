import 'package:waterup/components/pie_graph.dart';
import 'package:flutter/material.dart';
import 'package:waterup/pages/start.dart';
import 'package:waterup/backend/orçamentos.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key});

  @override
  Widget build(BuildContext context) {
    return Graph();
  }
}

class Graph extends StatefulWidget {
  const Graph({Key? key});

  @override
  GraphComponent createState() => GraphComponent();
}

class GraphComponent extends State<Graph> {
  late String selectedOption = '';
  List<String> listContents = [];
  List<double> percentages = [0, 100];
  double water = 0;
  Map<String, int> temp = {};
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 30),
        child: Container(
          color: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
              ),
              const Text(
                'WaterUp',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
      body: _dataLoaded
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Tip of the Day:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        ' "Drinking water is not only good for your health, it can also help you regulate the temperature of your body" ',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                  PieGraph(percentages),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Daily Goal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '$water L / 2 L',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'You’re almost at your daily goal! Keep it up!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> loadData() async {
    await Future.wait([getPercentage(), getTodayWater()]);
    setState(() {
      _dataLoaded = true;
    });
  }

  Future<void> getPercentage() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy/MM/dd').format(now);
    List<double> temp = await calculatePercentage(formattedDate);
    setState(() {
      percentages = temp;
    });
  }

  Future<void> getTodayWater() async {
    int temp = 0;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy/MM/dd').format(now);
    Map<String, int> current = await getWaterHistoryByDate(formattedDate);
    for (int i in current.values) {
      temp += i;
    }
    setState(() {
      water = temp / 1000;
    });
  }
}
