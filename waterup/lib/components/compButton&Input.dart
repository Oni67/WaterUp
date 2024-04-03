import 'package:flutter/material.dart';

///Criação do campo de inserção de texto
SizedBox generateTextInput(onChangeFunction, [String placeholder = "", double width=300]){
  return SizedBox(
    width: width,
    child: TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: placeholder,
      ),
      onChanged: onChangeFunction,
    ),
  );
}

/// Criação do botão
SizedBox generateButton(String textToShow, context, path){
  return SizedBox(
    width: 300,
    height: 50,
    child: ElevatedButton(
      onPressed: () => {
        if (path is Widget) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => path)
          )
        } else if(path is String && path == "back"){
          Navigator.pop(context)
        } else if(path is String){
          
        } else {
          path()
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        textToShow,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))
      ),
    ),
  );
}