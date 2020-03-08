import 'package:flutter/material.dart';
import '../models/memo.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MemoEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  Map<String, dynamic> args;
  Memo _memo;
  Function(Memo _memo) _editCallback;

  final _textSubjectController = TextEditingController();
  final _textContentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    _memo = args['memo'];
    _editCallback = args['editCallback'];
    _textSubjectController.text = _memo.subject;
    _textContentsController.text = _memo.contents;

    return new WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: Container(
          color: Color(0xFFFFE082),
          child: Column(
            children: <Widget>[
              new Expanded(
                flex: 1,
                child: TextField(
                  controller: _textSubjectController,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                  ),
                ),
              ),
              new Expanded(
                flex: 10,
                child: Container(
                  //color: Color(0xFFFFE082),
                  child: TextField(
                    controller: _textContentsController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Contents',
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Color(0xFFFFE082))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        if (_textSubjectController.text.length == 0 &&
            _textContentsController.text.length == 0) {
          Fluttertoast.showToast(msg: 'Empty');
        }else{
          if(_memo == null){
            // TODO : memo 생성
            _memo = new Memo(completed: false);
          }
          _memo.subject = _textSubjectController.text;
          _memo.contents = _textContentsController.text;
          _editCallback(_memo);
        }

        return new Future(() => true);
      },
    );
  }
}
