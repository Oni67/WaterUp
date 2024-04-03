import 'package:collection/collection.dart';

class FakeData {
  final double x;
  final double y;

  FakeData({required this.x, required this.y});
}

List<FakeData> get fakeData {
  final data = <double>[2, 2, 2, 4, 5, 3, 1, 10];
  return data
      .mapIndexed(
          ((index, element) => FakeData(x: index.toDouble(), y: element)))
      .toList();
}

class BudgetList {
  List<String> budgetList;

  BudgetList() : budgetList = [
    'Orçamento 1',
    'Orçamento 2',
    'Orçamento 3',
    'Orçamento 4',
    'Orçamento 5',
    'Orçamento 6',
    'Orçamento 7',
    'Orçamento 8',
    'Orçamento 9',
    'Orçamento 10',
    'Orçamento 11',
    'Orçamento 12',
    'Orçamento 13',
    'Orçamento 14',
    'Orçamento 15',
    'Orçamento 16',
    'Orçamento 17',
    'Orçamento 18',
    'Orçamento 19',
    'Orçamento 20',
    'Orçamento 21',
    'Orçamento 22',
    'Orçamento 23',
  ];

  BudgetList.withInitialValues(List<String> initialValues)
      : budgetList = initialValues;

  String? get first => null;
}

class TransactionsList {
  List<String> transationList;

  TransactionsList() : transationList = [
    'Transação 1',
    'Transação 2',
    'Transação 3',
    'Transação 4',
    'Transação 5',
    'Transação 6',
    'Transação 7',
    'Transação 8',
    'Transação 9',
    'Transação 10',
    'Transação 11',
    'Transação 12',
    'Transação 13',
    'Transação 14',
    'Transação 15',
    'Transação 16',
    'Transação 17',
    'Transação 18',
    'Transação 19',
    'Transação 20',
    'Transação 21',
    'Transação 22',
    'Transação 23',
  ];

  TransactionsList.withInitialValues(List<String> initialValues)
      : transationList = initialValues;

  String? get first => null;
}

class RecorringTransation {
  List<String> recurringTransaction;

  RecorringTransation() : recurringTransaction = [
    'Transação recorrente 1',
    'Transação recorrente 2',
    'Transação recorrente 3',
    'Transação recorrente 4',
    'Transação recorrente 5',
    'Transação recorrente 6',
    'Transação recorrente 7',
    'Transação recorrente 8',
    'Transação recorrente 9',
    'Transação recorrente 10',
    'Transação recorrente 11',
    'Transação recorrente 12',
    'Transação recorrente 13',
    'Transação recorrente 14',
    'Transação recorrente 15',
    'Transação recorrente 16',
    'Transação recorrente 17',
    'Transação recorrente 18',
    'Transação recorrente 19',
    'Transação recorrente 20',
    'Transação recorrente 21',
    'Transação recorrente 22',
    'Transação recorrente 23',
  ];

  RecorringTransation.withInitialValues(List<String> initialValues)
      : recurringTransaction = initialValues;

  String? get first => null;
}