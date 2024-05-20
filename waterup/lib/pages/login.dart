import 'package:waterup/main.dart';
import 'package:waterup/pages/start.dart';
import 'package:waterup/backend/login.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class Login extends StatelessWidget {
  const Login({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginIn(),
    );
  }
}

class LoginIn extends StatefulWidget {
  const LoginIn({Key? key});

  @override
  ThisLogin createState() => ThisLogin();
}

class ThisLogin extends State<LoginIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(236, 201, 198, 198),
        body: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/logo.png',
                  width: 350,
                  height: 350,
                ),
                const Text("Login", style: TextStyle(fontSize: 24)),
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
                if (emailError.isNotEmpty) // Display error if there is one
                  Text(
                    emailError,
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
                if (passwordError.isNotEmpty) // Display error if there is one
                  Text(
                    passwordError,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade700,
                  ),
                  onPressed: () {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    login(email, password).then((bool loginSuccessful) {
                      if (loginSuccessful) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NavigationExample()));
                      } else {
                        // Handle registration failure
                        // You might want to show an error message to the user
                        log("no no no");
                        setState(() {});
                      }
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    child: Text('Login'),
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
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ));
  }
}
