import 'dart:math';
import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'repository/database_creator.dart';
import 'repository/repository_service_todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SqfLiteCrud(title: 'Flutter Demo Home Page'),
    );
  }
}

class SqfLiteCrud extends StatefulWidget {
  SqfLiteCrud({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SqfLiteCrudState createState() => _SqfLiteCrudState();
}

class _SqfLiteCrudState extends State<SqfLiteCrud> {
  final _formKey = GlobalKey<FormState>();
  Future<List<Todo>> future;
  String name;
  int id;

  @override
  initState() {
    super.initState();
    future = RepositoryServiceTodo.getAllTodos();
  }

  void readData() async {
    final todo = await RepositoryServiceTodo.getTodo(id);
    print(todo.name);
  }

  updateTodo(Todo todo) async {
    todo.name = 'please 🤫';
    await RepositoryServiceTodo.updateTodo(todo);
    setState(() {
      future = RepositoryServiceTodo.getAllTodos();
    });
  }

  deleteTodo(Todo todo) async {
    await RepositoryServiceTodo.deleteTodo(todo);
    setState(() {
      id = null;
      future = RepositoryServiceTodo.getAllTodos();
    });
  }

  Card buildItem(Todo todo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Icon(Icons.person_add, color: Colors.blueAccent,size: 50),            
            Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  child: Image.asset("images/doctor.png", fit: BoxFit.contain,),
                ),              
                                  
              ],
            ),
            Text(
              'Name         : ${todo.name}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Comment  : ${todo.info}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateTodo(todo),
                  child: Text('Update', style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteTodo(todo),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        icon: Icon(Icons.person_add),
        hintText: 'Name',
        fillColor: Colors.grey[150],
        filled: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
      },
      onSaved: (value) => name = value,
    );
  }

  void createTodo() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      int count = await RepositoryServiceTodo.todosCount();
      final todo = Todo(count, name, randomTodo(), false);
      await RepositoryServiceTodo.addTodo(todo);
      setState(() {
        id = todo.id;
        future = RepositoryServiceTodo.getAllTodos();
      });
      print(todo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('sqfLite CRUD'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Image.asset('images/icon.png'),         
          Text('Input your name:',style: TextStyle(color: Colors.black54, fontSize: 30, fontWeight: FontWeight.w700),),       
          SizedBox(height: 16),
          Form(
            key: _formKey,
            child: buildTextFormField(),
          ),
          Row(           
            children: <Widget>[              
              RaisedButton(                
                onPressed: createTodo,
                child: Text('Create', style: TextStyle(color: Colors.white)),
                color: Colors.green,
              ),
              RaisedButton(
                onPressed: id != null ? readData : null,
                child: Text('Read', style: TextStyle(color: Colors.white)),
                color: Colors.blue,
              ),
            ],
          ),
          FutureBuilder<List<Todo>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: snapshot.data.map((todo) => buildItem(todo)).toList());
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  String randomTodo() {
    final randomNumber = Random().nextInt(4);
    String todo;
    switch (randomNumber) {
      case 1:
        todo = 'Hai Dear, How ar u?';
        break;
      case 2:
        todo = 'Hmm, lets cek @gustiadityatm on ig';
        break;
      case 3:
        todo = 'Patreon in the description 🤗';
        break;
      default:
        todo = 'Leave a comment 🤓';
        break;
    }
    return todo;
  }
}
