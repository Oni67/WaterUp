// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(236, 201, 198, 198),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue, // Set the color of the banner to blue
            padding: EdgeInsets.symmetric(vertical: 10),
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
          SizedBox(height: 16.0),
          const Expanded(
            // Use Expanded to allow ListView.builder to occupy remaining space
            child: ProfileForm(), // Display the profile form directly
          ),
        ],
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Add more controllers for other fields

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(), // Add border to text field
          ),
        ),
        const SizedBox(height: 16), // Add spacing between fields
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(), // Add border to text field
          ),
        ),
        // Add more text fields for other profile information
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Handle saving profile information
              String name = _nameController.text;
              String email = _emailController.text;
              // Save the information or perform validation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.lightBlue, // Set button color to light blue
            ),
            child: const Text('Save Profile'),
          ),
        )
      ],
    );
  }
}
