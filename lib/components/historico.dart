import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:bateponto_app/routes/routesAPIs.dart';

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
    final DateFormat dataformatter = DateFormat('EEE, dd/MM/yyyy');
    final DateFormat horaformatter = DateFormat('hh:mm:ss');
    final String dataformatted = dataformatter.format(now);
    final String horaformatted = horaformatter.format(now);
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
    // else {
    //   return Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 32),
    //     child: Center(
    //       child: maisDados ? CircularProgressIndicator() : Text(''),
    //     ),
    //   );
    // }
  }
}


/* 
{
            if (index < historico.length) {
              final data = historico[index]['created_at'];
              final DateTime now = DateTime.parse(data);
              final DateFormat formatter =
                  DateFormat('EEE, dd/MM/yyyy hh:mm:ss');
              final String formatted = formatter.format(now);
              String text = 'Ponto: inicio';
              Icon icone = new Icon(Icons.meeting_room);
              var tipo = historico[index]['tipo'];
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
              return Container(
                width: 150,
                //height: 100,
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
                  //onTap: () => print("clicado"),
                  leading: icone,
                  title: Text(text),
                  subtitle: Text(formatted),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: maisDados ? CircularProgressIndicator() : Text(''),
                ),
              );
            }
          },
 */
