class DadosIntervalo {
  int? _funcionarioPontoInicioId;
  int? _funcionarioPausaId;
  int? _funcIntervaloInicioId;

  DadosIntervalo();

  int? get funcionarioPontoInicioId {
    return _funcionarioPontoInicioId;
  }

  int? get funcionarioPausaId {
    return _funcionarioPausaId;
  }

  int? get funcIntervaloInicioId {
    return _funcIntervaloInicioId;
  }

  set funcionarioPontoInicioId(funcionarioPontoInicioId) {
    _funcionarioPontoInicioId = funcionarioPontoInicioId;
  }

  set funcionarioPausaId(funcionarioPausaId) {
    _funcionarioPausaId = funcionarioPausaId;
  }

  set funcIntervaloInicioId(funcIntervaloInicioId) {
    _funcIntervaloInicioId = funcIntervaloInicioId;
  }

  @override
  String toString() {
    return '{funcionarioPontoInicioId: $funcionarioPontoInicioId, funcionarioPausaId: $funcionarioPausaId, funcIntervaloInicioId: $funcIntervaloInicioId}';
  }
}
