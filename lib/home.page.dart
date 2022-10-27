import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'dart:async';

// intervalo
import 'package:bateponto_app/Controle/dadosIntervalo.dart';

// routes
import 'package:bateponto_app/routes/routesAPIs.dart';

// historico
import 'package:bateponto_app/components/historico.dart';

// botao para iniciar e finalizar ponto
import 'package:bateponto_app/components/ponto/inicio.dart';
import 'package:bateponto_app/components/ponto/fim.dart';

// botao para iniciar e finalizar intervalo
import 'package:bateponto_app/components/intervalo/inicio.dart';
import 'package:bateponto_app/components/intervalo/fim.dart';

// botao sair
import 'package:bateponto_app/components/logout.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // variaveis storage
  final LocalStorage storage = LocalStorage('bateponto_app');
  String token = '';

  var padraoUrl = Routes.urlRoute();

  // variaveis ponto
  bool showbtnPontoAbrir = false;
  bool showbtnPontoFechar = false;

  // variaveis intervalo
  bool showbtnIntervaloInicio = false;
  bool showbtnIntervaloFim = false;
  DadosIntervalo dadosIntervalo = DadosIntervalo();

  // input justificar
  final TextEditingController _justificaController = TextEditingController();

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
      //print(response.statusCode);
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

  verificaStatusPonto() {
    _getStatusPonto(padraoUrl, token)
        .then((value) {
          try {
            var response = value.body;
            if (response.isEmpty) {
              print('Resposta vazia!');
              return;
            }
            setState(() {
              var obj = jsonDecode(response);

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
        .timeout(const Duration(seconds: 10));
  }

  _HomePageState() {
    var storageJson = storage.getItem('@FuncionarioToken');

    var storageDecode = jsonDecode(storageJson);

    token = storageDecode['token'];

    verificaStatusPonto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black38,
        //alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(
          top: 40,
          left: 20,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //height: 60,
              //margin: const EdgeInsets.only(top: 5),
              width: 80,
              padding: const EdgeInsets.only(left: 7),

              alignment: Alignment.centerLeft,
              child: BtnSair(
                  storage: storage,
                  token: token,
                  verificaStatusPonto: verificaStatusPonto,
                  desativaIntervalos: desativaIntervalos,
                  desativaPontos: desativaPontos),
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
            const SizedBox(
              height: 5,
            ),
            Flexible(
              flex: 1,
              child: Container(
                child: ListView(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          const Center(
                            child: Text('Controle de ponto',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  //height: 60,
                                  //margin: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.centerLeft,
                                  child: BtnIniciar(
                                    token: token,
                                    showbtnPonto: showbtnPontoAbrir,
                                    ativaIntervaloAbrir: ativaIntervaloInicio,
                                    desativaIntervaloAbrir:
                                        desativaIntervaloInicio,
                                    ativaIntervaloFechar: ativaIntervaloFim,
                                    desativaIntervaloFechar:
                                        desativaIntervaloFim,
                                    desativaPontoAbrir: desativaPontoAbrir,
                                    ativaPontoFechar: ativaPontoFechar,
                                    desativaIntervalos: desativaIntervalos,
                                    dadosIntervalo: dadosIntervalo,
                                    refresh: refresh,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  //height: 60,
                                  //margin: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.centerLeft,
                                  child: BtnFim(
                                    token: token,
                                    showbtnPonto: showbtnPontoFechar,
                                    ativaIntervaloAbrir: ativaIntervaloInicio,
                                    desativaIntervaloAbrir:
                                        desativaIntervaloInicio,
                                    ativaIntervaloFechar: ativaIntervaloFim,
                                    desativaIntervaloFechar:
                                        desativaIntervaloFim,
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
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      //margin: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              'Controle de intervalo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  //height: 60,
                                  //margin: const EdgeInsets.only(top: 10),
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
                              const SizedBox(
                                width: 12,
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  //height: 60,
                                  //margin: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.centerLeft,
                                  child: BtnFimIntervalo(
                                    token: token,
                                    showBtnIntervalo: showbtnIntervaloFim,
                                    ativaPontoAbrir: ativaPontoAbrir,
                                    desativaPontoAbrir: desativaPontoAbrir,
                                    ativaPontoFechar: ativaPontoFechar,
                                    desativaPontoFechar: desativaPontoFechar,
                                    desativaIntervaloFechar:
                                        desativaIntervaloFim,
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
                    /* const SizedBox(
                      height: 12,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      padding: EdgeInsets.all(2),
                      child: Center(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _justificaController,
                          decoration: InputDecoration(
                            labelText: "Justificativa",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(96, 53, 52, 52),
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ), */
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future _getStatusPonto(padraoUrl, token) async {
  var url = Uri.parse(padraoUrl + '/funcionario/verificarPonto');
  return get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
}
