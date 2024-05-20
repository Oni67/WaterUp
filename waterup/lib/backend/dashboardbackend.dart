import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, int>> getWaterHistoryByDate(String date) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    String temp = '';
    int tempInt = 0;
    Map<String, int> transactions = {};
    CollectionReference documentTransaction = firestore
        .collection('WaterHistory')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('2024');

    QuerySnapshot querySnapshotTransaction = await documentTransaction.get();
    // Access transactions fields
    for (DocumentSnapshot document in querySnapshotTransaction.docs) {
      log('Data do registo: ${document['Data do registo']}, Quantidade de água: ${document['Quantidade de água (mL)']}');
      if (document['Data do registo'] == date) {
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

Future<double> getWaterIntakeOfUser() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    DocumentReference documentTransaction = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    DocumentSnapshot documentSnapshot = await documentTransaction.get();

    if (documentSnapshot.exists) {
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('Intake')) {
        log('Intake ${data['Intake']}');
        return double.parse(data['Intake']);
      } else {
        log('Intake field is missing in the document');
        return 2;
      }
    } else {
      log('Document does not exist');
      return 2; 
    }
  } catch (e) {
    log('Error getting user list: $e');
    return 2;
  }
}

Future<List<double>> calculatePercentage(String date) async {
  try {
    double max = await getWaterIntakeOfUser() * 1000;
    log('max$max');
    double percent = 100;
    double temp = 0;
    Map<String, int> current = await getWaterHistoryByDate(date);
    List<double> percentage = [];
    for (int i in current.values) {
      temp += (i / max) * 100;
    }
    if (temp > 100) {
      percentage.add(100);
    } else {
      percentage.add(temp);
    }
    for (double e in percentage) {
      percent -= e;
      if (percent < 0) {
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