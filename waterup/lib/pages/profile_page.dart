import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';

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
  String exerciseFrequency = 'No exercise';
  double weight = 70.0; // default weight
  double height = 170.0; // default height

  final List<String> exerciseOptions = [
    'No exercise',
    '1-2 days a week',
    '3-4 days a week',
    '5-6 days a week',
    'Every day',
  ];

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
          exerciseFrequency =
              snapshot.data()!['Exercise Frequency'] ?? 'No exercise';
          weight = (snapshot.data()!['Weight'] ?? 70).toDouble();
          height = (snapshot.data()!['Height'] ?? 170).toDouble();
        });
      }
    } catch (e) {
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
          await _saveImageUrlToFirestore(imageUrl);
        });
      }
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
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
    }
  }

  void _saveProfileData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String name = _nameController.text;
      String email = _emailController.text;
      String dob = _dobController.text;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'Name': name,
        'Email': email,
        'Date Of Birth': dob,
        'Exercise Frequency': exerciseFrequency,
        'Weight': weight,
        'Height': height,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      print('Error saving profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile data')),
      );
    }
  }

  double calculateWaterIntake() {
    double waterIntake = weight * 0.033;
    switch (exerciseFrequency) {
      case '1-2 days a week':
        waterIntake += 0.5;
        break;
      case '3-4 days a week':
        waterIntake += 1.0;
        break;
      case '5-6 days a week':
        waterIntake += 1.5;
        break;
      case 'Every day':
        waterIntake += 2.0;
        break;
    }
    return waterIntake;
  }

  void _showWeightPicker(BuildContext context) {
    int tempWeight = weight.toInt();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.0,
          color: Colors.white, // Set background color
          child: Column(
            children: [
              Container(
                height: 32.0,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      weight = tempWeight.toDouble();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.blue, // Button text color
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    tempWeight = index + 30; // Adjust to your minimum value
                  },
                  children: List<Widget>.generate(121, (int index) {
                    return Center(child: Text('${index + 30} kg',style: TextStyle(color: tempWeight == index + 30 ? Colors.blue : Colors.black,)));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHeightPicker(BuildContext context) {
    int tempHeight = height.toInt();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          color: Colors.white, // Set background color
          child: Column(
            children: [
              Container(
                height: 32.0,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      height = tempHeight.toDouble();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.blue, // Button text color
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  diameterRatio: 1.0,
                  onSelectedItemChanged: (int index) {
                    tempHeight = index + 100; // Adjust to your minimum value
                  },
                  children: List<Widget>.generate(121, (int index) {
                    return Center(child: Text('${index + 100} cm', style: TextStyle(color: tempHeight == index + 100 ? Colors.blue : Colors.black,)));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
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
                    ? Image.file(
                        _selectedImage!,
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
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: exerciseFrequency,
              onChanged: (String? newValue) {
                setState(() {
                  exerciseFrequency = newValue!;
                });
              },
              items:
                  exerciseOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text('Weight: ${weight.toStringAsFixed(1)} kg'),
              trailing: Icon(Icons.edit),
              onTap: () => _showWeightPicker(context),
            ),
            ListTile(
              title: Text('Height: ${height.toStringAsFixed(1)} cm'),
              trailing: Icon(Icons.edit),
              onTap: () => _showHeightPicker(context),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.lightBlue, // Set button color to light blue
                ),
                child: const Text('Save Profile'),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Text(
                'Recommended Water Intake: ${calculateWaterIntake().toStringAsFixed(2)} liters/day',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
