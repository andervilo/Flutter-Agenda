import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Agenda'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //List<Pessoa> pessoas;
  List pessoas;
  var url = "http://35.231.160.184/agenda/pessoas";

  Future<String> getAll() async {
    var data = await http.get(url);

    setState(() {
      //var json = jsonDecode(data.body);
      pessoas = jsonDecode(data.body);
      /*for (var item in json) {
        Pessoa p =
            Pessoa(int.parse(item['id']), item['nome'], item['telefone']);
        pessoas.add(p);
      }*/
      
    });

    return "ok";
  }

  void save() {
    http.post(
      url, 
      body:{
        "nome":"Luiz Botelho", 
        "telefone":"75 98745-2548"
      });
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: pessoas == null ? 0 : pessoas.length,
          itemBuilder: (BuildContext context, int index){
            return new Container(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      title: Text(pessoas[index]['nome']),
                      subtitle: Text(pessoas[index]['telefone'] ?? ""),
                      onTap: (){
                        save();
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this.getAll();
  }
}

class Pessoa {
  int id;
  String nome;
  String telefone;

  Pessoa(this.id, this.nome, this.telefone);
}
