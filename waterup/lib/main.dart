import 'package:flutter/material.dart';
import 'package:waterup/pages/budgeting.dart';
import 'package:waterup/pages/watch_transations.dart';
import 'package:waterup/pages/recurring_transactions.dart';
import 'package:waterup/pages/start.dart';
import 'package:waterup/pages/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const NavigationBarApp());
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 25, 101, 124),
        unselectedItemColor: const Color.fromARGB(255, 98, 132, 143),
        currentIndex: currentPageIndex,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Add Water',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'How to',),
        ],
      ),
      body: [
        const Dashboard(),
        const TransactionsPage(),
        const RecurrentTransactionsPage(),
        const BudgetingPage(),
      ][currentPageIndex],
    );
  }
}
