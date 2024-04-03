import 'package:waterup/main.dart';
import 'package:flutter/material.dart';

/// Criação da caixa de diálogo com 1 botão
void dialogBox1Button(context, title, content){
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Criação da caixa de diálogo com 2 botões
void dialogBox2Button(context, title, content){
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationExample())),
          child: const Text('Página principal'),
        ),
      ],
    ),
  );
}