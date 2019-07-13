import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _preco =  '0.00';
  String _dataAtualizacao = '';

  @override
  void initState() {
    super.initState();
    _recuperarDados();
  }

  Future _salvar() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("preco", _preco);
    sp.setString("data", _dataAtualizacao);
  }

  Future _recuperarDados() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
     _preco = (sp.getString('preco') ?? "00,00");
     _dataAtualizacao = (sp.getString('data') ?? "00/00/000 ás 00/00");
    });
  }

  void _atualizarData(){
   setState(() {
    _dataAtualizacao = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy, ' ás ', HH, ':', nn, ":", ss]).toString();
   });
  }

  void _atualizarPreco() async{
    var url = "https://blockchain.info/ticker";
    http.Response response = await http.get(url);
    Map<String, dynamic> retorno = json.decode(response.body);
    setState(() {
      String valor = retorno["BRL"]["buy"] .toString();
      var controller = new MoneyMaskedTextController(leftSymbol: 'R\$ ');
      controller.updateValue(double.parse(valor));
      _preco =  controller.text;
     _salvar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar : buildAppBar(),
     body: buildBody(_preco),
     bottomSheet: buildFooter(_dataAtualizacao),
    );
  }
  Widget buildAppBar(){
  return AppBar(
    title: Text('Meu Bitcoin'),
    backgroundColor: Colors.black,
    centerTitle: true,
  );
}

Widget buildBody(String preco){
  return Container(
    padding: EdgeInsets.all(32.0),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/bitcoin-logo.png"),
          Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30),
            child: Text(preco,
            style: TextStyle(fontSize: 35.0),
            ),
          ),
          buildButton("Atualizar")
        ],
      ),
    ),
  );
}

Widget buildFooter(String dataAtualizacao){
   return Container(
    color: Colors.black,
    width: double.maxFinite,
    height: 50,
    child: Align(
      alignment: Alignment.center,
      child: Text(
        "Última atualização em $dataAtualizacao.",
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}

Widget buildButton(String texto) {
  return SizedBox(
    width: double.infinity,
      child: RaisedButton(
        splashColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          side: BorderSide(color: Colors.black)
        ),
        child: Text(
          texto,
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(30.0, 15, 30.0, 15.0),
        onPressed: () {
          _atualizarData();
         _atualizarPreco();
      },
    ),
  );
}

}

