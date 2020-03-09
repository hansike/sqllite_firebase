import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../services/authentication.dart';
import '../services/memo.dart';
import '../models/memo.dart';
import 'drawer.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';

class MemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  //List<Memo> _memoList;
  bool isDisposed = false;
  MemoService _memoService = new MemoService();
  Auth auth;

  // native admob
  static const _adUnitID = "ca-app-pub-5432103368789181/2439397011";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  setList() async {
    List<Memo> _memoList = await _memoService.setMemoList();
    if (!isDisposed) {
      setState(() {
        print(_memoList.length.toString() + "개의 메모리스트 확인");
      });
    }
  }

  addNewMemo(Memo memo) {
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

  Widget showMemoList() {
    List<Memo> _memoList = _memoService.getMemoList();
    // if (_memoList.length > 0) {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        shrinkWrap: true,
        itemCount: _memoList.length,
        itemBuilder: (BuildContext context, int index) {
          Memo _memo = _memoList[index];
          //String userId = _memoList[index].userId;

          // admob
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            decoration: BoxDecoration(
              color: Color(_memo.color),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(5.0) //         <--- border radius here
                  ),
            ),
            child: showMenuListItem(_memo, index, context),
          );
          // } else {
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

  Widget showMenuListItem(Memo _memo, int index, BuildContext context) {
    if ("admob" == _memo.key) {
      return NativeAdmobBannerView(
        // Your ad unit id
        adUnitID: _adUnitID,

        // Styling native view with options
        options: const BannerOptions(
          backgroundColor: Color(0xFFFFE082),
          indicatorColor: Colors.black,
          ratingColor: Colors.yellow,
          adLabelOptions: const TextOptions(
            fontSize: 12,
            color: Colors.white,
            backgroundColor: Color(0xFFFFCC66),
          ),
          headlineTextOptions: const TextOptions(
            fontSize: 20,
            color: Colors.black,
          ),
          advertiserTextOptions: const TextOptions(
            fontSize: 14,
            color: Colors.black,
          ),
          bodyTextOptions: const TextOptions(
            fontSize: 14,
            color: Colors.grey,
          ),
          storeTextOptions: const TextOptions(
            fontSize: 12,
            color: Colors.black,
          ),
          priceTextOptions: const TextOptions(
            fontSize: 12,
            color: Colors.black,
          ),
          callToActionOptions: const TextOptions(
            fontSize: 15,
            color: Colors.white,
            backgroundColor: Color(0xFF4CBE99),
          ),
        ),

        // Whether to show media or not
        showMedia: false,

        // Content paddings
        contentPadding: EdgeInsets.all(10),

        onCreate: (controller) {
          // controller.setOptions(BannerOptions()); // change view styling options
        },
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/memo/edit',
            arguments: <String, dynamic>{
              'memo': _memo,
              'editCallback': editCallback,
            },
          );
        },
        child: Dismissible(
          key: Key(_memo.key),
          background: Container(
            color: Colors.green,
            child: Icon(Icons.check),
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: Container(
            color: Colors.red,
            child: Icon(Icons.delete),
            alignment: Alignment.centerRight,
          ),
          onDismissed: (direction) async {
            deleteMemo(_memo.key, index);
          },
          child: ListTile(
            title: Text(
              _memo.subject,
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(_memo.contents,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(fontSize: 14.0)),
            trailing: IconButton(
                icon: (_memo.completed)
                    ? Icon(
                        Icons.done_outline,
                        color: Colors.green,
                        size: 20.0,
                      )
                    : Icon(Icons.done, color: Colors.grey, size: 20.0),
                onPressed: () {
                  updateMemo(_memo);
                }),
          ),
        ),
      );
    }
  }

  loginCallback(String userId) async {
    //TODO widget.loginCallback();
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
      await auth.signOut();
      _memoService.setUserId("");
      
      //TODO widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  editCallback(Memo memo) {
    memo.userId = auth.getUserId();
    if (memo.key != null && memo.key != '') {
      updateMemo(memo);
    } else {
      addNewMemo(memo);
    }
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<Auth>(context);
    _memoService.setUserId(auth.getUserId());
    //setList();

    return Scaffold(
        drawer: Drawer(
          child: AppDrawer(),
        ),
        appBar: new AppBar(
          title: new Text(auth.getUserId()),
          actions: <Widget>[
            new FlatButton(
                child: new Text('login',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                    arguments: <String, dynamic>{
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
            //showAddMemoDialog(context);
            Navigator.pushNamed(
              context,
              '/memo/edit',
              arguments: <String, dynamic>{
                'editCallback': editCallback,
              },
            );
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
