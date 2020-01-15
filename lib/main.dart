import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=381ecb73";

void main() async {
  
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      accentColor: Colors.amber,
      cursorColor: Colors.amber,
      textSelectionColor: Color.fromRGBO(50, 50, 50, 1),
      textSelectionHandleColor: Colors.amber
    )    
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dolar;
  double euro;
  double bitcoin;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    bitcoinController.text = "";
  }

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(5);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / this.euro).toStringAsFixed(2);
    bitcoinController.text = (dolar * this.dolar / this.bitcoin).toStringAsFixed(5);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(5);
  }

  void _bitcoinChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dolarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(2);
    euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      appBar: AppBar(
        title: Text("Conversor", style: TextStyle(color: Colors.black)),
        brightness: Brightness.light ,
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.black,
            onPressed: _clearAll,
            highlightColor: Colors.amber[400],
          )
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(10, 25, 10, 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on, size: 100, color: Colors.amber,),
                        Divider(height: 15,),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(height: 15,),
                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(height: 15,),
                        buildTextField("Euros", "€", euroController, _euroChanged),
                        Divider(height: 15,),
                        buildTextField("Bitcoin", "₿", bitcoinController, _bitcoinChanged),
                      ],
                    ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function changed) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.amber, fontSize: 18),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber)
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber)
      )
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 18.0
    ),
    onChanged: changed,
  );
}
