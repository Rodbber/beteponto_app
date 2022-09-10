import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';

import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalStorage storage = new LocalStorage('todo_app');

  var _pontoAberto;
  var padraoUrl = "http://192.168.0.5:8000/api";
  var logout;

  AllUrlsPonto allUrlsPonto = AllUrlsPonto();
  var urlPonto;
  var tituloBtnPonto;
  var urlIntervalo;
  var tituloBtnIntervalo;
  var pontoAbertoAs = null;
  var dadosIntervalo;
  bool showbtnIntervalo = false;

  _HomePageState() {
    _pontoAberto = null;
    /* urlPonto = 'teste1';
    tituloBtnPonto = 'teste2';
    urlIntervalo = 'teste3';
    tituloBtnIntervalo = 'teste4';
    print(allUrlsPonto.toString());
    logout = padraoUrl + "/funcionario/logout";
    return; */
    urlPonto = allUrlsPonto.ponto.urlPontos?.open;
    tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.openText;
    urlIntervalo = allUrlsPonto.intervalo.urlIntervalos?.open;
    tituloBtnIntervalo = allUrlsPonto.intervalo.urlIntervalos?.openText;

    showbtnIntervalo = false;

    dadosIntervalo = {};

    logout = padraoUrl + "/funcionario/logout";
    _getStatusPonto(padraoUrl)
        .then((value) {
          try {
            var response = value.body;
            if (response.isEmpty) {
              print('Resposta vazia!');
              return;
            }
            setState(() {
              _pontoAberto = response;
              //print(_pontoAberto);
              var obj = jsonDecode(response);
              //print(obj['ponto']["funcionario_ponto_final"]);
              if (obj['ponto']["funcionario_ponto_final"] == null) {
                urlPonto = allUrlsPonto.ponto.urlPontos?.close;
                tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.closeText;

                if (obj['funcoes'].length != 0) {
                  dadosIntervalo = DadosIntervalo(
                      funcionarioPausaId: obj['funcoes'][0]['id'],
                      funcIntervaloInicioId: 0,
                      funcionarioPontoInicioId: obj['ponto']['id']);
                  showbtnIntervalo = true;
                  //print(showbtnIntervalo);
                }
                //print(obj['ponto']["func_intervalo_inicio"]);
                if (obj['ponto']["func_intervalo_inicio"].length != 0) {
                  var dadosIntervalos = obj['ponto']["func_intervalo_inicio"];
                  for (final i in dadosIntervalos) {
                    //print(i);
                    if (i['func_intervalo_fim'] == null) {
                      urlIntervalo =
                          allUrlsPonto.intervalo.urlIntervalos?.close;
                      tituloBtnIntervalo =
                          allUrlsPonto.intervalo.urlIntervalos?.closeText;
                      dadosIntervalo.funcIntervaloInicioId = i['id'];
                      print('caiu aqui');
                    }
                  }
                }

                print(dadosIntervalo.toString());
              }
            });
          } catch (e) {
            print(e);
          }
        })
        .catchError((e) => print(e))
        .timeout(Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 60,
            left: 40,
            right: 40,
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.3, 1],
                    colors: [
                      //#6DD5FA
                      Color(0xFF2980B9),
                      Color(0XFF6DD5FA),
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: SizedBox.expand(
                  child: TextButton(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Sair',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    onPressed: () {
                      var storageJson = storage.getItem('@FuncionarioToken');

                      var storageDecode = jsonDecode(storageJson);

                      var token = storageDecode['token'];

                      var url = Uri.parse(logout);
                      post(
                        url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': 'Bearer $token',
                        },
                      )
                          .then((value) {
                            try {
                              var response = value.body;
                              print(response);
                              var obj = jsonDecode(response);
                              storage.setItem('@FuncionarioToken', '');
                              Navigator.pop(context, '/');
                            } catch (e) {}
                          })
                          .catchError((e) => print(e))
                          .timeout(Duration(seconds: 10));
                      print('retornando...');
                    },
                  ),
                ),
              ),
              Container(
                height: 60,
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.3, 1],
                    colors: [
                      //#E4E5E6
                      Color(0xFF2980B9),
                      Color(0XFF6DD5FA),
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: SizedBox.expand(
                  child: TextButton(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        tituloBtnPonto,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    onPressed: () {
                      var storageJson = storage.getItem('@FuncionarioToken');

                      var storageDecode = jsonDecode(storageJson);

                      var token = storageDecode['token'];
                      var url = Uri.parse(padraoUrl + urlPonto);
                      /* print('Bearer $token');
                      return; */
                      //print(url);
                      post(
                        url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': 'Bearer $token',
                        },
                      ).then((value) {
                        try {
                          var response = value.body;
                          //response = jsonDecode(response);
                          Map<String, dynamic> data =
                              new Map<String, dynamic>.from(
                                  json.decode(response));
                          //print(data['message']);

                          setState(() {
                            if (data['message'] == 'Ponto iniciado.') {
                              urlPonto = allUrlsPonto.ponto.urlPontos?.close;
                              tituloBtnPonto =
                                  allUrlsPonto.ponto.urlPontos?.closeText;
                              showbtnIntervalo = true;
                            } else {
                              urlPonto = allUrlsPonto.ponto.urlPontos?.open;
                              tituloBtnPonto =
                                  allUrlsPonto.ponto.urlPontos?.openText;
                              showbtnIntervalo = false;
                            }
                          });
                          Fluttertoast.showToast(
                              msg: data['message'],
                              toastLength: Toast.LENGTH_LONG,
                              fontSize: 20,
                              backgroundColor: Colors.green);
                          //print(response);
                        } catch (e) {
                          print(e);
                        }
                      }).catchError((e) {
                        Map<String, dynamic> data =
                            new Map<String, dynamic>.from(json.decode(e));
                        Fluttertoast.showToast(
                            msg: data['message'],
                            toastLength: Toast.LENGTH_LONG,
                            fontSize: 20,
                            backgroundColor: Colors.red);
                      }).timeout(Duration(seconds: 10));
                      /* Position position = await _determinePosition();
                        print(position); */
                    },
                  ),
                ),
              ),
              if (showbtnIntervalo)
                Container(
                  height: 60,
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 1],
                      colors: [
                        //#E4E5E6
                        Color(0xFF2980B9),
                        Color(0XFF6DD5FA),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: SizedBox.expand(
                    child: TextButton(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          tituloBtnIntervalo,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      onPressed: () {
                        var storageJson = storage.getItem('@FuncionarioToken');

                        var storageDecode = jsonDecode(storageJson);

                        var token = storageDecode['token'];
                        var url = Uri.parse(padraoUrl + urlIntervalo);
                        /* print('Bearer $token');
                      return; */
                        //print(url);
                        Map<String, dynamic> data = new Map<String, dynamic>();

                        if (dadosIntervalo.funcIntervaloInicioId == 0) {
                          data['funcionario_ponto_inicio_id'] =
                              dadosIntervalo.funcionarioPontoInicioId;
                          data['funcionario_pausa_id'] =
                              dadosIntervalo.funcionarioPausaId;
                        } else {
                          data['func_intervalo_inicio_id'] =
                              dadosIntervalo.funcIntervaloInicioId;
                        }

                        /* print(data);
                        return; */
                        post(
                          url,
                          body: jsonEncode(data),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization': 'Bearer $token',
                          },
                        ).then((value) {
                          try {
                            var response = value.body;
                            //response = jsonDecode(response);
                            Map<String, dynamic> data =
                                new Map<String, dynamic>.from(
                                    json.decode(response));
                            //print(data['message']);

                            setState(() {
                              if (data['message'] == 'Intervalo iniciado.') {
                                urlIntervalo =
                                    allUrlsPonto.intervalo.urlIntervalos?.close;
                                tituloBtnIntervalo = allUrlsPonto
                                    .intervalo.urlIntervalos?.closeText;
                                dadosIntervalo.funcIntervaloInicioId =
                                    data['intervalo_id'];
                              } else {
                                urlIntervalo =
                                    allUrlsPonto.intervalo.urlIntervalos?.open;
                                tituloBtnIntervalo = allUrlsPonto
                                    .intervalo.urlIntervalos?.openText;
                                dadosIntervalo.funcIntervaloInicioId = 0;
                              }
                            });
                            Fluttertoast.showToast(
                                msg: data['message'],
                                toastLength: Toast.LENGTH_LONG,
                                fontSize: 20,
                                backgroundColor: Colors.green);
                            //print(response);
                          } catch (e) {
                            print(e);
                          }
                        }).catchError((e) {
                          Map<String, dynamic> data =
                              new Map<String, dynamic>.from(json.decode(e));
                          Fluttertoast.showToast(
                              msg: data['message'],
                              toastLength: Toast.LENGTH_LONG,
                              fontSize: 20,
                              backgroundColor: Colors.red);
                        }).timeout(Duration(seconds: 10));
                      },
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

class Tipos {
  String? open = '';
  String openText = '';
  String close = '';
  String closeText = '';
  Tipos(String open, String openText, String close, String closeText) {
    this.open = open;
    this.openText = openText;
    this.close = close;
    this.closeText = closeText;
  }

  @override
  String toString() {
    return '{open: ${this.open}, openText: ${this.openText}, close: ${this.close}, closeText: ${this.closeText}}';
  }
}

class Ponto {
  Tipos? urlPontos;
  Ponto() {
    urlPontos = Tipos("/funcionario/ponto/inicio", "Bater ponto",
        "/funcionario/ponto/fim", "Fechar ponto");
  }
  getUrlsPonto() {
    return this.urlPontos;
  }

  @override
  String toString() {
    return '{urlPontos: ${this.urlPontos}}';
  }
}

class Intervalo {
  Tipos? urlIntervalos;
  Intervalo() {
    urlIntervalos = Tipos(
        "/funcionario/ponto/intervalo/inicio",
        "Iniciar intervalo",
        "/funcionario/ponto/intervalo/fim",
        "Finalizar intervalo");
  }
  getUrlsIntervalo() {
    return this.urlIntervalos;
  }

  @override
  String toString() {
    return '{urlIntervalos: ${this.urlIntervalos}}';
  }
}

class AllUrlsPonto {
  Ponto ponto = Ponto();
  Intervalo intervalo = Intervalo();
  AllUrlsPonto();
  @override
  String toString() {
    return '{ponto: ${this.ponto}, intervalo: ${this.intervalo}}';
  }
}

class DadosIntervalo {
  int? funcionarioPontoInicioId;
  int? funcionarioPausaId;
  int? funcIntervaloInicioId;

  DadosIntervalo(
      {this.funcionarioPontoInicioId,
      this.funcionarioPausaId,
      this.funcIntervaloInicioId});

  @override
  String toString() {
    return '{funcionarioPontoInicioId: ${this.funcionarioPontoInicioId}, funcionarioPausaId: ${this.funcionarioPausaId}, funcIntervaloInicioId: ${this.funcIntervaloInicioId}}';
  }
}

Future _getStatusPonto(padraoUrl) async {
  final LocalStorage storage = new LocalStorage('todo_app');
  var storageJson = storage.getItem('@FuncionarioToken');

  var storageDecode = jsonDecode(storageJson);

  var token = storageDecode['token'];

  var url = Uri.parse(padraoUrl + '/funcionario/verificarPonto');
  return get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
