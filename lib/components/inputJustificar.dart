import 'package:flutter/material.dart';

class InputJustificar extends StatefulWidget {
  const InputJustificar({Key? key}) : super(key: key);

  @override
  State<InputJustificar> createState() => _InputJustificarState();
}

class _InputJustificarState extends State<InputJustificar> {
  final TextEditingController _justificaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: _justificaController,
        decoration: InputDecoration(
          labelText: "Justificativa",
          labelStyle: TextStyle(
            color: Colors.black38,
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
