import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';
//import 'package:intl/date_symbol_data_http_request.dart';
//initializeDateFormatting('pt_BR', null).then(() => runMyCode());

import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalStorage storage = new LocalStorage('todo_app');

  var _pontoAberto;
  var padraoUrl = "http://192.168.0.6:8000/api";
  var logout;

  AllUrlsPonto allUrlsPonto = AllUrlsPonto();
  var urlPonto;
  var tituloBtnPonto;
  var urlIntervalo;
  var tituloBtnIntervalo;
  var pontoAbertoAs = null;
  var dadosIntervalo;
  var historico;
  var funcao;
  String? token;
  bool showbtnIntervalo = false;
  bool showbtnPonto = false;

  _HomePageState() {
    var storageJson = storage.getItem('@FuncionarioToken');

    var storageDecode = jsonDecode(storageJson);

    token = storageDecode['token'];

    _pontoAberto = null;
    urlPonto = allUrlsPonto.ponto.urlPontos?.open;
    tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.openText;
    urlIntervalo = allUrlsPonto.intervalo.urlIntervalos?.open;
    tituloBtnIntervalo = allUrlsPonto.intervalo.urlIntervalos?.openText;

    showbtnIntervalo = false;

    dadosIntervalo = {};

    historico = [];

    funcao = null;

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

              if (obj['funcoes'].length != 0) {
                funcao = obj['funcoes'][0];
                dadosIntervalo = DadosIntervalo(
                    funcionarioPausaId: funcao['id'],
                    funcIntervaloInicioId: 0,
                    funcionarioPontoInicioId: 0);
              }
              if (obj['ponto']["funcionario_ponto_final"] == null) {
                urlPonto = allUrlsPonto.ponto.urlPontos?.close;
                tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.closeText;

                if (obj['funcoes'].length != 0) {
                  dadosIntervalo.funcionarioPontoInicioId = obj['ponto']['id'];
                  showbtnIntervalo = true;
                  //funcao = obj['funcoes'][0];
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
                      showbtnPonto = false;
                      //print('caiu aqui');
                    }
                  }
                }

                //print(dadosIntervalo.toString());
              }
              if (dadosIntervalo != {} &&
                  dadosIntervalo.funcIntervaloInicioId == 0) {
                showbtnPonto = true;
              }
              //showbtnPonto = true;
            });
          } catch (e) {
            print(e);
          }
        })
        .catchError((e) => print(e))
        .timeout(Duration(seconds: 10));
    atualizaHistorico();
  }

  void atualizaHistorico() {
    _getHistoricoPontos(padraoUrl)
        .then((value) {
          var response = value.body;
          if (response.isEmpty) {
            print('Resposta vazia!');
            return;
          }

          Map<String, dynamic> obj =
              new Map<String, dynamic>.from(json.decode(response));
          //var obj = jsonDecode(response);

          //print(obj);
          setState(() {
            if (obj['historico'].length != 0) {
              historico = obj['historico'];
            }
          });
        })
        .catchError((e) => print(e))
        .timeout(Duration(seconds: 10));
  }

  final RoundedLoadingButtonController _btnController1 =
      RoundedLoadingButtonController();

  final RoundedLoadingButtonController _btnBaterPonto =
      RoundedLoadingButtonController();

  void _batendoPonto(RoundedLoadingButtonController controller) async {
    var url = Uri.parse(padraoUrl + urlPonto);
    Position position = await _determinePosition();
    /* print(position);
                      return; */
    try {
      final response = await post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
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
        if (data['message'] == 'Ponto iniciado.') {
          urlPonto = allUrlsPonto.ponto.urlPontos?.close;
          tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.closeText;
          showbtnIntervalo = true;
          //showbtnPonto = false;
          dadosIntervalo.funcionarioPontoInicioId = data['ponto_id'];
        } else {
          urlPonto = allUrlsPonto.ponto.urlPontos?.open;
          tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.openText;
          showbtnIntervalo = false;
          dadosIntervalo.funcionarioPontoInicioId = 0;
        }
      });
      atualizaHistorico();

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

  final RoundedLoadingButtonController _btnBaterPontoIntervalo =
      RoundedLoadingButtonController();

  void _batendoPontoIntervalo(RoundedLoadingButtonController controller,
      RoundedLoadingButtonController controller2) async {
    var url = Uri.parse(padraoUrl + urlIntervalo);
    Map<String, dynamic> data = new Map<String, dynamic>();
    if (dadosIntervalo.funcIntervaloInicioId == 0) {
      data['funcionario_ponto_inicio_id'] =
          dadosIntervalo.funcionarioPontoInicioId;
      data['funcionario_pausa_id'] = dadosIntervalo.funcionarioPausaId;
    } else {
      data['func_intervalo_inicio_id'] = dadosIntervalo.funcIntervaloInicioId;
    }

    Position position = await _determinePosition();
    data['lat'] = position.latitude;
    data['lng'] = position.longitude;
    /* print(data);
    return; */
    try {
      var response = await post(
        url,
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
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

      setState(() {
        if (dataResponse['message'] == 'Intervalo iniciado.') {
          urlIntervalo = allUrlsPonto.intervalo.urlIntervalos?.close;
          tituloBtnIntervalo = allUrlsPonto.intervalo.urlIntervalos?.closeText;
          dadosIntervalo.funcIntervaloInicioId = dataResponse['intervalo_id'];
          showbtnPonto = false;
        } else {
          urlIntervalo = allUrlsPonto.intervalo.urlIntervalos?.open;
          tituloBtnIntervalo = allUrlsPonto.intervalo.urlIntervalos?.openText;
          dadosIntervalo.funcIntervaloInicioId = 0;
          showbtnPonto = true;
          controller2.reset();
          /* if(controller2.currentState ){

          } */

        }
      });
      /* setState(() {
        Timer(const Duration(seconds: 5), () {
          print(showbtnPonto);
          showbtnPonto = true;
          print(showbtnPonto);
          /* setState(() {
                    showbtnPonto = true;
                  }); */
        });
      }); */
      atualizaHistorico();
      Fluttertoast.showToast(
          msg: dataResponse['message'],
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.green);
    } catch (e, stacktrace) {
      controller.reset();
      Fluttertoast.showToast(
          msg: 'Ocorreu um erro!',
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.red);
    }
  }

  final RoundedLoadingButtonController _btnSair =
      RoundedLoadingButtonController();

  void _sair(RoundedLoadingButtonController controller) async {
    setState(() {
      showbtnIntervalo = false;
      showbtnPonto = false;
    });

    var url = Uri.parse(logout);
    try {
      var response = await post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      var responseBody = response.body;
      //print(response);
      controller.reset();
      var obj = jsonDecode(responseBody);
      storage.setItem('@FuncionarioToken', '');
      Navigator.pop(context, '/');
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Ocorreu um erro ao tentar sair!',
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.red);

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

                if (obj['funcoes'].length != 0) {
                  funcao = obj['funcoes'][0];
                  dadosIntervalo = DadosIntervalo(
                      funcionarioPausaId: funcao['id'],
                      funcIntervaloInicioId: 0,
                      funcionarioPontoInicioId: 0);
                }
                if (obj['ponto']["funcionario_ponto_final"] == null) {
                  urlPonto = allUrlsPonto.ponto.urlPontos?.close;
                  tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.closeText;

                  if (obj['funcoes'].length != 0) {
                    dadosIntervalo.funcionarioPontoInicioId =
                        obj['ponto']['id'];
                    showbtnIntervalo = true;
                    //funcao = obj['funcoes'][0];
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
                        showbtnPonto = false;
                        //print('caiu aqui');
                      }
                    }
                  }

                  //print(dadosIntervalo.toString());
                }
                if (dadosIntervalo != {} &&
                    dadosIntervalo.funcIntervaloInicioId == 0) {
                  showbtnPonto = true;
                }
                //showbtnPonto = true;
              });
            } catch (e) {
              print(e);
            }
          })
          .catchError((e) => print(e))
          .timeout(Duration(seconds: 10));
    }
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
                margin: EdgeInsets.only(top: 5),
                alignment: Alignment.centerLeft,
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.topLeft,
                //     end: Alignment.bottomRight,
                //     stops: [0.3, 1],
                //     colors: [
                //       //#E4E5E6
                //       Color(0xFF2980B9),
                //       Color(0XFF6DD5FA),
                //     ],
                //   ),
                //   borderRadius: BorderRadius.all(Radius.circular(5)),
                // ),
                child: RoundedLoadingButton(
                  color: Colors.blue[300],
                  // successColor: Colors.amber,
                  controller: _btnSair,
                  onPressed: () => _sair(_btnSair),
                  valueColor: Colors.black,

                  borderRadius: 10,
                  child: Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              if (showbtnPonto)
                Container(
                  height: 60,
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  // decoration: BoxDecoration(
                  //   gradient: LinearGradient(
                  //     begin: Alignment.topLeft,
                  //     end: Alignment.bottomRight,
                  //     stops: [0.3, 1],
                  //     colors: [
                  //       //#E4E5E6
                  //       Color(0xFF2980B9),
                  //       Color(0XFF6DD5FA),
                  //     ],
                  //   ),
                  //   borderRadius: BorderRadius.all(Radius.circular(5)),
                  // ),
                  child: RoundedLoadingButton(
                    color: Colors.blue[300],
                    // successColor: Colors.amber,
                    controller: _btnBaterPonto,
                    onPressed: () => _batendoPonto(_btnBaterPonto),
                    valueColor: Colors.black,

                    borderRadius: 10,
                    child: Text(
                      tituloBtnPonto,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              if (showbtnIntervalo)
                Container(
                  height: 60,
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  child: RoundedLoadingButton(
                    color: Colors.blue[300],
                    // successColor: Colors.amber,
                    controller: _btnBaterPontoIntervalo,
                    onPressed: () => _batendoPontoIntervalo(
                        _btnBaterPontoIntervalo, _btnBaterPonto),
                    valueColor: Colors.black,

                    borderRadius: 10,
                    child: Text(
                      tituloBtnIntervalo,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(bottom: 20),
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.centerLeft,
                  child: ListView.builder(
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      //print(historico[index]);
                      var data = historico[index]['created_at'];
                      final DateTime now = DateTime.parse(data);
                      final DateFormat formatter =
                          DateFormat('EEE, dd/MM/yyyy hh:mm:ss');
                      final String formatted = formatter.format(now);
                      String text = 'Bateu ponto';
                      Icon icone = new Icon(Icons.meeting_room);
                      var tipo = historico[index]['tipo'];
                      if (tipo == 'ponto fim') {
                        text = 'Fechou ponto';
                        icone = Icon(Icons.door_back_door);
                      } else if (tipo == 'intervalo inicio') {
                        text = 'Saiu para intervalo';
                        icone = Icon(Icons.bed);
                      } else if (tipo == 'intervalo fim') {
                        text = 'Voltou do intervalo';
                        icone = Icon(Icons.directions_walk_outlined);
                      }

                      //print(formatted);

                      //var data = DateTime(historico[int.parse(index)]['created_at']);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF000000),
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: ListTile(
                          leading: icone,
                          title: Text(text),
                          subtitle: Text(formatted),
                        ),
                      );
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

Future _getHistoricoPontos(padraoUrl) async {
  final LocalStorage storage = new LocalStorage('todo_app');
  var storageJson = storage.getItem('@FuncionarioToken');

  var storageDecode = jsonDecode(storageJson);

  var token = storageDecode['token'];

  var url = Uri.parse(padraoUrl + '/funcionario/ponto/historico');
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
