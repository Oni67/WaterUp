import 'package:flutter/material.dart';
import 'package:waterup/data/fake_data.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 30),
        child: AppBar(
          title: const Text(
            'How To:',
            style: TextStyle(fontSize: 48),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 48, // Set the font size to maintain the larger size
            fontWeight: FontWeight.bold, // Optional: make the text bold
            letterSpacing: 2.0, // Optional: adjust letter spacing
            fontStyle: FontStyle.italic, // Optional: adjust font style
            color: Colors.black, // Optional: set custom text color
            shadows: [
              Shadow(
                color: Colors.grey,
                offset: Offset(
                    2, 2), // Move the shadow slightly to the right and down
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                width: 500, // Same width as the buttons
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 17, 72, 88)),
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
