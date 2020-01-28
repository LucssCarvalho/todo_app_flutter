import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();

  List _todoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  void _addTodo() {
    if (_todoController.text.isEmpty) return;
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      newTodo["data"] = formatDate(
          DateTime.now(), [dd, '/', mm, '/', yyyy, ' | ', HH, ':', nn]);

      _todoList.add(newTodo);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Lista de tarefas'),
      ),
      body: Container(
        color: Colors.blueGrey[300],
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                    topRight: const Radius.circular(20.0),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white),
                        controller: _todoController,
                        decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "*";
                          }
                        },
                      ),
                    ),
                    RaisedButton(
                        color: Colors.blueAccent,
                        child: Text('ADD'),
                        textColor: Colors.white,
                        onPressed: _addTodo),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  itemCount: _todoList.length,
                  itemBuilder: buildItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: Container(
        color: Colors.white,
        child: CheckboxListTile(
          title: Text(_todoList[index]["title"]),
          subtitle: Text(_todoList[index]["data"].toString()),
          value: _todoList[index]["ok"],
          secondary: CircleAvatar(
            backgroundColor:
                _todoList[index]["ok"] ? Colors.green : Colors.yellow[700],
            child: Icon(
              _todoList[index]["ok"] ? (Icons.check) : (Icons.error),
              color: Colors.white,
            ),
          ),
          onChanged: (c) {
            setState(
              () {
                _todoList[index]["ok"] = c;
                _saveData();
              },
            );
          },
        ),
      ),
      onDismissed: (direction) {
        setState(
          () {
            _lastRemoved = Map.from(_todoList[index]);
            _lastRemovedPos = index;
            _todoList.removeAt(index);

            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedPos, _lastRemoved);
                  });
                },
              ),
              duration: Duration(seconds: 2),
            );
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(snack);
          },
        );
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
