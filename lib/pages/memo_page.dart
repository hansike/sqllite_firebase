import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication.dart';
import '../services/memo.dart';
import '../models/memo.dart';

class MemoPage extends StatefulWidget {
  MemoPage(
      {Key key,
      this.auth,
      this.userId,
      this.loginCallback,
      this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final VoidCallback loginCallback;
  final String userId;
  final Firestore firestore = Firestore.instance;
  @override
  State<StatefulWidget> createState() => new _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  //List<Memo> _memoList;
  bool isDisposed = false;
  MemoService _memoService = new MemoService();
  final _textEditingController = TextEditingController();
  final _textEditingContentsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _memoService.setUserId(widget.userId);
    setList();
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  setList() async {
    List<Memo> _memoList = await _memoService.setMemoList();
    print(_memoList.length.toString() + "개의 메모리스트 확인");
  }

  addNewMemo(String memoItem, String contents) {
    Memo memo = new Memo(
        color: '0',
        subject: memoItem.toString(),
        contents: contents.toString(),
        userId: widget.userId,
        completed: false);
    _memoService.addMemo(memo);
  }

  updateMemo(Memo memo) {
    setState(() {
      _memoService.updateMemo(memo);
    });
  }

  deleteMemo(String memoId, int index) {
    setState(() {
      _memoService.deleteMemo(memoId);
    });
  }

  showAddMemoDialog(BuildContext context) async {
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
                    addNewMemo(_textEditingController.text.toString(),
                        _textEditingContentsController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showMemoList() {
    List<Memo> _memoList = _memoService.getMemoList();
    // if (_memoList.length > 0) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _memoList.length,
        itemBuilder: (BuildContext context, int index) {
          String memoId = _memoList[index].key;
          String subject = _memoList[index].subject;
          bool completed = _memoList[index].completed;
          //String userId = _memoList[index].userId;
          return Dismissible(
            key: Key(memoId),
            background: Container(color: Colors.red),
            onDismissed: (direction) async {
              deleteMemo(memoId, index);
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
                    updateMemo(_memoList[index]);
                  }),
            ),
          );
        });
    // } else {
    //   return Center(
    //       child: Text(
    //     "Welcome. Your list is empty",
    //     textAlign: TextAlign.center,
    //     style: TextStyle(fontSize: 30.0),
    //   ));
    // }
  }

  loginCallback(String userId) async {
    widget.loginCallback();
    _memoService.setUserId(userId);
    await setList();
    if (!isDisposed) {
      setState(() {
        print('loginCallback');
      });
    }
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      _memoService.setUserId("");
      setList();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.auth.getUserId()),
          actions: <Widget>[
            new FlatButton(
                child: new Text('login',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                    arguments: <String, dynamic>{
                      'auth': widget.auth,
                      'loginCallback': loginCallback,
                    },
                  );
                }),
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showMemoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddMemoDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar:  showBottomAppBar(context));
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
