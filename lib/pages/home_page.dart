import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication.dart';
import '../models/todo.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final Firestore firestore = Firestore.instance;
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList = new List();

  final _textEditingController = TextEditingController();
  final _textEditingContentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('initState');
    widget.firestore
        .collection("users")
        .document(widget.userId)
        .collection('todo')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> ds = querySnapshot.documents;
      ds.forEach((u) {
        _todoList.add(new Todo.fromSnapshot(u));
      });
    }).catchError((onError) {
      print("Error getting documents: " + onError);
    }).whenComplete(() {
      setState(() {
        print('initState complete');
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getList() async {}

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  addNewTodo(String todoItem, String contents) {
    if (todoItem.length > 0) {
      Todo todo = new Todo(
          todoItem.toString(), contents.toString(), widget.userId, false);

      widget.firestore
          .collection('users')
          .document(widget.userId)
          .collection('todo')
          .add(todo.toJson())
          .then((docRef) {
        print("Document written with ID: " + docRef.documentID);
        todo.key = docRef.documentID;
      }).catchError((error) {
        print("Error adding document: " + error);
      }).whenComplete(() {
        setState(() {
          _todoList.add(todo);
        });
      });
    }
  }

  updateTodo(Todo todo) {
    //Toggle completed

    setState(() {
      todo.completed = !todo.completed;
      todo.updDt = new Timestamp.now();
    });
    if (todo != null) {
      widget.firestore
          .collection('users')
          .document(widget.userId)
          .collection('todo')
          .document(todo.key)
          .setData(todo.toJson())
          .then((docRef) {
        print("Document update with ID: " + todo.key);
      }).catchError((error) {
        print("Error updating document: " + error);
      }).whenComplete(() {
        print("updateTodo complete");
      });
    }
  }

  deleteTodo(String todoId, int index) {
    widget.firestore
        .collection('users')
        .document(widget.userId)
        .collection('todo')
        .document(todoId)
        .delete()
        .then((docRef) {
      print("Document delete with ID: " + todoId);
    }).catchError((error) {
      print("Error deleting document: " + error);
    });
  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Column(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Subject',
                  ),
                )),
                new Expanded(
                    child: new TextField(
                  controller: _textEditingContentsController,
                  autofocus: false,
                  decoration: new InputDecoration(
                    labelText: 'Contents',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    addNewTodo(_textEditingController.text.toString(),
                        _textEditingContentsController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            //String userId = _todoList[index].userId;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                deleteTodo(todoId, index);
              },
              child: ListTile(
                title: InkWell(
                  onTap: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Tap'),
                    ));
                  },
                  child: Text(
                    subject,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                trailing: IconButton(
                    icon: (completed)
                        ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                        : Icon(Icons.done, color: Colors.grey, size: 20.0),
                    onPressed: () {
                      updateTodo(_todoList[index]);
                    }),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('page1',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () {
                  Navigator.pushNamed(context, '/page1');
                }),
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: showBottomAppBar(context));
  }

  BottomAppBar showBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(), // or null
      color: Theme.of(context).primaryColor,
      child: Row(
        children: <Widget>[
          // Bottom that pops up from the bottom of the screen.
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => Container(
                alignment: Alignment.center,
                height: 200,
                child: Text('Dummy bottom sheet'),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () =>
                Fluttertoast.showToast(msg: 'Dummy search action.'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Fluttertoast.showToast(msg: 'Dummy menu action.'),
          ),
        ],
      ),
    );
  }
}
