import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waterup/data/fake_data.dart';
import 'package:waterup/backend/AddWaterPage.dart';

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

class WaterHistoryState extends State<WaterHistory> {
  late List<bool> _selected;
  final int listLength = BudgetList().budgetList.length;

  @override
  void initState() {
    super.initState();
    initializeSelection();
  }

  void initializeSelection() {
    _selected = List<bool>.generate(listLength, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Provide default data or an empty map
          Map<String, dynamic> defaultData = {
            'Data do registo': '',
            'Quantidade de Água (mL)': '',
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
      body: ListBuilder(
        selectedList: _selected,
        onSelectionChange: (bool x) {
          setState(() {});
        },
      ),
    );
  }
}

class ListBuilder extends StatefulWidget {
  const ListBuilder({
    Key? key,
    required this.selectedList,
    required this.onSelectionChange,
  }) : super(key: key);

  final List<bool> selectedList;
  final ValueChanged<bool>? onSelectionChange;

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
    for (DocumentSnapshot document in entries) {
      String temp = document['Data do registo'] + ": " + document['Quantidade de água (mL)'] + "mL";
      names.add(temp);
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue, // Set the color of the banner to blue
            padding: EdgeInsets.symmetric(vertical: 10),
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
                        spacing: 10, // Space between buttons
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
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
                              );
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
