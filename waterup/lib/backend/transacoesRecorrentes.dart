// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checks.dart';

class TransacoesRecorrentesScreen extends StatefulWidget {
  final Map<String, dynamic>? recurrentTransactionData;
  final bool control;
  final String controlDocId;
  List<String> budgets;
  TransacoesRecorrentesScreen(
      {Key? key,
      this.recurrentTransactionData,
      required this.control,
      required this.controlDocId,
      required this.budgets})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecurrentTrasactionScreenState createState() =>
      _RecurrentTrasactionScreenState();
}

Future<List<DocumentSnapshot>> getRecurrentTransactionsList() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    CollectionReference document = firestore
        .collection('recurrent_transactions')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('category');

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

Future<void> deleteReccurrentTransaction(String documentId) async {
  try {
    // Reference to the collection
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference document = firestore
        .collection('recurrent_transactions')
        .doc(FirebaseAuth.instance.currentUser?.email);

    // Delete the document
    await document.collection('category').doc(documentId).delete();

    log('Document deleted successfully!');
  } catch (e) {
    log('Error deleting document: $e');
  }
}

class _RecurrentTrasactionScreenState
    extends State<TransacoesRecorrentesScreen> {
  String errorRegularityMessage = '';
  String errorDescriptionMessage = '';
  String errorValueMessage = '';
  String errorTypeMessage = '';
  String? selectedBudget;

  final TextEditingController _checkValueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _regularityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool update = false;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      List<String> fetchedBudgets = await fetchBudgetsFromFirebase();

      // Update the state with the fetched budgets
      setState(() {
        widget.budgets = fetchedBudgets;
      });

      // Pre-fill the text fields with the existing budget data
      _checkValueController.text = widget.recurrentTransactionData?['Valor'];
      _descriptionController.text =
          widget.recurrentTransactionData?['Descrição'];
      _regularityController.text =
          widget.recurrentTransactionData?['regularidade'];
      _nameController.text = widget.recurrentTransactionData?['tipo'];
      update = widget.control;
    } catch (e) {
      // Handle errors if needed
      print('Error initializing data: $e');
    }
  }

  Future<void> registerRecurrentTransaction(String valor, String descricao,
      String regularidade, String tipo, String? budget) async {
    try {
      log('${FirebaseAuth.instance.currentUser}');

      await _performRecurrentCheck(valor, descricao, regularidade, tipo);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection and add a document
      DocumentReference transactions = firestore
          .collection('recurrent_transactions')
          .doc(FirebaseAuth.instance.currentUser?.email);
      // Determine the category based on user input
      String transactionCategory = tipo.isEmpty ? 'No category' : tipo;
      // Create a reference to the category
      await transactions.collection('category').doc().set({
        'Valor': valor,
        'Descrição': descricao,
        'regularidade': regularidade,
        'tipo': transactionCategory,
        'budgetId': budget,
      });
      await _showSuccessDialog();
    } catch (e) {
      errorRegularityMessage = '';
      errorDescriptionMessage = '';
      errorValueMessage = '';
      errorTypeMessage = '';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'Invalid-Regularity':
            errorRegularityMessage =
                'Invalid regularity. It can only be diariamente, semanalmente, mensalmente ou anualmente';
            break;
          case 'Invalid-Value':
            errorValueMessage = 'Invalid Value';
            break;
          case 'Blank-Type':
            errorTypeMessage = 'Type cannot be blank';
            break;
          case 'Blank-Description':
            errorDescriptionMessage = 'Description cannot be blank';
            break;
        }
      }
      log('$e');

      _setRegularityError(errorRegularityMessage);
      _setDescriptionError(errorDescriptionMessage);
      _setValueError(errorValueMessage);
      _setTypeError(errorTypeMessage);
    }
  }

  Future<void> updateRecurrentTransaction(String valor, String descricao,
      String regularidade, String tipo, String? budget) async {
    try {
      log('${FirebaseAuth.instance.currentUser}');

      await _performRecurrentCheck(valor, descricao, regularidade, tipo);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection and add a document
      DocumentReference transactions = firestore
          .collection('recurrent_transactions')
          .doc(FirebaseAuth.instance.currentUser?.email);
      // Determine the category based on user input
      String transactionCategory = tipo.isEmpty ? 'No category' : tipo;
      // Create a reference to the category
      await transactions
          .collection('category')
          .doc(widget.controlDocId)
          .update({
        'Valor': valor,
        'Descrição': descricao,
        'regularidade': regularidade,
        'tipo': transactionCategory,
        'budgetId': budget,
      });
      await _showSuccessDialog();
    } catch (e) {
      errorRegularityMessage = '';
      errorDescriptionMessage = '';
      errorValueMessage = '';
      errorTypeMessage = '';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'Invalid-Value':
            errorValueMessage = 'Invalid Value';
            break;
          case 'Blank-Description':
            errorTypeMessage = 'Description cannot be blank';
            break;
          case 'Invalid-Regularity':
            errorValueMessage =
                'Invalid regularity. It can only be diariamente, semanalmente, mensalmente ou anualmente';
            break;
          case 'Blank-Type':
            errorTypeMessage = 'Type cannot be blank';
            break;
        }
      }
      log('$e');

      _setRegularityError(errorRegularityMessage);
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
          content: const Text('Recurrent Transaction added successfully!'),
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

  void _setRegularityError(String error) {
    setState(() {
      // Extract the error message from the error string
      errorRegularityMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
    });
  }

  void _clearRegularityError() {
    setState(() {
      errorRegularityMessage = '';
    });
  }

  void _setDescriptionError(String error) {
    setState(() {
      // Extract the error message from the error string
      errorDescriptionMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
    });
  }

  void _clearDescriptionError() {
    setState(() {
      errorDescriptionMessage = '';
    });
  }

  void _setValueError(String error) {
    setState(() {
      // Extract the error message from the error string
      errorValueMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
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
      errorTypeMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
    });
  }

  void _clearTypeError() {
    setState(() {
      errorTypeMessage = '';
    });
  }

  Future<void> _performRecurrentCheck(String value, String description,
      String regularidade, String category) async {
    if (!isValidValue(value)) {
      throw FirebaseAuthException(
        code: 'Invalid-Value',
      );
    }

    if (description.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'Blank-Description',
      );
    }
    _clearDescriptionError(); // Clear any previous errors

    if (!isValidTime(regularidade)) {
      throw FirebaseAuthException(
        code: 'Invalid-Regularity',
      );
    }

    _clearRegularityError(); // Clear any previous errors

    if (category.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'Blank-Type',
      );
    }

    _clearTypeError(); // Clear any previous errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Registo de Transações Recorrentes'), // Add const to Text widget
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _checkValueController,
              decoration: const InputDecoration(
                  labelText: 'Valor'), // Add const to InputDecoration
            ),
            if (errorValueMessage.isNotEmpty) // Display error if there is one
              Text(
                errorValueMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Descrição'), // Add const to InputDecoration
            ),
            if (errorDescriptionMessage
                .isNotEmpty) // Display error if there is one
              Text(
                errorDescriptionMessage,
                style: TextStyle(color: Colors.red),
              ),
            DropdownButton<String>(
              value: _regularityController.text.isNotEmpty
                  ? _regularityController.text
                  : null, // Set an initial value from the list
              hint: const Text('Select regularidade'),
              onChanged: (String? newValue) {
                setState(() {
                  _regularityController.text = newValue!;
                });
              },
              items: [
                'diariamente',
                'semanalmente',
                'mensalmente',
                'anualmente'
              ].map<DropdownMenuItem<String>>(
                (String regularidade) {
                  return DropdownMenuItem<String>(
                    value: regularidade,
                    child: Text(regularidade),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 20),
            if (errorRegularityMessage
                .isNotEmpty) // Display error if there is one
              Text(
                errorRegularityMessage,
                style: TextStyle(color: Colors.red),
              ),
            DropdownButton<String>(
              value: _nameController.text.isNotEmpty
                  ? _nameController.text
                  : null, // Set an initial value from the list
              hint: const Text('Select tipo'),
              onChanged: (String? newValue) {
                setState(() {
                  _nameController.text = newValue!;
                });
              },
              items: ['dinheiro', 'cartão de crédito']
                  .map<DropdownMenuItem<String>>(
                (String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 20),
            if (errorTypeMessage.isNotEmpty) // Display error if there is one
              Text(
                errorTypeMessage,
                style: TextStyle(color: Colors.red),
              ),
            DropdownButton<String>(
              value: selectedBudget,
              hint: const Text('Select a budget'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedBudget = newValue;
                });
              },
              items: widget.budgets.map<DropdownMenuItem<String>>(
                (String budget) {
                  return DropdownMenuItem<String>(
                    value: budget,
                    child: Text(budget),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 20), // Add const to SizedBox
            ElevatedButton(
              onPressed: () {
                String valor = _checkValueController.text.trim();
                String descricao = _descriptionController.text.trim();
                String regularidade = _regularityController.text.trim();
                String tipo = _nameController.text.trim();
                if (update == false) {
                  registerRecurrentTransaction(
                      valor, descricao, regularidade, tipo, selectedBudget);
                } else {
                  updateRecurrentTransaction(
                      valor, descricao, regularidade, tipo, selectedBudget);
                }
              },
              child: const Text(
                  'Guardar transação recorrente'), // Add const to Text widget
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
