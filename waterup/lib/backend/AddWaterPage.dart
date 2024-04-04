// ignore_for_file: must_be_immutable, avoid_print, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'checks.dart';
import 'package:intl/intl.dart';

Future<List<DocumentSnapshot>> getWaterHistoryList() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    CollectionReference document = firestore
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('2024').doc('04').collection('10');

    QuerySnapshot querySnapshot =
        await document.get(); // find a way to get this

    return querySnapshot.docs;

    /* Access document fields
      for (DocumentSnapshot document in documents) {
        log('Data Limite: ${document['Data Limite']}, Percentagem Limite: ${document['Percentagem Limite']}, Orçamento Máximo: ${document['Orçamento Máximo']}, Nome: ${document['Nome']}');
      }*/
  } catch (e) {
    print('Error getting budget list: $e');
    return [];
  }
}

Future<void> deleteTransaction(String documentId) async {
  try {
    // Reference to the collection
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference document = firestore
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email);

    // Delete the document
    await document.collection('2024').doc(documentId).delete();

    log('Document deleted successfully!');
  } catch (e) {
    log('Error deleting document: $e');
  }
}

class AddWaterScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;
  final bool control;
  final String controlDocId;
  List<String> budgets;
  AddWaterScreen(
      {Key? key,
      this.transactionData,
      required this.control,
      required this.controlDocId,
      required this.budgets})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddWaterScreenState createState() => _AddWaterScreenState();
}

class _AddWaterScreenState extends State<AddWaterScreen> {
  String errorDateMessage = '';
  String errorDescriptionMessage = '';
  String errorValueMessage = '';
  String errorTypeMessage = '';
  String? selectedBudget;

  final TextEditingController _checkDateController = TextEditingController();
  final TextEditingController _monetaryValueController =
      TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  bool update = false;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      // Fetch budgets from Firebase
      List<String> fetchedBudgets = await fetchBudgetsFromFirebase();

      // Update the state with the fetched budgets
      setState(() {
        widget.budgets = fetchedBudgets;
      });

      // Pre-fill the text fields with the existing budget data
      _checkDateController.text = widget.transactionData?['Data do registo'];
      _monetaryValueController.text = widget.transactionData?['Quantidade de água (mL)'];

      update = widget.control;
    } catch (e) {
      // Handle errors if needed
      print('Error initializing data: $e');
    }
  }

  Future<void> registerTransaction(String date,
      String value, String category) async {
    try {
      _performTransactionCheck(date, value);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection and add a document
      DocumentReference transactions = firestore
          .collection('WaterHistory')
          .doc(FirebaseAuth.instance.currentUser?.email);
      // Determine the category based on user input
      String transactionCategory = category.isEmpty ? 'No category' : category;
      // Create a reference to the category
      //await transactions.collection('category').doc(transactionCategory).collection('docs').add({'Data da transação': checkDate(date), 'Descrição': description, 'Valor monetário': value});
      await transactions.collection(date).doc().set({
        'Data do registo': checkDate(date),
        'Quantidade de água (mL)': value,
      });
      await _showSuccessDialog();
    } catch (e) {
      errorDateMessage = '';
      errorDescriptionMessage = '';
      errorValueMessage = '';
      errorTypeMessage = '';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'Invalid-Date-Format':
            errorDateMessage =
                'Invalid date format or empty, it should be DD/MM/YYYY or YYYY/MM/DD';
            break;
          case 'Invalid-Date-Time':
            errorDateMessage = 'Date cannot be in the past';
            break;
          case 'Blank-Description':
            errorDescriptionMessage = 'Description cannot be blank';
            break;
          case 'Invalid-Value':
            errorValueMessage = 'Invalid Value';
            break;
          case 'Blank-Type':
            errorTypeMessage = 'Type cannot be blank';
            break;
        }
      }
      log('$e');

      _setDateError(errorDateMessage);
      _setDescriptionError(errorDescriptionMessage);
      _setValueError(errorValueMessage);
      _setTypeError(errorTypeMessage);
    }
  }

  Future<void> updateTransaction(String date, String value, String category) async {
    try {
      log('${FirebaseAuth.instance.currentUser}');
      _performTransactionCheck(date, value);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection and add a document
      DocumentReference transactions = firestore
          .collection('WaterHistory')
          .doc(FirebaseAuth.instance.currentUser?.email);
      // Determine the category based on user input
      String transactionCategory = category.isEmpty ? 'No category' : category;
      // Create a reference to the category
      //await transactions.collection('category').doc(transactionCategory).collection('docs').add({'Data da transação': checkDate(date), 'Descrição': description, 'Valor monetário': value});
      await transactions
          .collection('2024')
          .doc(widget.controlDocId)
          .update({
        'Data do registo': checkDate(date),
        'Quantidade de água (mL)': value,
      });
      await _showSuccessDialog();
    } catch (e) {
      errorDateMessage = '';
      errorDescriptionMessage = '';
      errorValueMessage = '';
      errorTypeMessage = '';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'Invalid-Date-Format':
            errorDateMessage =
                'Invalid date format or empty, it should be DD/MM/YYYY or YYYY/MM/DD';
            break;
          case 'Blank-Description':
            errorDescriptionMessage = 'Description cannot be blank';
            break;
          case 'Invalid-Value':
            errorValueMessage = 'Invalid Value';
            break;
          case 'Blank-Type':
            errorTypeMessage = 'Type cannot be blank';
            break;
        }
      }
      log('$e');

      _setDateError(errorDateMessage);
      _setDescriptionError(errorDescriptionMessage);
      _setValueError(errorValueMessage);
      _setTypeError(errorTypeMessage);
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
                Navigator.pop(context); // Close the popup
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _setDateError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      errorDateMessage = errorMessage;
    });
  }

  void _clearDateError() {
    setState(() {
      errorDateMessage = '';
    });
  }

  void _setDescriptionError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      errorDescriptionMessage = errorMessage;
    });
  }

  void _setValueError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      errorValueMessage = errorMessage;
    });
  }

  void _clearValueError() {
    setState(() {
      errorValueMessage = '';
    });
  }

  void _setTypeError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      errorTypeMessage = errorMessage;
    });
  }

  void _clearTypeError() {
    setState(() {
      errorTypeMessage = '';
    });
  }

  void _performTransactionCheck(
      String date, String value) {
    DateTime? parsedDate;
    try {
      date = date.replaceAll('/', '-');
      parsedDate = DateTime.parse(date);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'Invalid-Date-Format',
      );
    }
    _clearDateError();

    _clearDateError(); // Clear any previous errors

    _clearValueError(); // Clear any previous errors

    _clearTypeError(); // Clear any previous errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      appBar: AppBar(
        title: const Text('Add Water'), // Add const to Text widget
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _checkDateController,
              decoration: const InputDecoration(
                labelText: 'Data',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy/MM/dd').format(pickedDate);
                  setState(() {
                    _checkDateController.text = formattedDate;
                  });
                }
              },
            ),
            if (errorDateMessage.isNotEmpty) // Display error if there is one
              Text(
                errorDateMessage,
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _monetaryValueController,
              decoration: const InputDecoration(
                  labelText: 'Quantidade de água (mL)'), // Add const to InputDecoration
            ),
            if (errorValueMessage.isNotEmpty) // Display error if there is one
              Text(
                errorValueMessage,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20), // Add const to SizedBox
            ElevatedButton(
              onPressed: () {
                String thisDate = _checkDateController.text.trim();
                String thisMonetaryValue = _monetaryValueController.text.trim();
                String thisName = _typeController.text.trim();
                if (update == false) {
                  registerTransaction(thisDate,
                      thisMonetaryValue,thisName);
                } else {
                  updateTransaction(thisDate,
                      thisMonetaryValue,thisName);
                }
              },
              child:
                  const Text('Guardar registo de água'), // Add const to Text widget
            ),
          ],
        ),
      ),
    );
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