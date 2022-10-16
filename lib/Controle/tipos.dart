class Tipos {
  final String _open;
  final String _openText;
  final String _close;
  final String _closeText;
  String _textoAtual;
  String _urlAtual;
  Tipos(this._open, this._openText, this._close, this._closeText,
      this._urlAtual, this._textoAtual);

  String get open {
    return _open;
  }

  String get openText {
    return _openText;
  }

  String get close {
    return _close;
  }

  String get closeText {
    return _closeText;
  }

  String get urlAtual {
    return _urlAtual;
  }

  String get textoAtual {
    return _textoAtual;
  }

  set urlAtual(urlAtual) {
    _urlAtual = urlAtual;
  }

  set textoAtual(textoAtual) {
    _textoAtual = textoAtual;
  }

  void fechar() {
    textoAtual = closeText;
    urlAtual = close;
  }

  void abrir() {
    textoAtual = openText;
    urlAtual = open;
  }

  @override
  String toString() {
    return '{open: $open, openText: $openText, close: $close, closeText: $closeText, urlAtual:$urlAtual textoAtual: $textoAtual}';
  }
}
