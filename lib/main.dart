import 'package:flutter/material.dart';

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
//  List<int> _todoItemsCompleted = [];

  void _addTodoListItem(String todoText) {
    if (todoText.length > 0) {
      setState(() {
        _todoItems.add(todoText);
      });
    }
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Add a task")
          ),
          body: TextField(
            autofocus: true,
            onSubmitted: (todoText) {
              _addTodoListItem(todoText);
              Navigator.pop(context);
            },
            decoration: InputDecoration(
              hintText: "Enter something to do...",
              contentPadding: const EdgeInsets.all(16.0),
            ),
          )
        );
      })
    );
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Mark "${_todoItems[index]}" as complete?'),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text("Mark as done"),
            onPressed: () {
              _removeTodoItem(index);
              Navigator.of(context).pop();
            },
          ),
        ]
      );
    });
  }

  Widget _buildTodoList() {
    return ListView.builder(itemBuilder: (context, index) {
      if (index < _todoItems.length) {
        return _buildTodoItem(index, _todoItems[index]);
      }
    });
  }

  Widget _buildTodoItem(int index, String todoText) {
//    if (_todoItemsCompleted.contains(index)) {
//      return ListTile(
//        title: Text(
//          todoText,
//          style: TextStyle(
//            color: Colors.red,
//            decoration: TextDecoration.lineThrough,
//          )
//        ),
//        onTap: () => _promptRemoveTodoItem(index),
//      );
//    }

    return ListTile(
      title: Text(todoText),
      onTap: () => _promptRemoveTodoItem(index),
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
        onPressed: _pushAddTodoScreen,
        tooltip: "Add task",
        child: Icon(Icons.add),
      ),
    );
  }
}

