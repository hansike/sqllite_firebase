import 'package:flutter/material.dart';
import 'routes.dart';


void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    
    return new MaterialApp(
      title: 'Flutter login demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: new RootPage(auth: new Auth()));
      initialRoute: '/',
      routes: routes,
    );
  }
}
