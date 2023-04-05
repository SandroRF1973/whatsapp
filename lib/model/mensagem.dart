class Mensagem {
  String? _idUsuario;
  String? _mensagem;
  String? _urlImagem;
  //Define o tipo da mensagem, que pode ser "texto" ou "imagem"
  String? _tipo;

  Mensagem();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": idUsuario,
      "mensagem": mensagem,
      "urlImagem": urlImagem,
      "tipo": tipo
    };

    return map;
  }

  String get idUsuario => _idUsuario ?? "";

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get mensagem => _mensagem ?? "";

  set mensagem(String value) {
    _mensagem = value;
  }

  String get urlImagem => _urlImagem ?? "";

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get tipo => _tipo ?? "";

  set tipo(String value) {
    _tipo = value;
  }
}