import 'package:waterup/pages/login.dart';
import 'package:waterup/pages/start.dart';
import 'package:waterup/backend/register.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class Register extends StatelessWidget {
  const Register({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Registering(),
    );
  }
}

class Registering extends StatefulWidget {
  const Registering({Key? key});

  @override
  ThisRegister createState() => ThisRegister();
}

class ThisRegister extends State<Registering> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              '../images/logo.png',
              width: 350,
              height: 350,
            ),
            const Text("Registo", style: TextStyle(fontSize: 24)),
            SizedBox(
              width: 250,
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            if (errorEmail.isNotEmpty) // Display error if there is one
              Text(
                errorEmail,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 15),
            SizedBox(
              width: 250,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            if (errorPassword.isNotEmpty) // Display error if there is one
              Text(
                errorPassword,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 15),
            SizedBox(
              width: 250,
              child: TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirmação de Password',
                ),
              ),
            ),
            if (errorConfirmation.isNotEmpty) // Display error if there is one
              Text(
                errorConfirmation,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade700,
              ),
              onPressed: () {
                String email = emailController.text;
                String password = passwordController.text;
                String confirmPassword = confirmPasswordController.text;
                register(email, password, confirmPassword)
                    .then((bool registrationSuccessful) {
                  if (registrationSuccessful) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  } else {
                    // Handle registration failure
                    // You might want to show an error message to the user
                    setState(() {});
                    log("no");
                  }
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: Text('Registar'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
