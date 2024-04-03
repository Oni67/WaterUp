import 'package:flutter/material.dart';

class DropdowButtonComponent extends StatefulWidget {
  final List<String> list;
  final ValueChanged<String?> onChanged;

  const DropdowButtonComponent(this.list, {required this.onChanged, Key? key});

  @override
  State<DropdowButtonComponent> createState() => _DropdownButtonState(list);
}

class _DropdownButtonState extends State<DropdowButtonComponent> {
  late List<String> dropdownList;
  String? dropdownValue;

  _DropdownButtonState(List<String> list) {
    dropdownList = list;
    dropdownList.insert(0, 'Select a budget');
    dropdownValue = null;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      underline: Container(
        height: 2,
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value;
        });

        // Call the onChanged callback with the selected value (or null if it's the placeholder)
        widget.onChanged(value == 'Select a budget' ? null : value);
      },
      items: dropdownList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value == 'Select a budget' ? null : value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
