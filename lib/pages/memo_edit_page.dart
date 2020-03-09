import 'package:flutter/material.dart';
import '../models/memo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MemoEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  Memo _memo;
  Function(Memo _memo) _editCallback;
  bool isEditMode = false;

  final _textSubjectController = TextEditingController();
  final _textContentsController = TextEditingController();

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() {
      print('color code' + color.value.toString());
      _memo.color = color.value;
      print('memo.color code' + _memo.color.toString());
    });
    Navigator.of(context).pop();
  }

  void _openColorPicker() {
// raise the [showDialog] widget
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          // child: ColorPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true,
          //   pickerAreaHeightPercent: 0.8,
          // ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          child: BlockPicker(
            pickerColor: Color(_memo.color),
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    if (_memo == null) {
      _memo = args['memo'];
    }
    _editCallback = args['editCallback'];

    if (_memo == null) {
      _memo = new Memo(
          subject: '',
          contents: '',
          completed: false,
          color: Colors.lime.value);
    }

    _textSubjectController.text = _memo.subject;
    _textContentsController.text = _memo.contents;

    return new WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: () {
                _openColorPicker();
              },
            ),
            IconButton(
              icon: Icon(Icons.subject),
              onPressed: () {
                print('_memo.color' + _memo.color.toString());
              },
            ),
          ],
        ),
        body: Container(
          color: Color(_memo.color),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _textSubjectController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Subject',
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
                          borderSide:
                              new BorderSide(color: Color(_memo.color))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        if (_textSubjectController.text.trim().length == 0 &&
            _textContentsController.text.trim().length == 0) {
          Fluttertoast.showToast(msg: 'Empty');
        } else {
          _memo.subject = _textSubjectController.text.toString();
          _memo.contents = _textContentsController.text.toString();
          _editCallback(_memo);
        }

        return new Future(() => true);
      },
    );
  }
}
