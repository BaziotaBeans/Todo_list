import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/item.dart';

void main() => runApp(App());


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  var items = new List<Item>();

  HomePage(){
    items = [];
    //items.add(Item(title: "Item 1", done: false));
    //items.add(Item(title: "Item 3", done: true));
    //items.add(Item(title: "Item 3", done: false));
    //items.add(Item(title: "Cozinhar Sopa", done: true));
    //items.add(Item(title: "Comprar açucar", done: true));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add()
  {
    setState(() {
      if(newTaskCtrl.text.isEmpty) return;
      widget.items.add(Item(
        title: newTaskCtrl.text,
        done: false,
      ),
      );
      newTaskCtrl.text = "";
      save();
      //newTaskCtrl.clear();
    });
  }

  void remove(int index)
  {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async
  {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if(data != null)
    {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState(){
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          decoration: InputDecoration(
            labelText: "Adiciona a tarefa do dia Emma",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          Icon(Icons.plus_one)
        ],
      ),
      body: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext ctxt, int index){
            final item = widget.items[index];
            return Dismissible(
              child: CheckboxListTile(
                title: Text(item.title),
                value: item.done,
                onChanged: (value){
                  setState(() {
                    item.done = value;
                    save();
                  });
                },
              ),
              key: Key(item.title),
              background: Container(
                color: Colors.red,
                child: Text("Excluir", style: TextStyle(color: Colors.white, fontSize: 20),),
              ),
              onDismissed: (direction){
                remove(index);
              },
            );
         },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
      );
  }
}

