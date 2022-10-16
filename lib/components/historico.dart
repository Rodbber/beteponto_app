import 'package:flutter/material.dart';

class Historico extends StatefulWidget {
  const Historico({Key? key}) : super(key: key);

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  List historico = [];

// Future refresh() async {
//     setState(() {
//       isLoading = false;
//       maisDados = true;
//       historico.clear();
//     });
//     buscaHistorico();
//   }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Flexible(
    //           flex: 1,
    //           child: Container(
    //             padding: EdgeInsets.only(bottom: 20),
    //             margin: EdgeInsets.only(top: 20),
    //             alignment: Alignment.centerLeft,
    //             child: RefreshIndicator(
    //               onRefresh: refresh,
    //               child: ListView.builder(
    //                 controller: controllerList,
    //                 itemCount: historico.length + 1,
    //                 //scrollDirection: Axis.horizontal,
    //                 itemBuilder: (context, index) {
    //                   if (index < historico.length) {
    //                     final data = historico[index]['created_at'];
    //                     final DateTime now = DateTime.parse(data);
    //                     final DateFormat formatter =
    //                         DateFormat('EEE, dd/MM/yyyy hh:mm:ss');
    //                     final String formatted = formatter.format(now);
    //                     String text = 'Bateu ponto';
    //                     Icon icone = new Icon(Icons.meeting_room);
    //                     var tipo = historico[index]['tipo'];
    //                     if (tipo == 'ponto fim') {
    //                       text = 'Fechou ponto';
    //                       icone = Icon(Icons.door_back_door);
    //                     } else if (tipo == 'intervalo inicio') {
    //                       text = 'Saiu para intervalo';
    //                       icone = Icon(Icons.bed);
    //                     } else if (tipo == 'intervalo fim') {
    //                       text = 'Voltou do intervalo';
    //                       icone = Icon(Icons.directions_walk_outlined);
    //                     }
    //                     return Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.white,
    //                         border: Border.all(
    //                           color: const Color(0xFF000000),
    //                           width: 1.0,
    //                           style: BorderStyle.solid,
    //                         ),
    //                         borderRadius: BorderRadius.all(
    //                           Radius.circular(10),
    //                         ),
    //                       ),
    //                       child: ListTile(
    //                         leading: icone,
    //                         title: Text(text),
    //                         subtitle: Text(formatted),
    //                       ),
    //                     );
    //                   } else {
    //                     return Padding(
    //                       padding: EdgeInsets.symmetric(vertical: 32),
    //                       child: Center(
    //                         child: maisDados
    //                             ? CircularProgressIndicator()
    //                             : Text(''),
    //                       ),
    //                     );
    //                   }
    //                 },
    //               ),
    //             ),
    //           ),
    //         );
  }
}
