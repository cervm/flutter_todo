import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/routes/todo_dialog.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _completedKey = GlobalKey<State>();

  ListTile _taskTile(Task task) {
    final completedTextStyle = TextStyle(
      decoration: TextDecoration.lineThrough,
    );

    return ListTile(
      leading: IconButton(
        icon: task.completed
            ? Icon(FontAwesomeIcons.checkCircle)
            : Icon(FontAwesomeIcons.circle),
        onPressed: () => _toggleTask(task),
      ),
      title: Text(
        '${task.name}',
        style: task.completed ? completedTextStyle : null,
      ),
      subtitle: (task.details != null)
          ? Text(
              task.details,
              style: task.completed ? completedTextStyle : null,
            )
          : null,
      trailing: IconButton(
        icon: Icon(FontAwesomeIcons.trash),
        onPressed: () => _deleteTask(task),
      ),
    );
  }

  void _addTask() async {
    final task = await Navigator.push(
        context,
        MaterialPageRoute<Task>(
          builder: (context) => TaskDialog(),
          fullscreenDialog: true,
        ));

    if (task != null) {
      setState(() {
        Task.tasks.add(task);
      });
    }
  }

  void _toggleTask(Task task) {
    setState(() {
      task.completed = !task.completed;
    });

    final snackBar = SnackBar(
      content: Text('Yay! A SnackBar!'),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() {
            task.completed = !task.completed;
          });
        },
      ),
    );

    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _deleteTask(Task task) async {
    final confirmed = (Platform.isIOS)
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Delete Task?'),
              content: const Text('This task will be permanently deleted.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('Delete'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          )
        : await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task?'),
              content: const Text('This task will be permanently deleted.'),
              actions: <Widget>[
                FlatButton(
                  child: const Text("CANCEL"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: const Text("DELETE"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          );

    if (confirmed ?? false) {
      setState(() {
        Task.tasks.remove(task);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Todos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          for (var task in Task.currentTasks) _taskTile(task),
          Divider(),
          ExpansionTile(
            key: _completedKey,
            title: Text('Completed (${Task.completedTasks.length})'),
            children: <Widget>[
              for (var task in Task.completedTasks) _taskTile(task),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.plus),
        onPressed: _addTask,
      ),
    );
  }
}
