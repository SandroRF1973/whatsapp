import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/usuario.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({super.key});

  @override
  State<AbaConversas> createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  // ignore: prefer_final_fields
  List<Conversa> _listaConversas = [];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late String _idUsuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .doc(_idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });

    return stream;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser;

    _idUsuarioLogado = usuarioLogado!.uid;

    _adicionarListenerConversas();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.close();
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(children: const [
                Text("Carregando conversas"),
                CircularProgressIndicator()
              ]),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Text("Erro ao carregar os dados!");
            } else {
              QuerySnapshot? querySnapshot = snapshot.data;

              // ignore: prefer_is_empty
              if (querySnapshot!.docs.length == 0) {
                return const Center(
                  child: Text(
                    "Você não tem mensagem :( ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _listaConversas.length,
                itemBuilder: (context, indice) {
                  // Conversa conversa = _listaConversas[indice];
                  List<DocumentSnapshot> conversas =
                      querySnapshot.docs.toList();
                  DocumentSnapshot item = conversas[indice];

                  String urlImagem = item["caminhoFoto"];
                  String tipo = item["tipoMensagem"];
                  String mensagem = item["mensagem"];
                  String nome = item["nome"];
                  String idDestinatario = item["idDestinatario"];

                  // ignore: avoid_print
                  print("Nome: $nome");

                  Usuario usuario = Usuario();
                  usuario.nome = nome;
                  usuario.urlImagem = urlImagem;
                  usuario.idUsuario = idDestinatario;

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/mensagens",
                          arguments: usuario);
                    },
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          // ignore: unnecessary_null_comparison
                          urlImagem != null ? NetworkImage(urlImagem) : null,
                    ),
                    title: Text(nome,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(tipo == "texto" ? mensagem : "Imagem...",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  );
                },
              );
            }
        }
      },
    );
  }
}
