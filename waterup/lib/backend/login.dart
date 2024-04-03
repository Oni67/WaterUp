import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

String emailError = "";
String passwordError = "";

Future<bool> login(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _clearEmailError();
    _clearPasswordError();
    return true;
  } catch (e) {
    log('Error signing in: $e');

    String errorEmailMessage = '';
    String errorPasswordMessage = '';

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          errorEmailMessage = 'Bad Email format. Please check your email.';
          break;
        case 'missing-password':
          errorPasswordMessage = 'Password cannot be blank. Please try again.';
          break;
        case 'invalid-login-credentials':
          errorEmailMessage = "Incorrect Email or Password. Please try again";
          break;
        default:
          errorEmailMessage = 'Error signing in. Please try again later.';
          break;
      }
    } else {
      errorEmailMessage = 'Error signing in. Please try again later.';
    }

    setEmailError(errorEmailMessage);
    setPasswordError(errorPasswordMessage);
    return false;
  }
}

void setEmailError(String error) {
  // Extract the error message from the error string
  final errorMessage =
      error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
  emailError = errorMessage;
}

void _clearEmailError() {
  emailError = '';
}

void setPasswordError(String error) {
  // Extract the error message from the error string
  final errorMessage =
      error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
  passwordError = errorMessage;
  ;
}

void _clearPasswordError() {
  passwordError = '';
}
