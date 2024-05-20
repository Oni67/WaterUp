// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waterup/main.dart';

class AddWaterScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;
  final bool control;
  final String controlDocId;
  List<String> budgets;

  AddWaterScreen({
    Key? key,
    this.transactionData,
    required this.control,
    required this.controlDocId,
    required this.budgets,
  }) : super(key: key);

  @override
  _AddWaterScreenState createState() => _AddWaterScreenState();
}

class _AddWaterScreenState extends State<AddWaterScreen> {
  String errorValueMessage = '';
  String selectedWaterAmount = '';
  bool update = false;
  bool isCustomSelected = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      List<String> fetchedBudgets = await fetchBudgetsFromFirebase();

      setState(() {
        widget.budgets = fetchedBudgets;
        _selectedDate = DateTime.now();
      });

      if (widget.transactionData != null) {
        selectedWaterAmount = widget.transactionData!['Quantidade de água (mL)'];
        _selectedDate = DateFormat('yyyy/MM/dd').parse(widget.transactionData!['Data do registo']);
      }

      update = widget.control;
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> registerTransaction(String value) async {
    try {
      if (value.isEmpty || _selectedDate == null) {
        throw FirebaseAuthException(code: 'Invalid-Value');
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String selectedDate = DateFormat('yyyy/MM/dd').format(_selectedDate!);

      DocumentReference transactions = firestore
          .collection('WaterHistory')
          .doc(FirebaseAuth.instance.currentUser?.email);

      await transactions.collection('2024').doc().set({
        'Data do registo': selectedDate,
        'Quantidade de água (mL)': value,
      });

      await _showSuccessDialog();
      Navigator.pop(context, true); // Pop with a result to indicate success
    } catch (e) {
      errorValueMessage = '';
      if (e is FirebaseAuthException && e.code == 'Invalid-Value') {
        errorValueMessage = 'Invalid Value or Date';
      }
      log('$e');
      _setValueError(errorValueMessage);
    }
  }

  Future<void> updateTransaction(String value) async {
    try {
      if (value.isEmpty || _selectedDate == null) {
        throw FirebaseAuthException(code: 'Invalid-Value');
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String selectedDate = DateFormat('yyyy/MM/dd').format(_selectedDate!);

      DocumentReference transactions = firestore
          .collection('WaterHistory')
          .doc(FirebaseAuth.instance.currentUser?.email);

      await transactions.collection('2024').doc(widget.controlDocId).update({
        'Data do registo': selectedDate,
        'Quantidade de água (mL)': value,
      });

      await _showSuccessDialog();
      Navigator.pop(context, true); // Pop with a result to indicate success
    } catch (e) {
      errorValueMessage = '';
      if (e is FirebaseAuthException && e.code == 'Invalid-Value') {
        errorValueMessage = 'Invalid Value or Date';
      }
      log('$e');
      _setValueError(errorValueMessage);
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Water added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const NavigationExample(initialPageIndex: 1)),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _setValueError(String error) {
    setState(() {
      errorValueMessage = error;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor:Color.fromARGB(236, 201, 198, 198), // Set a slightly darker background color
    appBar: AppBar(
      title: Text('Add Water'), // Customize app bar title
      backgroundColor: Colors.blue, // Customize app bar background color
    ),
    body: Center( // Center the column both horizontally and vertically
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically
          children: [
            if (errorValueMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  errorValueMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.center, // Align buttons to the center
              spacing: 8.0,
              runSpacing: 16.0, // Set vertical spacing between rows
              children: [
                _buildWaterButton('100'),
                _buildWaterButton('150'),
                _buildWaterButton('200'),
                _buildWaterButton('333'),
                _buildWaterButton('500'),
                _buildWaterButton('1000'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? customAmount = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController customController = TextEditingController();
                    return AlertDialog(
                      title: Text('Enter custom amount'),
                      content: TextField(
                        controller: customController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Enter amount in mL"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, customController.text);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                if (customAmount != null && customAmount.isNotEmpty) {
                  setState(() {
                    selectedWaterAmount = customAmount;
                    isCustomSelected = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCustomSelected ? Colors.grey : null,
              ),
              child: Text('Custom'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${DateFormat('yyyy/MM/dd').format(_selectedDate!)}',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (update == false) {
                  registerTransaction(selectedWaterAmount);
                } else {
                  updateTransaction(selectedWaterAmount);
                }
              },
              child: Text('Save Water Record'),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildWaterButton(String amount) {
  return SizedBox(
    width: MediaQuery.of(context).size.width / 3 - 16.0, // Set button width to fit 3 buttons per line
    child: ElevatedButton(
      onPressed: () {
        setState(() {
          selectedWaterAmount = amount;
          isCustomSelected = false;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: selectedWaterAmount == amount && !isCustomSelected ? Colors.grey : null,
      ),
      child: Text('$amount mL'),
    ),
  );
}





  Future<List<String>> fetchBudgetsFromFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference document = firestore
        .collection('budget')
        .doc(FirebaseAuth.instance.currentUser?.email);

    QuerySnapshot querySnapshot = await document.collection('budgets').get();

    List<String> budgetList = [];
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      String budgetName = documentSnapshot.id;
      budgetList.add(budgetName);
    }

    return budgetList;
  }
}

