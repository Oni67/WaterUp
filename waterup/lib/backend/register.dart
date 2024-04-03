import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

String errorEmail = '';
String errorPassword = '';
String errorConfirmation = '';

Future<bool> register(String email, String password, String confirm) async {
  try {
    if (!_hasLowercase(password)) {
      throw FirebaseAuthException(
        code: 'missing-lowercase',
        message: 'Password must contain at least 1 lowercase letter',
      );
    }

    if (!_hasUppercase(password)) {
      throw FirebaseAuthException(
        code: 'missing-uppercase',
        message: 'Password must contain at least 1 uppercase letter',
      );
    }

    if (!_hasNumber(password)) {
      throw FirebaseAuthException(
        code: 'missing-number',
        message: 'Password must contain at least 1 number',
      );
    }

    if (!_hasSpecialCharacter(password)) {
      throw FirebaseAuthException(
        code: 'missing-special-character',
        message:
            'Password must contain at least 1 special character (.!@%#\$&*~)',
      );
    }

    _clearPasswordError();

    if (password != confirm) {
      throw FirebaseAuthException(
        code: 'passwords-not-matching',
        message: 'Passwords do not match',
      );
    }

    _clearConfirmationError();

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    log('User created $email');

    _clearEmailError();
    return true;
  } catch (e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          errorEmail = 'Bad Email format. Please check your email';
          break;
        case 'email-already-in-use':
          errorEmail = 'address is already in use by another account';
          break;
        case 'weak-password':
          errorPassword = 'Password should be at least 6 characters';
          break;
        case 'missing-email':
          errorEmail = 'email cannot be blank. Please write your email';
          break;
        case 'missing-password':
          errorPassword = 'password cannot be blank. Please write a password';
          break;
        case 'missing-lowercase':
          errorPassword = 'Password must contain at least 1 lowercase letter';
          break;
        case 'missing-uppercase':
          errorPassword = 'Password must contain at least 1 uppercase letter';
          break;
        case 'missing-number':
          errorPassword = 'Password must contain at least 1 number';
          break;
        case 'missing-special-character':
          errorPassword =
              'Password must contain at least 1 special character (.!@%#\$&*~)';
          break;
        case 'passwords-not-matching':
          errorConfirmation = 'Passwords do not match';
          break;
        default:
          errorEmail = 'Error signing in. Please try again later.';
          break;
      }
    } else {
      errorEmail = 'Error signing in. Please try again later.';
    }
    log('Error registering user: $e');
    _setEmailError(errorEmail);
    _setPasswordError(errorPassword);
    _setConfirmationError(errorConfirmation);
  }
  return false;
}

bool _hasLowercase(String value) {
  return RegExp(r'[a-z]').hasMatch(value);
}

bool _hasUppercase(String value) {
  return RegExp(r'[A-Z]').hasMatch(value);
}

bool _hasNumber(String value) {
  return RegExp(r'[0-9]').hasMatch(value);
}

bool _hasSpecialCharacter(String value) {
  return RegExp(r'[.!@#\%$&*~]').hasMatch(value);
}

void _setEmailError(String error) {
  // Extract the error message from the error string
  final errorMessage =
      error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
  errorEmail = errorMessage;
}

void _setPasswordError(String error) {
  // Extract the error message from the error string
  final errorMessage =
      error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
  errorPassword = errorMessage;
}

void _setConfirmationError(String error) {
  // Extract the error message from the error string
  final errorMessage =
      error.replaceAllMapped(RegExp(r'\[.*\]\s'), (match) => '');
  errorConfirmation = errorMessage;
}

void _clearEmailError() {
  errorEmail = '';
}

void _clearPasswordError() {
  errorPassword = '';
}

void _clearConfirmationError() {
  errorConfirmation = '';
}
