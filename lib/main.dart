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
  final pessoas = new List<Pessoa>();
  var _isLoading = true;
  var url = "http://35.231.160.184/agenda/pessoas";
  //var url = "http://192.168.0.104:8088/api/pessoas";

  TextEditingController controllerNome = new TextEditingController();
  TextEditingController controllerTelefone = new TextEditingController();

  getAll() async {
    var data = await http.get(url);

    setState(() {
      pessoas.clear();
      if (data.statusCode == 200) {
        final json = jsonDecode(data.body);
        json.forEach((p) {
          final pessoa =
              new Pessoa(int.parse(p['id']), p['nome'], p['telefone']);
          pessoas.add(pessoa);
        });
      }
    });

    return "ok";
  }

  void save() async{
    if(controllerNome.text.isEmpty){
      nomeBranco();
      print("nome");
    }else if (controllerTelefone.text.isEmpty) {
      telefoneBranco();
      print("telefone");
    }else if (controllerNome.text.isNotEmpty && controllerTelefone.text.isNotEmpty) {
      var response = await http.post(url, body: {"nome": controllerNome.text, "telefone": controllerTelefone.text});
      if(response.statusCode ==200){
        getAll();
        Navigator.pop(context);
      }
    }    
  }

  

  void delete  (int id, int index) async {
    AlertDialog ad = new AlertDialog(
      title: Text("Exclusão de Contato"),
      content: Text("Excluir ${pessoas[index].nome}"),
      actions: <Widget>[
        RaisedButton(
          child: Text(
            "OK",
            style: new TextStyle(color: Colors.white),
          ),
          color: Colors.red,
          onPressed: () {
            var url = "${this.url}/$id";
            this.deleteOne(url);
          },
        ),
        RaisedButton(
          child:new Text(
            "CANCELAR", 
            style: new TextStyle(color: Colors.white)
            ),
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(context: context, child: ad);
  }

  void deleteOne(String url) async {
    var response = await http.delete(url);
    if(response.statusCode == 200){
      getAll();
      Navigator.pop(context);
    }
  }

  void getOne(int id) async {
    var data = await http.get("$url/$id");
    controllerNome.clear();
    controllerTelefone.clear();

    if (data.statusCode == 200) {
      var json = jsonDecode(data.body);

      setState(() {
        controllerNome.text = json['nome'];
        controllerTelefone.text = json['telefone'];      
      });
      
    }
  }

  void update(int id) async{
    var url = "${this.url}/$id";
    var response = await http.put(url, body: {"nome": controllerNome.text, "telefone": controllerTelefone.text});
    if(response.statusCode ==200){
      getAll();
      Navigator.pop(context);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Agenda'),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: (){
              getAll();
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            color: Colors.white,
            onPressed: (){
              setState(() {
                this.controllerNome.clear();
                this.controllerTelefone.clear();
              });
              Navigator.push(context,
                new MaterialPageRoute(
                  builder: (BuildContext context){
                    return addTela();
                  }
                )
              );
              getAll();
            },
          ),
        ],
      ),
      body: Center(
        child: new ListView.builder(
          itemCount: pessoas.length,
          itemBuilder: (context, i) {
            final pessoa = pessoas[i];
            return new Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: ListTile(
                        title: Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[Text(pessoa.nome ?? "")],
                            ),
                          ],
                        ),
                        subtitle: Text(pessoa.telefone ?? ""),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              delete(pessoa.id, i);
                              this.getAll();
                            },
                          ),
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(Icons.edit),
                            color: Colors.blueAccent,
                            onPressed: () {
                              getOne(pessoa.id);
                              Navigator.push(context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context){
                                    return editTela(pessoa.id);
                                  }
                                )
                              );
                               
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Divider()
              ],
            );
          },
        ),
      ),
    );
  }



  void nomeBranco() {
    AlertDialog ad = new AlertDialog(
      content: Text("Campo nome vazio!"),
      actions: <Widget>[
        RaisedButton(
          child:new Text(
            "OK", 
            style: new TextStyle(color: Colors.white)
            ),
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(context: context, child: ad);
  }

  void telefoneBranco() {
    AlertDialog ad = new AlertDialog(
      content: Text("Campo telefone vazio!"),
      actions: <Widget>[
        RaisedButton(
          child:new Text(
            "OK", 
            style: new TextStyle(color: Colors.white)
            ),
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  
    showDialog(context: context, child: ad);
  }
  
  @override
  void initState() {
    super.initState();
    this.getAll();
  }


  Scaffold addTela(){
    return Scaffold(      
      appBar: AppBar(
        title: Text("Adicionar Contato"),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(        
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: Column(          
          children: <Widget>[
            TextField(
              controller: controllerNome,
              decoration: InputDecoration(hintText: "Nome"),
              
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: controllerTelefone,
              decoration: InputDecoration(hintText: "Telefone"),
              
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text("Salvar"),
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: (){
                save();
                //getAll();
              },
            )
          ],
        ),
      ),
      ),
    );
  }

  Scaffold editTela(int id){
    return Scaffold(      
      appBar: AppBar(
        title: Text("Editar Contato"),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(        
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: Column(          
          children: <Widget>[
            TextField(
              controller: controllerNome,
              decoration: InputDecoration(hintText: "Nome"),
              
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: controllerTelefone,
              decoration: InputDecoration(hintText: "Telefone"),
              
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text("Salvar"),
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: (){
                update(id);                
                               
              },
            )
          ],
        ),
      ),
      ),
    );
  }
}



class Pessoa {
  int id;
  String nome;
  String telefone;

  Pessoa(this.id, this.nome, this.telefone);
}
