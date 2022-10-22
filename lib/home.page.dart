import 'package:flutter/material.dart';

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

import 'package:bateponto_app/routes/routesAPIs.dart';

import 'package:bateponto_app/components/historico.dart';

import 'package:bateponto_app/components/position.dart';

// botao para iniciar e finalizar ponto
import 'package:bateponto_app/components/ponto/inicio.dart';
import 'package:bateponto_app/components/ponto/fim.dart';

// botao para iniciar e finalizar intervalo
import 'package:bateponto_app/components/intervalo/inicio.dart';
import 'package:bateponto_app/components/intervalo/fim.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalStorage storage = new LocalStorage('bateponto_app');

  var _pontoAberto;
  var padraoUrl = Routes.urlRoute();
  //var padraoUrl = "http://192.168.0.3:8000/api";
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
  DadosIntervalo dadosIntervalo = DadosIntervalo();
  var funcao;
  String token = '';
  bool showbtnIntervaloInicio = false;
  bool showbtnIntervaloFim = false;
  bool showbtnPontoAbrir = false;
  bool showbtnPontoFechar = false;

  // ativar e desativar ponto
  void ativaPontoAbrir() {
    showbtnPontoAbrir = true;
  }

  void desativaPontoAbrir() {
    showbtnPontoAbrir = false;
  }

  void ativaPontoFechar() {
    showbtnPontoFechar = true;
  }

  void desativaPontoFechar() {
    showbtnPontoFechar = false;
  }

  void desativaPontos() {
    desativaPontoAbrir();
    desativaPontoFechar();
  }

  // ativar e desativar intervalo
  void ativaIntervaloInicio() {
    showbtnIntervaloInicio = true;
  }

  void desativaIntervaloInicio() {
    showbtnIntervaloInicio = false;
  }

  void ativaIntervaloFim() {
    showbtnIntervaloFim = true;
  }

  void desativaIntervaloFim() {
    showbtnIntervaloFim = false;
  }

  void desativaIntervalos() {
    desativaIntervaloInicio();
    desativaIntervaloFim();
  }

  // historico
  final pageSize = 10;
  bool maisDados = true;
  bool isLoading = false;
  List historico = [];

  Future<void> refresh() async {
    //print('recarregando');
    setState(() {
      isLoading = false;
      maisDados = true;
      historico.clear();
    });
    buscaHistorico();
  }

  Future buscaHistorico() async {
    if (isLoading) return;
    isLoading = true;
    var offset = historico.length;
    //print(historico.length);
    String historicoUrl = Routes.historico();
    var limit = pageSize;
    final Uri url = Uri.parse("$historicoUrl?offset=$offset&limit=$limit"
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
      print(response.statusCode);
      if (response.statusCode == 200) {
        //print(response.body);
        //final List data = json.decode(response.body);
        Map<String, dynamic> map = json.decode(response.body);
        List<dynamic> data = map["historico"];
        //print(data);
        if (mounted) {
          setState(() {
            isLoading = false;
            if (data.length < limit) {
              maisDados = false;
            }
            historico.addAll(data);
            //items = historico.map((e) => CardItem(urlImage: , title: title, subtitle: subtitle))
          });
        }
      } /* else {
        maisDados = false;
        isLoading = false;
      } */
    } catch (e) {
      maisDados = false;
      print('caiu no erro');
      print(e);
    }
  }

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

    //showbtnIntervalo = false;

    //dadosIntervalo = {};

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
                //dadosIntervalo.funcionarioPontoInicioId = null;
                dadosIntervalo.funcionarioPausaId = intervalo0['id'];
              }

              if (obj['ponto'] != null) {
                dadosIntervalo.funcionarioPontoInicioId = obj['ponto']['id'];
                //print(obj['ponto']["funcionario_ponto_final"]);
                if (obj['ponto']["funcionario_ponto_final"] == null) {
                  desativaPontoAbrir();
                  ativaPontoFechar();
                  ativaIntervaloInicio();
                  //ponto.fechar();

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
                    //print(obj['ponto']["func_intervalo_inicio"]);
                    for (final i in dadosIntervalos) {
                      //print(i);
                      if (i['func_intervalo_fim'] == null) {
                        desativaIntervalos();
                        ativaIntervaloFim();
                        dadosIntervalo.funcIntervaloInicioId = i['id'];
                        desativaPontos();
                      }
                    }
                  }
                  //showbtnIntervalo = true;
                  //ativaIntervaloInicio();

                  //print(dadosIntervalo.toString());
                }
              }

              if (!showbtnPontoFechar &&
                  dadosIntervalo.funcIntervaloInicioId == null) {
                ativaPontoAbrir();
              }
            });
          } catch (e) {
            print(e);
          }
        })
        .catchError((e) => print(e))
        .timeout(Duration(seconds: 10));
    //refresh();
  }

  final RoundedLoadingButtonController _btnSair =
      RoundedLoadingButtonController();

  void _sair(RoundedLoadingButtonController controller) async {
    setState(() {
      desativaIntervalos();
      desativaPontos();
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
              //dadosIntervalo = DadosIntervalo(funcao['id'], 0);
              dadosIntervalo.funcionarioPausaId = funcao['id'];
            }
            if (obj['ponto']["funcionario_ponto_final"] == null) {
              desativaPontoAbrir();
              ativaPontoFechar();
              if (obj['funcoes'].length != 0) {
                dadosIntervalo.funcionarioPontoInicioId = obj['ponto']['id'];
                ativaIntervaloInicio();
                //funcao = obj['funcoes'][0];
                //print(showbtnIntervalo);
              }

              //print(obj['ponto']["func_intervalo_inicio"]);
              if (obj['ponto']["func_intervalo_inicio"].length != 0) {
                var dadosIntervalos = obj['ponto']["func_intervalo_inicio"];
                for (final i in dadosIntervalos) {
                  //print(i);
                  if (i['func_intervalo_fim'] == null) {
                    dadosIntervalo.funcIntervaloInicioId = i['id'];
                    desativaIntervaloInicio();
                    ativaIntervaloFim();
                    desativaPontos();
                    //print('caiu aqui');
                  }
                }
              }

              //   //print(dadosIntervalo.toString());
              // }
              if (dadosIntervalo != {} &&
                  dadosIntervalo.funcIntervaloInicioId == null) {
                ativaPontoAbrir();
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

  /* Future refresh() async {
    setState(() {
      isLoading = false;
      maisDados = true;
      historico.clear();
    });
    buscaHistorico();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 60,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Container(
              //height: 60,
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
            Container(
              height: 150,
              child: Historico(
                buscaHistorico: buscaHistorico,
                maisDados: maisDados,
                isLoading: isLoading,
                historico: historico,
                refresh: refresh,
              ),
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text('Controle de ponto',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                //height: 60,
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
                                child: BtnIniciar(
                                  token: token,
                                  showbtnPonto: showbtnPontoAbrir,
                                  ativaIntervaloAbrir: ativaIntervaloInicio,
                                  desativaIntervaloAbrir:
                                      desativaIntervaloInicio,
                                  ativaIntervaloFechar: ativaIntervaloFim,
                                  desativaIntervaloFechar: desativaIntervaloFim,
                                  desativaPontoAbrir: desativaPontoAbrir,
                                  ativaPontoFechar: ativaPontoFechar,
                                  desativaIntervalos: desativaIntervalos,
                                  dadosIntervalo: dadosIntervalo,
                                  refresh: refresh,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                //height: 60,
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
                                child: BtnFim(
                                  token: token,
                                  showbtnPonto: showbtnPontoFechar,
                                  ativaIntervaloAbrir: ativaIntervaloInicio,
                                  desativaIntervaloAbrir:
                                      desativaIntervaloInicio,
                                  ativaIntervaloFechar: ativaIntervaloFim,
                                  desativaIntervaloFechar: desativaIntervaloFim,
                                  DesativaPontoFechar: desativaPontoFechar,
                                  ativaPontoAbrir: ativaPontoAbrir,
                                  desativaIntervalos: desativaIntervalos,
                                  dadosIntervalo: dadosIntervalo,
                                  refresh: refresh,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Controle de intervalo',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                //height: 60,
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: BtnInicioIntervalo(
                                  token: token,
                                  showBtnIntervalo: showbtnIntervaloInicio,
                                  ativaPontoAbrir: ativaPontoAbrir,
                                  desativaPontoAbrir: desativaPontoAbrir,
                                  ativaPontoFechar: ativaPontoFechar,
                                  desativaPontoFechar: desativaPontoFechar,
                                  desativaIntervaloAbrir:
                                      desativaIntervaloInicio,
                                  ativaIntervaloFechar: ativaIntervaloFim,
                                  desativaPontos: desativaPontos,
                                  dadosIntervalo: dadosIntervalo,
                                  refresh: refresh,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                //height: 60,
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: BtnFimIntervalo(
                                  token: token,
                                  showBtnIntervalo: showbtnIntervaloFim,
                                  ativaPontoAbrir: ativaPontoAbrir,
                                  desativaPontoAbrir: desativaPontoAbrir,
                                  ativaPontoFechar: ativaPontoFechar,
                                  desativaPontoFechar: desativaPontoFechar,
                                  desativaIntervaloFechar: desativaIntervaloFim,
                                  ativaIntervaloAbrir: ativaIntervaloInicio,
                                  desativaPontos: desativaPontos,
                                  dadosIntervalo: dadosIntervalo,
                                  refresh: refresh,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
