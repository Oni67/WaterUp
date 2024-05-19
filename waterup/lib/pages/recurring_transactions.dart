import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waterup/data/fake_data.dart';
import 'package:waterup/backend/transacoesRecorrentes.dart';
import 'package:waterup/pages/start.dart';

class RecurrentTransactionsPage extends StatelessWidget {
  const RecurrentTransactionsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: recurring_Transactions(),
    );
  }
}

class recurring_Transactions extends StatefulWidget {
  const recurring_Transactions({Key? key});

  @override
  recurring_TransactionsState createState() => recurring_TransactionsState();
}

class recurring_TransactionsState extends State<recurring_Transactions> {
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
    List<DocumentSnapshot> fetchedData = await getRecurrentTransactionsList();
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
      names.add(document['Descrição']);
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
            // Use Expanded to allow ListView.builder to occupy remaining space
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (_, int index) {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: ListTile(
                        onTap: () => _toggle(index),
                        title: Text(names[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // ignore: avoid_print
                                print(
                                    "Do action to remove recurrent transaction from database");
                                deleteReccurrentTransaction(entries[index].id);
                                _loadData();
                              },
                              icon: const Icon(Icons.delete_forever),
                              label: const Text("Delete"),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red.shade400),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to BudgetScreen with the selected budget data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TransacoesRecorrentesScreen(
                                      recurrentTransactionData: entries[index]
                                          .data() as Map<String, dynamic>,
                                      control: true,
                                      controlDocId: entries[index]
                                          .id, // Pass the budget data to BudgetScreen
                                      budgets: [],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit"),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green.shade400),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
