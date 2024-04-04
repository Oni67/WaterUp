import 'package:flutter/material.dart';
import 'package:waterup/data/fake_data.dart';
import 'package:waterup/pages/start.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HowTo(),
    );
  }
}

class HowTo extends StatefulWidget {
  const HowTo({Key? key});

  @override
  BudgetingState createState() => BudgetingState();
}

class BudgetingState extends State<HowTo> {
  final List<bool> _showExplanationList = List.generate(20, (index) => false);

  // Button texts for each index
  List<String> buttonTexts = [
    'The first how to goes here',
    'Button 2',
    'Button 3',
    'Button 4',
    'Button 5',
    'Button 6',
    'Button 7',
    'Button 8',
    'Button 9',
    'Button 10',
    'Button 11',
    'Button 12',
    'Button 13',
    'Button 14',
    'Button 15',
    'Button 16',
    'Button 17',
    'Button 18',
    'Button 19',
    'Button 20',
  ];

  // Messages for each index
  List<String> messages = [
    'The explanation of it goes here',
    'Message 2',
    'Message 3',
    'Message 4',
    'Message 5',
    'Message 6',
    'Message 7',
    'Message 8',
    'Message 9',
    'Message 10',
    'Message 11',
    'Message 12',
    'Message 13',
    'Message 14',
    'Message 15',
    'Message 16',
    'Message 17',
    'Message 18',
    'Message 19',
    'Message 20',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 30),
        child: Container(
            color: Colors.blue, // Set the color of the banner to blue
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.logout,
                      color: Colors.white), // Icon color set to white
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),
                const Text(
                  'WaterUp',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(width: 40), // Adjust the space between the icon and text as needed 
              ],
            ),
          ),
      ),
      body:
      ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 500, // Same width as the buttons
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 25, 164, 206)),
                  ),
                  onPressed: () {
                    setState(() {
                      _showExplanationList[index] =
                          !_showExplanationList[index];
                      for (int i = 0; i < _showExplanationList.length; i++) {
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
              const SizedBox(height: 15), // Add space between buttons
            ],
          );
        },
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
