import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key});

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        setState(() {
          _nameController.text = snapshot.data()!['Name'] ?? '';
          _emailController.text = snapshot.data()!['Email'] ?? '';
          _dobController.text = snapshot.data()!['Date Of Birth'] ?? '';
        });
      }
    } catch (e) {
      // Handle errors
      print('Error loading profile data: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Upload the image to Firebase Storage
      await _uploadImageToFirebaseStorage();
    }
  }

Future<void> _uploadImageToFirebaseStorage() async {
  try {
    if (_selectedImage != null) {
      final firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref().child(
                'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
      final firebase_storage.UploadTask uploadTask =
          storageRef.putFile(_selectedImage!);
      await uploadTask.whenComplete(() async {
        final String imageUrl = await storageRef.getDownloadURL();
        print('Uploaded image URL: $imageUrl');
        // Save the image URL to Firestore or perform any other operation
        await _saveImageUrlToFirestore(imageUrl);
      });
    }
  } catch (e) {
    print('Error uploading image to Firebase Storage: $e');
    // Handle error
  }
}

Future<void> _saveImageUrlToFirestore(String imageUrl) async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
    });
  } catch (e) {
    print('Error saving image URL to Firestore: $e');
    // Handle error
  }
}

  void _saveProfileData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String name = _nameController.text;
      String email = _emailController.text;
      String dob = _dobController.text;
      // Implement logic to save profile data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'Name': name,
        'Email': email,
        'Date Of Birth': dob,
        // Add more fields as needed
      });
      // Optionally, show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      // Handle errors
      print('Error saving profile data: $e');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _selectImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey, // Placeholder color
              ),
              child: _selectedImage != null
                  ? Image.network(
                      _selectedImage!.path,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.person, size: 50), // Placeholder icon
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(), // Add border to text field
            ),
          ),
          SizedBox(height: 16.0), // Add spacing between fields
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(), // Add border to text field
            ),
          ),
          SizedBox(height: 16.0),
          InkWell(
            onTap: _selectDate,
            child: IgnorePointer(
              child: TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(), // Add border to text field
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Center(
            child: ElevatedButton(
              onPressed: _saveProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, // Set button color to light blue
              ),
              child: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
