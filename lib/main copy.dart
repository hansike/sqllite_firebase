import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

FirebaseUser _user;
Firestore firestore = Firestore.instance;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("hello world"),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              title: Text('Business'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              title: Text('School'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FlatButton(
              color: Colors.blue,
              child:
                  Text("create button", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Add data on click.
                firestore
                    .collection('users')
                    .document(_user.uid)
                    .setData({'id': 'test', 'email': 'khs208@gmail.com'});
              },
            ),
            FlatButton(
              color: Colors.blue,
              child: Text("read button", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Read data on click.
                firestore
                    .collection('users')
                    .document('json')
                    .get()
                    .then((DocumentSnapshot ds) {
                  String title = ds.data["email"];
                  print(ds.data["id"] + title);
                });
              },
            ),
            FlatButton(
              color: Colors.blue,
              child:
                  Text("update button", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Update data on click.
                firestore
                    .collection('users')
                    .document('json')
                    .updateData({'email': 'update@gmail.com'});
              },
            ),
            FlatButton(
              color: Colors.blue,
              child:
                  Text("delete button", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Delete data on click.
                firestore.collection('users').document('json').delete();
              },
            ),
            FlatButton(
              color: Colors.amber,
              child: Text("Login", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                // 전체 소스코드
                final GoogleSignIn _googleSignIn = GoogleSignIn();
                final FirebaseAuth _auth = FirebaseAuth.instance;

                GoogleSignInAccount account = await _googleSignIn.signIn();
                GoogleSignInAuthentication authentication =
                    await account.authentication;
                AuthCredential credential = GoogleAuthProvider.getCredential(
                    idToken: authentication.idToken,
                    accessToken: authentication.accessToken);
                AuthResult authResult =
                    await _auth.signInWithCredential(credential);
                _user = authResult.user;

                firestore.collection('users').document(_user.uid).setData({
                  'uid': _user.uid,
                  'providerId': _user.providerId,
                  'photoUrl': _user.photoUrl,
                  'phoneNumber': _user.phoneNumber,
                  'isEmailVerified': _user.isEmailVerified,
                  'isAnonymous': _user.isAnonymous,
                  'hashCode': _user.hashCode,
                  'email': _user.email,
                  'displayName': _user.displayName,
                  'metadata': {
                    'creationTime': _user.metadata.creationTime,
                    'lastSignInTime': _user.metadata.lastSignInTime
                  }
                });
              },
            ),
            _widgetOptions.elementAt(_selectedIndex)
          ],
        ),
      ),
    );
  }
}
