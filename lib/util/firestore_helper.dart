import 'package:class_scheduler/models/student.dart';
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

  static void addStudent(Student student) {
    FirebaseFirestore.instance.collection('students').add(student.tomap());
  }

  static Future<bool> teacherUserNameAlreadyExists(String name) async {
    var data = (await FirebaseFirestore.instance
        .collection('teachers')
        .where('username', isEqualTo: name)
        .get());
    return data.size > 0;
  }

  static Future<bool> studentUserNameAlreadyExists(String name) async {
    var data = (await FirebaseFirestore.instance
        .collection('students')
        .where('username', isEqualTo: name)
        .get());
    return data.size > 0;
  }

  
}
