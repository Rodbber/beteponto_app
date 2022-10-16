import 'package:bateponto_app/Controle/pontos.dart';
import 'package:bateponto_app/Controle/intervalos.dart';

class AllUrlsPonto {
  final Ponto _ponto = Ponto("/funcionario/ponto/inicio", "Bater ponto",
      "/funcionario/ponto/fim", "Fechar ponto");
  final Intervalo _intervalo = Intervalo(
      "/funcionario/ponto/intervalo/inicio",
      "Iniciar intervalo",
      "/funcionario/ponto/intervalo/fim",
      "Finalizar intervalo");
  AllUrlsPonto();

  Ponto get ponto {
    return _ponto;
  }

  Intervalo get intervalo {
    return _intervalo;
  }

  @override
  String toString() {
    return '{ponto: ${_ponto.toString()}, intervalo: ${_intervalo.toString()}}';
  }
}
