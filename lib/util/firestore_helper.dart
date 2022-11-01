import 'package:class_scheduler/models/schedule.dart';
import 'package:class_scheduler/models/teacher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static final FirestoreHelper fsh = FirestoreHelper._internal();

  FirestoreHelper._internal();

  factory FirestoreHelper() {
    return fsh;
  }

  static void addTeacher(Teacher teacher) {
    FirebaseFirestore.instance.collection('teachers').add(teacher.toMap());
  }

  static Future<bool> teacherUserNameAlreadyExists(String name) async {
    var data = (await FirebaseFirestore.instance
        .collection('teachers')
        .where('name', isEqualTo: name)
        .get());
    return data.size > 0;
  }
}
