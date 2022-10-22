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

class BtnFimIntervalo extends StatefulWidget {
  BtnFimIntervalo(
      {Key? key,
      required this.token,
      required this.showBtnIntervalo,
      required this.ativaPontoAbrir,
      required this.desativaPontoAbrir,
      required this.ativaPontoFechar,
      required this.desativaPontoFechar,
      required this.ativaIntervaloAbrir,
      required this.desativaIntervaloFechar,
      required this.desativaPontos,
      required this.dadosIntervalo,
      required this.refresh})
      : super(key: key);

  String token;
  bool showBtnIntervalo;
  Function ativaPontoAbrir;
  Function desativaPontoAbrir;
  Function ativaPontoFechar;
  Function desativaPontoFechar;
  Function ativaIntervaloAbrir;
  Function desativaIntervaloFechar;
  Function desativaPontos;
  DadosIntervalo dadosIntervalo;
  Function refresh;

  @override
  State<BtnFimIntervalo> createState() => _BtnFimIntervalorState();
}

class _BtnFimIntervalorState extends State<BtnFimIntervalo> {
  final LocalStorage storage = new LocalStorage('bateponto_app');
  String padraoUrl = Routes.urlRoute();
  //final ponto = AllUrlsPonto().ponto;
  final urlfim = AllUrlsPonto().intervalo.close;

  final RoundedLoadingButtonController _btnBaterPontoIntervalo =
      RoundedLoadingButtonController();

  void _batendoPontoIntervalo(RoundedLoadingButtonController controller) async {
    var url = Uri.parse(padraoUrl + urlfim);
    //print(url);
    Map<String, dynamic> data = new Map<String, dynamic>();
    //print(dadosIntervalo);
    /* if (widget.dadosIntervalo.funcIntervaloInicioId == null) {
      data['funcionario_ponto_inicio_id'] =
          widget.dadosIntervalo.funcionarioPontoInicioId;
      data['funcionario_pausa_id'] = widget.dadosIntervalo.funcionarioPausaId;
    } else { */
    data['func_intervalo_inicio_id'] =
        widget.dadosIntervalo.funcIntervaloInicioId;
    /* } */

    Position position = await DeterminePosition.determinePosition();
    data['lat'] = position.latitude.toString();
    data['lng'] = position.longitude.toString();
    /* print(data);
    controller.reset();
    return; */

    try {
      var response = await post(
        url,
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(Duration(seconds: 10));
      controller.reset();
      final statusCode = response.statusCode;
      var responseBody = response.body;

      /* print(responseBody);
      controller.reset();
      return; */

      //response = jsonDecode(response);
      Map<String, dynamic> dataResponse =
          new Map<String, dynamic>.from(json.decode(responseBody));

      if (statusCode != 200) {
        Fluttertoast.showToast(
            msg: dataResponse['error'],
            toastLength: Toast.LENGTH_LONG,
            fontSize: 20,
            backgroundColor: Colors.red);
        return;
      }
      //print(dataResponse);
      setState(() {
        widget.desativaIntervaloFechar();
        widget.ativaIntervaloAbrir();
        widget.dadosIntervalo.funcIntervaloInicioId = null;
        widget.ativaPontoFechar();
      });
      widget.refresh();
      Fluttertoast.showToast(
          msg: dataResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.green);
    } catch (e) {
      controller.reset();
      print(e);
      Fluttertoast.showToast(
          msg: 'Ocorreu um erro!',
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      animateOnTap: widget.showBtnIntervalo,
      //disabledColor: Colors.blue[100],
      color: widget.showBtnIntervalo ? Colors.blue[300] : Colors.blue[100],
      // successColor: Colors.amber,
      controller: _btnBaterPontoIntervalo,

      onPressed: widget.showBtnIntervalo
          ? () => _batendoPontoIntervalo(_btnBaterPontoIntervalo)
          : () => Fluttertoast.showToast(
              msg: 'é necessário iniciar um intervalo para termina-lo.',
              toastLength: Toast.LENGTH_LONG,
              fontSize: 20,
              textColor: Colors.black,
              backgroundColor: Colors.blue[300]),
      valueColor: Colors.black,

      borderRadius: 10,
      child: Text(
        'Fechar',
        style: TextStyle(
          color: widget.showBtnIntervalo ? Colors.black : Colors.black38,
          fontSize: 20,
        ),
      ),
    );
  }
}
