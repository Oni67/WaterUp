import 'package:flutter/material.dart';
import 'package:waterup/pages/HowTo.dart';
import 'package:waterup/pages/Water_History.dart';
import 'package:waterup/pages/profile_page.dart';
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
  final int initialPageIndex;

  const NavigationExample({super.key, this.initialPageIndex = 0});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  late int currentPageIndex;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.initialPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 46, 162, 197),
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
            label: 'How to',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
      body: [
        const Dashboard(),
        const WaterHistoryPage(),
        const RecurrentTransactionsPage(),
        const HowToPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}
