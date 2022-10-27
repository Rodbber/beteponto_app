import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:convert';
import 'package:bateponto_app/routes/routesAPIs.dart';

import 'package:localstorage/localstorage.dart';

import 'package:http/http.dart';

import 'package:fluttertoast/fluttertoast.dart';

class BtnSair extends StatefulWidget {
  BtnSair(
      {Key? key,
      required this.storage,
      required this.token,
      required this.verificaStatusPonto,
      required this.desativaIntervalos,
      required this.desativaPontos})
      : super(key: key);

  LocalStorage storage;
  String token;
  Function verificaStatusPonto;
  Function desativaIntervalos;
  Function desativaPontos;

  @override
  State<BtnSair> createState() => _BtnSairState();
}

class _BtnSairState extends State<BtnSair> {
  final RoundedLoadingButtonController _btnSair =
      RoundedLoadingButtonController();

  void _sair(RoundedLoadingButtonController controller) async {
    setState(() {
      widget.desativaIntervalos();
      widget.desativaPontos();
    });

    var url = Uri.parse(Routes.logout());
    try {
      var response = await post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(Duration(seconds: 10));
      var responseBody = response.body;
      //print(response);
      controller.reset();
      var obj = jsonDecode(responseBody);
      widget.storage.clear();
      Navigator.pop(context, '/');
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Ocorreu um erro ao tentar sair!',
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.red);

      widget.verificaStatusPonto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      color: Colors.blue[300],
      // successColor: Colors.amber,
      controller: _btnSair,
      onPressed: () => _sair(_btnSair),
      valueColor: Colors.black,

      borderRadius: 10,
      child: const Text(
        'Sair',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }
}
