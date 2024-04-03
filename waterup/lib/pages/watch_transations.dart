import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waterup/data/fake_data.dart';
import 'package:waterup/backend/transacoes.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Transactions(),
    );
  }
}

class Transactions extends StatefulWidget {
  const Transactions({Key? key});

  @override
  transactionsState createState() => transactionsState();
}

class transactionsState extends State<Transactions> {
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
      appBar: AppBar(
        title: const Text('Transações'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Provide default data or an empty map
          Map<String, dynamic> defaultData = {
            'Data da transação': '',
            'Descrição': '',
            'Valor monetário': '',
            'tipo': '',
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransacoesScreen(
                transactionData: defaultData,
                control: false,
                controlDocId: '',
                budgets:[],
              ),
            ),
          );
        },
        backgroundColor: Colors.lightBlue.shade200,
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
    List<DocumentSnapshot> fetchedData = await getTransactionsList();
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

    return ListView.builder(
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
                        print("Do action to remove recurrent transaction from database");
                        deleteTransaction(entries[index].id);
                        _loadData();
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Delete"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.red.shade400),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to BudgetScreen with the selected budget data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransacoesScreen(
                              transactionData: entries[index].data() as Map<String,
                                  dynamic>,
                                  control: true,
                                  controlDocId: entries[index].id,
                                  budgets: [], // Pass the budget data to BudgetScreen
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green.shade400),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
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
    );
  }
}
