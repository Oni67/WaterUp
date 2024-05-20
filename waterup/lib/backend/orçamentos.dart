import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checks.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  final Map<String, dynamic>? budgetData;
  final bool control;
  final String controlDocId;
  const BudgetScreen({Key? key, this.budgetData, required this.control, required this.controlDocId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TrasactionScreenState createState() => _TrasactionScreenState();
}

Future<List<DocumentSnapshot>> getList() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentReference document = firestore
        .collection('budget')
        .doc(FirebaseAuth.instance.currentUser?.email);

    QuerySnapshot querySnapshot = await document.collection('budgets').get();

    // Store the list of documents in the budgetList property
    //print(querySnapshot.docs);
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

Future<int> getBudgetMax(String budgetId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    int max = 0;
    String temp = '';
    DocumentReference document = firestore
        .collection('budget')
        .doc(FirebaseAuth.instance.currentUser?.email);

    QuerySnapshot querySnapshot = await document.collection('budgets').get();

      // Access transactions fields
      for (DocumentSnapshot document in querySnapshot.docs) {
        log('Data Limite: ${document['Data Limite']}, Percentagem Limite: ${document['Percentagem Limite']}, Orçamento Máximo: ${document['Orçamento Máximo']}, Nome: ${document['Nome']}');
        if (document['Nome'] == budgetId){
          temp = document['Orçamento Máximo'];
          max = int.parse(temp);
          print('Max:$max');
        }
      }
    return max;
  } catch (e) {
    print('Error getting budget list: $e');
    return 0;
  }
}

Future<Map<String,int>> getWaterHistoryByDate(String date) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try{
    String temp = '';
    int tempInt = 0;
    Map<String,int> transactions = {};
    CollectionReference documentTransaction = firestore
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('2024');

    QuerySnapshot querySnapshotTransaction =
        await documentTransaction.get();
    // Access transactions fields
      for (DocumentSnapshot document in querySnapshotTransaction.docs) {
        log('Data do registo: ${document['Data do registo']}, Quantidade de água: ${document['Quantidade de água (mL)']}');
        if(document['Data do registo'] == date){
          temp = document['Quantidade de água (mL)'];
          tempInt += int.parse(temp);
          transactions[document['Data do registo']] = tempInt;
        }
      }
  log('Transactions: $transactions');
  return transactions;
  } catch (e) {
    log('Error getting water list: $e');
    return {};
  }
}

Future<List<double>> calculatePercentage(String date) async {
  try {
    int max = 2000;
    double percent = 100;
    double temp = 0;
    Map<String,int> current = await getWaterHistoryByDate(date);
    List<double> percentage = [];
    for(int i in current.values){
      temp += (i / max) * 100;
    }
    if(temp > 100){
      percentage.add(100);
    }else{
    percentage.add(temp);
    }
    for (double e in percentage){
      percent -= e;
      if (percent < 0){
        percent = 0;
      }
    }
    percentage.add(percent);
    log("$percentage");
    print(percentage);
    return percentage;
  } catch (e) {
    print('Error getting budget list: $e');
    return [];
  }
}


Future<void> deleteBudget(String documentId) async {
  try {
    // Reference to the collection
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference document = firestore
        .collection('budget')
        .doc(FirebaseAuth.instance.currentUser?.email);

    // Delete the document
    await document.collection('budgets').doc(documentId).delete();

    log('Document deleted successfully!');
  } catch (e) {
    log('Error deleting document: $e');
  }
}

class _TrasactionScreenState extends State<BudgetScreen> {
  String _errorDateMessage = '';
  String _errorPercentageMessage = '';
  String _errorBudgetMessage = '';
  String _errorNameMessage = '';

  final TextEditingController _checkDateController = TextEditingController();
  final TextEditingController _limitPercentageController =
      TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool update = false;
  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with the existing budget data
    _checkDateController.text = widget.budgetData?['Data Limite'];
    _limitPercentageController.text = widget.budgetData?['Percentagem Limite'];
    _maxBudgetController.text = widget.budgetData?['Orçamento Máximo'];
    _nameController.text = widget.budgetData?['Nome'];
    update = widget.control;
  }
  String formatDate(DateTime date) {
  return DateFormat('yyyy/MM/dd').format(date);
}
DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _checkDateController.text = formatDate(pickedDate);
        _clearlimitdateError();
      });
    }
  }
  Future<void> _registerBudget(String limitdate, String limitPercentage,
      String maxBudget, String name) async {
    try {
      log('${FirebaseAuth.instance.currentUser}');

      await _performFirebaseChecks(limitdate, limitPercentage, maxBudget, name);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection and add a document
      DocumentReference transactions = firestore
          .collection('budget')
          .doc(FirebaseAuth.instance.currentUser?.email);
      // Determine the category based on user input
      // Create a reference to the category
        await transactions.collection('budgets').add({
          'Data Limite': checkDate(limitdate),
          'Percentagem Limite': limitPercentage,
          'Orçamento Máximo': maxBudget,
          'Nome': name
        });
      await _showSuccessDialog();
    } catch (e) {
      String errorDateMessage = '';
      String errorPercentageMessage = '';
      String errorBudgetMessage = '';
      String errorNameMessage = '';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'Invalid-Date-Format':
            errorDateMessage =
                'Invalid date format or empty, it should be DD/MM/YYYY or YYYY/MM/DD';
            break;
          case 'Invalid-Date-Time':
            errorDateMessage = 'Date cannot be in the past';
            break;
          case 'Invalid-Value-Percentage':
            errorPercentageMessage = 'Invalid Percentage Value';
            break;
          case 'Invalid-Value-Budget':
            errorBudgetMessage = 'Invalid Budget Value';
            break;
          case 'zero-value-Percentage':
            errorPercentageMessage = 'Limit Percentage must be above 0';
            break;
          case 'zero-value-Budget':
            errorBudgetMessage = 'Max Budget must be above 0';
            break;
          case 'Blank-Name':
            errorNameMessage = 'Name cannot be blank';
            break;
        }
      }
      log('$e');

      _setlimitdateError(errorDateMessage);
      _setlimitPercentageError(errorPercentageMessage);
      _setmaxBudgetError(errorBudgetMessage);
      _setmaxnametError(errorNameMessage);
    }
  }
  Future<void> _updateBudget(String limitdate, String limitPercentage,
      String maxBudget, String name) async {
    try {
      log('${FirebaseAuth.instance.currentUser}');

      await _performFirebaseChecks(limitdate, limitPercentage, maxBudget, name);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection and add a document
      DocumentReference transactions = firestore
          .collection('budget')
          .doc(FirebaseAuth.instance.currentUser?.email);
      // Determine the category based on user input
      // Create a reference to the category
        await transactions
          .collection('budgets')
          .doc(widget.controlDocId)
          .update({
        'Data Limite': checkDate(limitdate),
        'Percentagem Limite': limitPercentage,
        'Orçamento Máximo': maxBudget,
        'Nome': name,
      });
      await _showSuccessDialog();
    } catch (e) {
      String errorDateMessage = '';
      String errorPercentageMessage = '';
      String errorBudgetMessage = '';
      String errorNameMessage = '';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'Invalid-Date-Format':
            errorDateMessage =
                'Invalid date format or empty, it should be DD/MM/YYYY or YYYY/MM/DD';
            break;
          case 'Invalid-Date-Time':
            errorDateMessage = 'Date cannot be in the past';
            break;
          case 'Invalid-Value-Percentage':
            errorPercentageMessage = 'Invalid Percentage Value';
            break;
          case 'Invalid-Value-Budget':
            errorBudgetMessage = 'Invalid Budget Value';
            break;
          case 'zero-value-Percentage':
            errorPercentageMessage = 'Limit Percentage must be above 0';
            break;
          case 'zero-value-Budget':
            errorBudgetMessage = 'Max Budget must be above 0';
            break;
          case 'Blank-Name':
            errorNameMessage = 'Name cannot be blank';
            break;
        }
      }
      log('$e');

      _setlimitdateError(errorDateMessage);
      _setlimitPercentageError(errorPercentageMessage);
      _setmaxBudgetError(errorBudgetMessage);
      _setmaxnametError(errorNameMessage);
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Budget added successfully!'),
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

  void _setlimitdateError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      _errorDateMessage = errorMessage;
    });
  }

  void _clearlimitdateError() {
    setState(() {
      _errorDateMessage = '';
    });
  }

  void _setlimitPercentageError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      _errorPercentageMessage = errorMessage;
    });
  }

  void _clearlimitPercentageError() {
    setState(() {
      _errorPercentageMessage = '';
    });
  }

  void _setmaxBudgetError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      _errorBudgetMessage = errorMessage;
    });
  }

  void _clearmaxBudgetError() {
    setState(() {
      _errorBudgetMessage = '';
    });
  }

  void _setmaxnametError(String error) {
    setState(() {
      // Extract the error message from the error string
      final errorMessage =
          error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
      _errorNameMessage = errorMessage;
    });
  }

  void _clearmaxnametError() {
    setState(() {
      _errorNameMessage = '';
    });
  }

  Future<void> _performFirebaseChecks(String limitdate, String limitPercentage,
      String maxBudget, String name) async {
    if (!isValidDate(limitdate)) {
      throw FirebaseAuthException(
        code: 'Invalid-Date-Format',
      );
    }

    if (isDateInPast(limitdate)) {
      throw FirebaseAuthException(
        code: 'Invalid-Date-Time',
      );
    }

    if (!isValidValue(limitPercentage) || !isValidValue(maxBudget)) {
      if (!isValidValue(limitPercentage)) {
        throw FirebaseAuthException(
          code: 'Invalid-Value-Percentage',
        );
      } else {
        throw FirebaseAuthException(
          code: 'Invalid-Value-Budget',
        );
      }
    }

    if (double.parse(limitPercentage) <= 0 || double.parse(maxBudget) <= 0) {
      if (double.parse(limitPercentage) <= 0) {
        throw FirebaseAuthException(
          code: 'zero-value-Percentage',
        );
      } else {
        throw FirebaseAuthException(
          code: 'zero-value-Budget',
        );
      }
    }

    if (name.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'Blank-Name',
      );
    }

    _clearlimitdateError(); // Clear any previous errors
    _clearlimitPercentageError(); // Clear any previous errors
    _clearmaxBudgetError(); // Clear any previous errors
    _clearmaxnametError(); // Clear any previous errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registo de Orçamento'), // Add const to Text widget
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _checkDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data Limite',
                  ),
                ),
              ),
            ),
            if (_errorDateMessage.isNotEmpty)
              Text(
                _errorDateMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _limitPercentageController,
              decoration: const InputDecoration(
                  labelText:
                      'Percentagem Limite'), // Add const to InputDecoration
            ),
            if (_errorPercentageMessage
                .isNotEmpty) // Display error if there is one
              Text(
                _errorPercentageMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _maxBudgetController,
              decoration: const InputDecoration(
                  labelText:
                      'Orçamento Máximo'), // Add const to InputDecoration
            ),
            if (_errorBudgetMessage.isNotEmpty) // Display error if there is one
              Text(
                _errorBudgetMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Nome'), // Add const to InputDecoration
            ),
            if (_errorNameMessage.isNotEmpty) // Display error if there is one
              Text(
                _errorNameMessage,
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20), // Add const to SizedBox
            ElevatedButton(
              onPressed: () {
                String limitdate = _checkDateController.text.trim();
                String limitPercentage = _limitPercentageController.text.trim();
                String maxBudget = _maxBudgetController.text.trim();
                String name = _nameController.text.trim();
                if(update == false){
                _registerBudget(limitdate, limitPercentage, maxBudget, name);
                }
                else{
                  _updateBudget(limitdate, limitPercentage, maxBudget, name);
                }
              },
              child:
                  const Text('Guardar orçamento'), // Add const to Text widget
            ),
          ],
        ),
      ),
    );
  }
}
