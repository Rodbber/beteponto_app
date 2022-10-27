import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:bateponto_app/routes/routesAPIs.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CardItem {
  final String icone;
  final String tipo;
  final String data;

  const CardItem({
    required this.icone,
    required this.tipo,
    required this.data,
  });
}

class Historico extends StatefulWidget {
  Historico(
      {Key? key,
      required this.buscaHistorico,
      required this.maisDados,
      required this.isLoading,
      required this.historico,
      required this.refresh})
      : super(key: key);

  Function buscaHistorico;
  bool maisDados;
  bool isLoading;
  List historico;
  Function refresh;

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final LocalStorage storage = new LocalStorage('bateponto_app');
  String token = '';
  _HistoricoState() {
    var storageJson = storage.getItem('@FuncionarioToken');

    var storageDecode = jsonDecode(storageJson);

    token = storageDecode['token'];
  }

  //List<CardItem> items = [];

  final ScrollController _controllerList = ScrollController();

  @override
  void initState() {
    super.initState();
    this.widget.buscaHistorico();
    //_controllerList = ScrollController();
    _controllerList.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_controllerList.offset >= _controllerList.position.maxScrollExtent &&
        !_controllerList.position.outOfRange) {
      this.widget.buscaHistorico();
    }
    /* if (_controllerList.offset <= _controllerList.position.minScrollExtent &&
        !_controllerList.position.outOfRange) {
      print("teste2");
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      margin: EdgeInsets.only(top: 20),
      alignment: Alignment.centerLeft,
      child: RefreshIndicator(
        onRefresh: () async => this.widget.refresh,
        child: ListView.builder(
          controller: _controllerList,
          itemCount: this.widget.historico.length + 1,
          scrollDirection: Axis.horizontal,
          // separatorBuilder: (context, _) => SizedBox(
          //   width: 1,
          // ),
          itemBuilder: (context, index) =>
              buildCard(this.widget.historico, index),
        ),
      ),
    );
  }

  Widget buildCard(historico, index) {
    initializeDateFormatting('pt_BR', null);
    if (index >= historico.length) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: this.widget.maisDados ? CircularProgressIndicator() : Text(''),
        ),
      );
    }
    final item = historico[index];
    final data = item['created_at'];
    final DateTime now = DateTime.parse(data);
    final DateTime novaData = DateTime(
        now.year, now.month, now.day, now.hour - 3, now.minute, now.second);

    final DateFormat dataformatter = DateFormat('EEE, dd/MM/yyyy', 'pt_BR');
    final DateFormat horaformatter = DateFormat('HH:mm:ss');
    final String dataformatted = dataformatter.format(novaData);
    final String horaformatted = horaformatter.format(novaData);

    String text = 'Ponto: inicio';
    Icon icone = new Icon(Icons.meeting_room);
    var tipo = item['tipo'];
    if (tipo == 'ponto fim') {
      text = 'Ponto: fim';
      icone = Icon(Icons.door_back_door);
    } else if (tipo == 'intervalo inicio') {
      text = 'Intervalo: inicio';
      icone = Icon(Icons.bed);
    } else if (tipo == 'intervalo fim') {
      text = 'Intervalo: fim';
      icone = Icon(Icons.directions_walk_outlined);
    }
    return TextButton(
      onPressed: () => print('clicado'),
      style: TextButton.styleFrom(
        primary: Colors.black54,
      ),
      //style: TextStyle(color: Colors.black),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Text(text),
            Text(dataformatted),
            Text(horaformatted),
            icone,
          ],
        ),
      ),
    );
  }
}
