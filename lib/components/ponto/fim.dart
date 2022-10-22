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

class BtnFim extends StatefulWidget {
  BtnFim(
      {Key? key,
      required this.token,
      required this.showbtnPonto,
      required this.ativaIntervaloAbrir,
      required this.desativaIntervaloAbrir,
      required this.ativaIntervaloFechar,
      required this.desativaIntervaloFechar,
      required this.ativaPontoAbrir,
      required this.DesativaPontoFechar,
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
  Function ativaPontoAbrir;
  Function DesativaPontoFechar;
  Function desativaIntervalos;
  DadosIntervalo dadosIntervalo;
  Function refresh;

  @override
  State<BtnFim> createState() => _BtnFimState();
}

class _BtnFimState extends State<BtnFim> {
  final LocalStorage storage = new LocalStorage('bateponto_app');
  String padraoUrl = Routes.urlRoute();
  final ponto = AllUrlsPonto().ponto;
  final urlfim = AllUrlsPonto().ponto.close;

  final RoundedLoadingButtonController _btnBaterPonto =
      RoundedLoadingButtonController();

  void _batendoPonto(RoundedLoadingButtonController controller) async {
    //print(showbtnPonto);
    var url = Uri.parse(padraoUrl + urlfim);
    Position position = await DeterminePosition.determinePosition();
    //print(position);
    //return;
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
      //response = jsonDecode(response);
      Map<String, dynamic> data =
          new Map<String, dynamic>.from(json.decode(response.body));
      //print(data['message']);
      if (statusCode != 200) {
        Fluttertoast.showToast(
            msg: data['error'],
            toastLength: Toast.LENGTH_LONG,
            fontSize: 20,
            backgroundColor: Colors.red);
        return;
      }

      setState(() {
        widget.ativaPontoAbrir();
        widget.DesativaPontoFechar();
        widget.desativaIntervalos();
        widget.dadosIntervalo.funcionarioPontoInicioId = null;
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
              msg: 'É necessário iniciar um ponto para fecha-lo.',
              toastLength: Toast.LENGTH_LONG,
              fontSize: 20,
              textColor: Colors.black,
              backgroundColor: Colors.blue[300]),
      valueColor: Colors.black,

      borderRadius: 10,
      child: Text(
        'Fechar',
        style: TextStyle(
          color: widget.showbtnPonto ? Colors.black : Colors.black38,
          fontSize: 20,
        ),
      ),
    );
  }
}
