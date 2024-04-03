import 'package:waterup/components/dropdown_list.dart';
import 'package:waterup/components/pie_graph.dart';
import 'package:flutter/material.dart';
import 'package:waterup/pages/start.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waterup/backend/orçamentos.dart';

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
  List<double> percentages = [100];
  Map<String, int> temp = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
      ),
      body: Column(
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
          FutureBuilder(
            future: fetchBudgetsFromFirebase(),
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return Column(
                  children: [
                    DropdowButtonComponent(
                      snapshot.data ?? [],
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                        getPercentage(selectedOption);
                        loadTransactions(selectedOption);
                      },
                    ),
                    Text("$selectedOption", style: TextStyle(fontSize: 24)),
                    PieGraph(percentages),
                  ],
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder(
              future: Future.value(null),
              builder: (context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: listContents.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ListTile(
                          title: Text(
                            '${percentages[index]}% ${listContents[index]}',
                            textScaler: TextScaler.linear(0.90),
                          ),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPercentage(String id) async {
    List<double> temp = await calculatePercentage(id);
    setState(() {
      percentages = temp;
    });
  }

  Future<void> loadTransactions(String id) async {
    Map<String, int> trans = await getTransactionsByBudget(id);
    List<String> updatedListContents = [];

    trans.forEach((key, value) {
      updatedListContents.add('$key: $value€');
    });

    setState(() {
      temp = trans;
      listContents = updatedListContents;
    });
  }

  Future<List<String>> fetchBudgetsFromFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Replace 'yourCollection' with the actual name of your Firebase collection
    DocumentReference document = firestore
        .collection('budget')
        .doc(FirebaseAuth.instance.currentUser?.email);

    QuerySnapshot querySnapshot = await document.collection('budgets').get();

    List<String> budgetList = [];
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Assuming you have a field named 'budgetName' in your documents
      String budgetName = documentSnapshot['Nome'];
      budgetList.add(budgetName);
    }
    return budgetList;
  }
}
