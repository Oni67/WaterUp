import 'package:flutter/material.dart';

/// Criação de um botão checkbox
class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {

    return Checkbox(
      checkColor: Colors.white,
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}


/// Criação de um campo checkbox (botão mais expressão)
Row checkboxWithText(String text){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      const CheckboxExample(),
      Text(text)
    ],
  );
}