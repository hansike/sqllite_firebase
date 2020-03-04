import 'package:flutter/material.dart';
import 'services/authentication.dart';
import 'pages/root_page.dart';

final routes = {
  '/': (BuildContext context) => new RootPage(auth: new Auth()),
  '/page1': (BuildContext context) => Page1(),
  '/page4': (BuildContext context) => Page4(),
};

class Page1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Page1'),
        RaisedButton(
          onPressed: () {
            // 현재 라우트를 pop(제거)
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ],
    );
  }
}

class Page4 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _Page4State();
}

class _Page4State extends State<Page4> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Page4'),
        RaisedButton(
          onPressed: () {
            // 현재 라우트를 pop(제거)
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ],
    );
    
  }
}
