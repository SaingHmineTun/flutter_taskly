import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/model/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  String? _newTaskContent;
  Box? box;

  _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _displayTaskPopup();
      },
      child: Icon(Icons.add),
    );
  }

  _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Taskly",
        style: TextStyle(color: Colors.white, fontSize: _deviceWidth * 0.1),
      ),
      toolbarHeight: _deviceHeight * 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: _floatingActionButton(),
      appBar: _appBar(),
      body: _taskView(),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text("Add new task"),
          actions: [
            OutlinedButton(
              onPressed: () {
                if (_newTaskContent != null) {
                  Task task = Task(
                    content: _newTaskContent.toString(),
                    timestamp: DateTime.now(),
                    done: false,
                  );
                  box!.add(task.toMap());
                  setState(() {
                    _newTaskContent = null;
                    Navigator.pop(context);
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Save"),
            ),
          ],
          content: TextField(
            decoration: InputDecoration(
              labelText: "Enter new task",
              border: OutlineInputBorder(),
            ),
            onChanged: (str) {
              _newTaskContent = str;
            },
          ),
        );
      },
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          box = snapshot.data;
          return _taskList();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _taskList() {
    List tasks = box!.values.toList();

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            onLongPress: () {
              setState(() {
                box!.deleteAt(index);
              });
            },
            onTap: () {
              setState(() {
                task.done = !task.done;
                box!.putAt(index, task.toMap());
              });
            },
            title: Text(
              task.content,
              style:
                  task.done
                      ? TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
            ),
            subtitle: Text(task.timestamp.toString()),
            trailing: Checkbox(value: task.done, onChanged: (_) {}),
          ),
        );
      },
    );
  }

  // _taskList(List<Task> tasks) {
  //   return ListView(
  //     children:
  //         tasks.map((task) {
  //           return Card(
  //             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //             child: ListTile(
  //               title: Text(
  //                 task.content,
  //                 style:
  //                     task.done
  //                         ? TextStyle(decoration: TextDecoration.lineThrough)
  //                         : TextStyle(),
  //               ),
  //               subtitle: Text(task.timestamp.toString()),
  //               trailing: Checkbox(value: task.done, onChanged: (_) {}),
  //             ),
  //           );
  //         }).toList(),
  //   );
  // }
}
