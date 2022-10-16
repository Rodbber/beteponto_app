import 'package:flutter/material.dart';

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

// infinity scroll
//import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
//import 'package:bateponto_app/character_summary.dart';
//import 'package:bateponto_app/remote_api.dart';

import 'package:bateponto_app/Controle/dadosPonto.dart';
import 'package:bateponto_app/Controle/dadosIntervalo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalStorage storage = new LocalStorage('bateponto_app');

  var _pontoAberto;

  var padraoUrl = "http://192.168.0.3:8000/api";
  //var padraoUrl = "https://mr-ponto.herokuapp.com/api";
  var logout;

  //final AllUrlsPonto allUrlsPonto = AllUrlsPonto();
  final ponto = AllUrlsPonto().ponto;
  final intervalo = AllUrlsPonto().intervalo;
  String urlPonto = '';
  String tituloBtnPonto = '';
  String urlIntervalo = '';
  String tituloBtnIntervalo = '';

  var pontoAbertoAs = null;
  var dadosIntervalo;
  List historico = [];
  var funcao;
  String? token;
  bool showbtnIntervalo = false;
  bool showbtnPonto = false;
  bool maisDados = true;
  bool isLoading = false;
  String historicoRoute = '/funcionario/ponto/historico';

  alteraStateBtns() {
    setState(() {
      urlPonto = ponto.urlAtual;
      tituloBtnPonto = ponto.textoAtual;
      urlIntervalo = intervalo.urlAtual;
      tituloBtnIntervalo = intervalo.textoAtual;
    });
  }

  _HomePageState() {
    var storageJson = storage.getItem('@FuncionarioToken');

    var storageDecode = jsonDecode(storageJson);

    token = storageDecode['token'];

    _pontoAberto = null;
    logout = padraoUrl + "/funcionario/logout";
    /* print(allUrlsPonto.ponto);
    return; */

    urlPonto = ponto.urlAtual;
    tituloBtnPonto = ponto.textoAtual;

    urlIntervalo = intervalo.urlAtual;
    tituloBtnIntervalo = intervalo.textoAtual;

    showbtnIntervalo = false;

    dadosIntervalo = {};

    //historico = [];

    funcao = null;

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
                //funcao = obj['funcoes'][0];
                //print(funcao);

              }
              //print(obj['ponto']);
              if (obj['intervalos'].length != 0) {
                var intervalo0 = obj['intervalos'][0];
                dadosIntervalo = DadosIntervalo(intervalo0['id'], 0);
              }

              if (obj['ponto'] != null) {
                dadosIntervalo.funcionarioPontoInicioId = obj['ponto']['id'];
                //print(obj['ponto']["funcionario_ponto_final"]);
                if (obj['ponto']["funcionario_ponto_final"] == null) {
                  ponto.fechar();
                  alteraStateBtns();
                  /* urlPonto = allUrlsPonto.ponto.urlPontos?.close;
                  tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.closeText; */

                  // if (obj['funcoes'].length != 0) {
                  //   dadosIntervalo.funcionarioPontoInicioId =
                  //       obj['ponto']['id'];
                  //   showbtnIntervalo = true;
                  //   //funcao = obj['funcoes'][0];
                  //   //print(showbtnIntervalo);
                  // }
                  if (obj['ponto']["func_intervalo_inicio"].length != 0) {
                    var dadosIntervalos = obj['ponto']["func_intervalo_inicio"];
                    for (final i in dadosIntervalos) {
                      //print(i);
                      if (i['func_intervalo_fim'] == null) {
                        intervalo.fechar();
                        alteraStateBtns();
                        /* urlIntervalo =
                            allUrlsPonto.intervalo.urlIntervalos?.close;
                        tituloBtnIntervalo =
                            allUrlsPonto.intervalo.urlIntervalos?.closeText; */
                        dadosIntervalo.funcIntervaloInicioId = i['id'];
                        showbtnPonto = false;
                        //print('caiu aqui');
                      }
                    }
                  }
                  showbtnIntervalo = true;

                  //print(dadosIntervalo.toString());
                }
              }

              if (dadosIntervalo != {} &&
                  dadosIntervalo.funcIntervaloInicioId == null) {
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
    //refresh();
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

  final RoundedLoadingButtonController _btnBaterPonto =
      RoundedLoadingButtonController();

  void _batendoPonto(RoundedLoadingButtonController controller) async {
    var url = Uri.parse(padraoUrl + urlPonto);
    Position position = await _determinePosition();
    //print(position);
    //return;
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
          ponto.fechar();
          alteraStateBtns();
          showbtnIntervalo = true;
          dadosIntervalo.funcionarioPontoInicioId = data['ponto_id'];
        } else {
          ponto.abrir();
          showbtnIntervalo = false;
          dadosIntervalo.funcionarioPontoInicioId = null;
        }
      });
      refresh();

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

    if (dadosIntervalo.funcIntervaloInicioId != null) {
      data['funcionario_ponto_inicio_id'] =
          dadosIntervalo.funcionarioPontoInicioId;
      data['funcionario_pausa_id'] = dadosIntervalo.funcionarioPausaId;
    } else {
      data['func_intervalo_inicio_id'] = dadosIntervalo.funcIntervaloInicioId;
    }

    Position position = await _determinePosition();
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
      //print(dataResponse);
      setState(() {
        if (dataResponse['message'] == 'Intervalo iniciado.') {
          intervalo.fechar();
          alteraStateBtns();
          /* urlIntervalo = allUrlsPonto.intervalo.urlIntervalos?.close;
          tituloBtnIntervalo = allUrlsPonto.intervalo.urlIntervalos?.closeText; */
          dadosIntervalo.funcIntervaloInicioId = dataResponse['intervalo_id'];
          showbtnPonto = false;
        } else {
          /* urlIntervalo = allUrlsPonto.intervalo.urlIntervalos?.open;
          tituloBtnIntervalo = allUrlsPonto.intervalo.urlIntervalos?.openText; */
          intervalo.abrir();
          alteraStateBtns();
          dadosIntervalo.funcIntervaloInicioId = null;
          showbtnPonto = true;
          controller2.reset();
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
      refresh();
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
      storage.clear();
      Navigator.pop(context, '/');
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Ocorreu um erro ao tentar sair!',
          toastLength: Toast.LENGTH_LONG,
          fontSize: 20,
          backgroundColor: Colors.red);

      _getStatusPonto(padraoUrl).then((value) {
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
              dadosIntervalo = DadosIntervalo(funcao['id'], 0);
            }
            if (obj['ponto']["funcionario_ponto_final"] == null) {
              /* urlPonto = allUrlsPonto.ponto.urlPontos?.close;
              tituloBtnPonto = allUrlsPonto.ponto.urlPontos?.closeText; */
              ponto.fechar();
              alteraStateBtns();
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
                    intervalo.fechar();
                    alteraStateBtns();
                    dadosIntervalo.funcIntervaloInicioId = i['id'];
                    showbtnPonto = false;
                    //print('caiu aqui');
                  }
                }
              }

              //   //print(dadosIntervalo.toString());
              // }
              if (dadosIntervalo != {} &&
                  dadosIntervalo.funcIntervaloInicioId == null) {
                showbtnPonto = true;
              }
              //showbtnPonto = true;
            }
          });
        } catch (e) {
          print(e);
        }
      }).catchError((e) {
        /* print('caiu aqui');
        print(e); */
      }).timeout(Duration(seconds: 10));
    }
  }

  final pageSize = 10;
  final controllerList = ScrollController();

  @override
  void initState() {
    super.initState();
    buscaHistorico();
    controllerList.addListener(() {
      if (controllerList.position.maxScrollExtent == controllerList.offset) {
        buscaHistorico();
      }
    });
  }

  Future buscaHistorico() async {
    if (isLoading) return;
    isLoading = true;
    var offset = historico.length;
    //print(historico.length);
    var limit = pageSize;
    final Uri url = Uri.parse('$padraoUrl$historicoRoute?'
        'offset=$offset'
        '&limit=$limit'
        //'${_buildSearchTermQuery(searchTerm)}',
        );
    //print(url);
    try {
      final response = await get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      //print(response.statusCode);
      if (response.statusCode == 200) {
        //print(response.body);
        //final List data = json.decode(response.body);
        Map<String, dynamic> map = json.decode(response.body);
        List<dynamic> data = map["historico"];
        //print(data);
        setState(() {
          isLoading = false;
          if (data.length < limit) {
            maisDados = false;
          }
          historico.addAll(data);
        });
      }
    } catch (e) {
      print('caiu no erro');
      print(e);
    }
  }

  Future refresh() async {
    setState(() {
      isLoading = false;
      maisDados = true;
      historico.clear();
    });
    buscaHistorico();
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
          ],
        ),
      ),
    );
  }
}

Future _getStatusPonto(padraoUrl) async {
  final LocalStorage storage = new LocalStorage('bateponto_app');
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
  final LocalStorage storage = new LocalStorage('bateponto_app');
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

// antiga lista de historico
/* 
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
 */
