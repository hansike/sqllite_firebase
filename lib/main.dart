import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'services/authentication.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Locale locale = Locale('en');
    return MultiProvider(
      providers: [ChangeNotifierProvider<Auth>.value(value: Auth())],
      child: MaterialApp(
        supportedLocales: [Locale('en'), Locale('kr')],
        locale: locale,
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primaryColor: Colors.indigo,
          primarySwatch: Colors.indigo,
        ),
        //home: new RootPage(auth: new Auth()));
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}
