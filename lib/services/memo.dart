import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/memo.dart';
import 'dart:math';

abstract class BaseMemoService {
  setUserId(String userId);
  Future<List<Memo>> setMemoList();
  List<Memo> getMemoList();

  addMemo(Memo memo);
  updateMemo(Memo memo);
  deleteMemo(String memoId);
}

class MemoService implements BaseMemoService {
  MemoService({this.userId});
  String userId;
  List<Memo> _memoList = new List();
  MemoSqlite _memoSqlite = new MemoSqlite();
  MemoFirebase _memoFirebase = new MemoFirebase();

  @override
  setUserId(String userId) {
    if (userId == null || userId == '') {
      this.userId = "";
    } else {
      this.userId = userId;
    }
  }

  @override
  Future<List<Memo>> setMemoList() async {
    if (userId != null && userId != '') {
      _memoList = await _memoFirebase.setMemoList(userId);
    } else {
      _memoList = await _memoSqlite.setMemoList(userId);
    }
    // add admob
    if (_memoList.length > 0) {
      Random random = new Random();
      _memoList.insert(
          random.nextInt(_memoList.length) + 1, new Memo(key: "admob"));
    }

    return _memoList;
  }

  @override
  List<Memo> getMemoList() {
    return _memoList;
  }

  @override
  addMemo(Memo memo) {
    memo.regDt = (new Timestamp.now()).toString();

    _memoList.add(memo);

    if (userId != null && userId != '') {
      _memoFirebase.addMemo(memo);
    } else {
      _memoSqlite.addMemo(memo);
    }
  }

  @override
  updateMemo(Memo memo) {
    memo.completed = !memo.completed;
    memo.updDt = (new Timestamp.now()).toString();

    if (userId != null && userId != '') {
      _memoFirebase.updateMemo(memo);
    } else {
      _memoSqlite.updateMemo(memo);
    }
  }

  @override
  deleteMemo(String memoId) {
    if (userId != null && userId != '') {
      _memoFirebase.deleteMemo(memoId, userId);
    } else {
      _memoSqlite.deleteMemo(memoId, userId);
    }
  }
}

class MemoSqlite {
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    print('sqlite - initDB()');
    String path = join(await getDatabasesPath(), "memo_database.db");
    return await openDatabase(path, version: 2, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE memo(key TEXT, color INTEGER, subject TEXT, contents TEXT, completed NUMERIC, userId TEXT, regDt TEXT, updDt TEXT )");
    });
  }

  Future<List<Memo>> setMemoList(String userId) async {
    print('sqlite - setMemoList()');
    final db = await database;
    var res = await db.query("memo");
    List<Memo> list =
        res.isNotEmpty ? res.map((c) => Memo.fromMap(c)).toList() : [];
    for (int i = 0; i < list.length; i++) {
      print("list - $i - " +
          list[i].key.toString() +
          list[i].completed.toString());
    }
    return list;
  }

  addMemo(Memo memo) async {
    print('sqlite - addMemo()');
    final db = await database;

    var uuid = new Uuid();
    String key = uuid.v1();
    memo.key = key;

    print('sqlite - setMemoList() - key = ' + key.toString());
    var res = await db.rawInsert(
        "INSERT Into memo (key, color, subject, contents, completed, userId, regDt)"
        " VALUES (?,?,?,?,?,?,?)",
        [
          memo.key,
          memo.color,
          memo.subject,
          memo.contents,
          memo.completed ? 1 : 0,
          memo.userId,
          memo.regDt
        ]);
    return res;
  }

  updateMemo(Memo memo) async {
    print('sqlite - updateMemo()');
    final db = await database;
    var res = await db.update("memo", memo.toJsonSqlite(),
        where: "key = ?", whereArgs: [memo.key]);
    return res;
  }

  deleteMemo(String key, String userId) async {
    print('sqlite - deleteMemo($key, $userId)');
    final db = await database;
    db.delete("memo", where: "key = ?", whereArgs: [key]);
  }
}

class MemoFirebase {
  Future<List<Memo>> setMemoList(String userId) async {
    List<Memo> _memoList = new List<Memo>();
    QuerySnapshot result = await Firestore.instance
        .collection("users")
        .document(userId)
        .collection('todo')
        .getDocuments();
    List<DocumentSnapshot> ds = result.documents;
    if (ds != null) {
      ds.forEach((u) {
        _memoList.add(new Memo.fromSnapshot(u));
      });
    }

    return _memoList;
  }

  addMemo(Memo memo) {
    if (memo != null) {
      Firestore.instance
          .collection('users')
          .document(memo.userId)
          .collection('todo')
          .document(memo.key)
          .setData(memo.toJson())
          .then((docRef) {
        print("Document written with ID: " + memo.key);
      }).catchError((error) {
        print("Error adding document: " + error);
      }).whenComplete(() {
        //_memoList.add(memo);
      });
    }
  }

  updateMemo(Memo memo) {
    //Toggle completed

    Firestore.instance
        .collection('users')
        .document(memo.userId)
        .collection('todo')
        .document(memo.key)
        .setData(memo.toJson())
        .then((docRef) {
      print("Document update with ID: " + memo.key);
    }).catchError((error) {
      print("Error updating document: " + error);
    }).whenComplete(() {
      print("updateMemo complete");
    });
  }

  deleteMemo(String memoId, String userId) {
    Firestore.instance
        .collection('users')
        .document(userId)
        .collection('todo')
        .document(memoId)
        .delete()
        .then((docRef) {
      print("Document delete with ID: " + memoId);
    }).catchError((error) {
      print("Error deleting document: " + error);
    });
  }
}
