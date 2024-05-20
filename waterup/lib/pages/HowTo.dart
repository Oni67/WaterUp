import 'package:flutter/material.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HowTo(),
    );
  }
}

class HowTo extends StatefulWidget {
  const HowTo({Key? key}) : super(key: key);

  @override
  BudgetingState createState() => BudgetingState();
}

class BudgetingState extends State<HowTo> {
  final List<bool> _showExplanationList = List.generate(9, (index) => false);

  // Button texts for each index
  List<String> buttonTexts = [
    'Home',
    'Add Water',
    'How to',
    'Profile',
    'How do I log out?',
    'How do I register water intake?',
    'How do I view Intake history?',
    'How do I edit or delete my water history?',
    'Why does my profile require all this information?',
  ];

  // Messages for each index
  List<String> messages = [
    "In the Home menu, you can view your progress on today's water goal and logout from the application.",
    'In the Add Water menu, you can register your water intake and view your drinking history.',
    'This is where you are! Here, you can get help on how to use the app.',
    'In the Profile menu, you can edit all your information, which we will use to determine how much water you should drink each day.',
    'You can find the logout button in the top left corner of the Home menu.',
    'To register your Water intake, you must navigate to the Add Water menu and press the "+" icon',
    'To view your intake history, you must navigate to the Add Water menu and navigate through the calendar at the top and view the weekly graph.',
    'To edit or delete water history, you must navigate to the Add Water menu and navigate through the calendar at the top to select the desired week and edit or delete the entries that will appear below the graph.',
    'All the information we request in the Profile menu is used to calculate your ideal water intake for each day.',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(236, 201, 198, 198),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue, // Set the color of the banner to blue
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WaterUp',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: const Text(
              'How To:',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 28.0, // Increase the font size
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 9,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    const SizedBox(height: 10), // Reduce space between items
                    SizedBox(
                      width: 500, // Same width as the buttons
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 25, 164, 206)),
                        ),
                        onPressed: () {
                          setState(() {
                            _showExplanationList[index] =
                                !_showExplanationList[index];
                            for (int i = 0;
                                i < _showExplanationList.length;
                                i++) {
                              if (i != index) {
                                _showExplanationList[i] = false;
                              }
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_downward),
                              const SizedBox(width: 2),
                              Text(buttonTexts[index]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_showExplanationList[index])
                      ExplanationDialog(
                        message: messages[index],
                        onClose: () =>
                            setState(() => _showExplanationList[index] = false),
                      ),
                    const SizedBox(height: 10), // Reduce space between buttons
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExplanationDialog extends StatelessWidget {
  final String message;
  final Function onClose;

  const ExplanationDialog(
      {super.key, required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async {
          onClose(); // Call onClose function when back button is pressed
          return true;
        },
        child: Container(
          width: 500, // Same width as the buttons
          color: Colors.grey[200],
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
