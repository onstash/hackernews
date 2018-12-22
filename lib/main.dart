import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoList(),
      theme: ThemeData(
        primaryColor: Colors.purple,
      )
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];

  void _addTodoListItem() {
    setState(() {
      int index = _todoItems.length;
      _todoItems.add('Item: ' + index.toString());
    });
  }

  Widget _buildTodoList() {
    return ListView.builder(itemBuilder: (context, index) {
      if (index < _todoItems.length) {
        return _buildTodoItem(_todoItems[index]);
      }
    });
  }

  Widget _buildTodoItem(String todoText) {
    return ListTile(
      title: Text(todoText)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks at hand"),
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoListItem,
        tooltip: "Add task",
        child: Icon(Icons.add),
      ),
    );
  }
}

