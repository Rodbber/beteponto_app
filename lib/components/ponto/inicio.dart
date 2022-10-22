import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:convert';
import 'package:bateponto_app/routes/routesAPIs.dart';

import 'package:bateponto_app/components/position.dart';
import 'package:geolocator/geolocator.dart';

import 'package:localstorage/localstorage.dart';

import 'package:bateponto_app/Controle/dadosPonto.dart';

import 'package:http/http.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:bateponto_app/Controle/dadosPonto.dart';
import 'package:bateponto_app/Controle/dadosIntervalo.dart';

//import 'package:localstorage/localstorage.dart';

class BtnIniciar extends StatefulWidget {
  BtnIniciar(
      {Key? key,
      required this.token,
      required this.showbtnPonto,
      required this.ativaIntervaloAbrir,
      required this.desativaIntervaloAbrir,
      required this.ativaIntervaloFechar,
      required this.desativaIntervaloFechar,
      required this.ativaPontoFechar,
      required this.desativaPontoAbrir,
      required this.desativaIntervalos,
      required this.dadosIntervalo,
      required this.refresh})
      : super(key: key);

  String token;
  bool showbtnPonto;
  Function ativaIntervaloAbrir;
  Function desativaIntervaloAbrir;
  Function ativaIntervaloFechar;
  Function desativaIntervaloFechar;
  Function ativaPontoFechar;
  Function desativaPontoAbrir;
  Function desativaIntervalos;
  DadosIntervalo dadosIntervalo;
  Function refresh;

  @override
  State<BtnIniciar> createState() => _BtnIniciarState();
}

class _BtnIniciarState extends State<BtnIniciar> {
  final RoundedLoadingButtonController _btnBaterPonto =
      RoundedLoadingButtonController();
  final LocalStorage storage = new LocalStorage('bateponto_app');
  String padraoUrl = Routes.urlRoute();
  //String token = '';
  final ponto = AllUrlsPonto().ponto;
  final urlinicio = AllUrlsPonto().ponto.open;
  /* _BtnIniciarState() {
    token = this.token;
  } */

  void _batendoPonto(RoundedLoadingButtonController controller) async {
    //print(showbtnPonto);
    var url = Uri.parse(padraoUrl + urlinicio);
    Position position = await DeterminePosition.determinePosition();
    /* print(widget.token);
    return; */
    try {
      final response = await post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(<String, String>{
          'lat': position.latitude.toString(),
          'lng': position.longitude.toString(),
        }),
      ).timeout(Duration(seconds: 10));
      controller.reset();
      final statusCode = response.statusCode;

      /* var resp = response.body; */
      /* print(resp);
      return; */
      Map<String, dynamic> data =
          new Map<String, dynamic>.from(json.decode(response.body));
      //print(data['message']);
      //print(data);

      if (statusCode != 200) {
        Fluttertoast.showToast(
            msg: data['error'],
            toastLength: Toast.LENGTH_LONG,
            fontSize: 20,
            backgroundColor: Colors.red);
        return;
      }

      setState(() {
        widget.desativaPontoAbrir();
        widget.ativaPontoFechar();
        widget.ativaIntervaloAbrir();
        widget.dadosIntervalo.funcionarioPontoInicioId = data['ponto_id'];
      });

      widget.refresh();
      Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.green);
    } catch (e) {
      controller.reset();
      Fluttertoast.showToast(
          msg: 'Erro ao realizar busca.',
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      animateOnTap: widget.showbtnPonto,
      //disabledColor: Colors.blue[100],
      color: widget.showbtnPonto ? Colors.blue[300] : Colors.blue[100],
      // successColor: Colors.amber,
      controller: _btnBaterPonto,
      onPressed: widget.showbtnPonto
          ? () => _batendoPonto(_btnBaterPonto)
          : () => Fluttertoast.showToast(
              msg: 'É necessário fechar o ponto atual para iniciar outro.',
              toastLength: Toast.LENGTH_LONG,
              fontSize: 20,
              textColor: Colors.black,
              backgroundColor: Colors.blue[300]),
      valueColor: Colors.black,

      borderRadius: 10,
      child: Text(
        'Abrir',
        style: TextStyle(
          color: widget.showbtnPonto ? Colors.black : Colors.black38,
          fontSize: 20,
        ),
      ),
    );
  }
}
