import 'package:cloud_firestore/cloud_firestore.dart';

class Memo {
  
  String key;
  String color;
  String subject;
  String contents;
  bool completed;
  String userId;
  String regDt;
  String updDt;

  Memo(
      {
      this.key,
      this.color,
      this.subject,
      this.contents,
      this.completed,
      this.userId,
      this.regDt,
      this.updDt});

  Memo.fromSnapshot(DocumentSnapshot snapshot)
      : key = snapshot.documentID,
        userId = snapshot.data["userId"],
        color = snapshot.data["color"],
        subject = snapshot.data["subject"],
        contents = snapshot.data["contents"],
        completed = snapshot.data["completed"],
        regDt = snapshot.data["regDt"].toString(),
        updDt = snapshot.data["updDt"].toString();

  toJson() => {
        "key": key,
        "userId": userId,
        "color": color,
        "subject": subject,
        "contents": contents,
        "completed": completed,
        "regDt": regDt.toString(),
        "updDt": updDt.toString(),
      };

      toJsonSqlite() => {
        "key": key,
        "userId": userId,
        "color": color,
        "subject": subject,
        "contents": contents,
        "completed": completed? 1 : 0,
        "regDt": regDt.toString(),
        "updDt": updDt.toString(),
      };
  
  factory Memo.fromMap(Map<String, dynamic> json) => new Memo(
        key: json["key"],
        userId: json["userId"],
        color: json["color"],
        subject: json["subject"],
        contents: json["contents"],
        completed: json["completed"] == 1,
        regDt: json["regDt"].toString(),
        updDt: json["updDt"].toString(),
      );
}
