import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String key;
  String subject;
  String contents;
  bool completed;
  String userId;
  Timestamp regDt = new Timestamp.now();
  Timestamp updDt;

  Todo(this.subject, this.contents, this.userId, this.completed);

  Todo.fromSnapshot(DocumentSnapshot snapshot) :
    key = snapshot.documentID,
    userId = snapshot.data["userId"],
    subject = snapshot.data["subject"],
    contents = snapshot.data["contents"],
    completed = snapshot.data["completed"],
    regDt =  snapshot.data["regDt"],
    updDt = snapshot.data["updDt"];


  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "contents": contents,
      "completed": completed,
      "regDt": regDt,
      "updDt": updDt
    };
  }
}