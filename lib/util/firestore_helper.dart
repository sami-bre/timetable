import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/models/student.dart';
import 'package:class_scheduler/models/teacher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static final FirestoreHelper fsh = FirestoreHelper._internal();

  FirestoreHelper._internal();

  factory FirestoreHelper() {
    return fsh;
  }

  static void addTeacher(Teacher teacher) {
    FirebaseFirestore.instance.collection('teachers').add(teacher.toMap());
  }

  static void addStudent(Student student, User user) {
    // FirebaseFirestore.instance.collection('students').add(student.tomap());
    FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .set(student.tomap());
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

  static Future<List<Class>> getClassesForATeacher(User user) async {
    var raw = (await FirebaseFirestore.instance
            .collection('classes')
            .where('teacher_id', isEqualTo: user.uid)
            .get())
        .docs;
    var classes = raw.map((e) => Class.fromMap(e.data())).toList();
    return classes;
  }

  static Future<void> populateClassesUnderStudentsTest() async {
    var allClassesData =
        (await FirebaseFirestore.instance.collection('classes').get()).docs;
    for (var student
        in (await FirebaseFirestore.instance.collection('students').get())
            .docs) {
      for (var clas
          in (await FirebaseFirestore.instance.collection('classes').get())
              .docs) {
        FirebaseFirestore.instance
            .collection('students')
            .doc(student.id)
            .collection('tracked_classes')
            .add(clas.data());
      }
    }
  }

  static Future<List<Class>> getClassesForAStudent(User user) async {
    // id function just makes a one time retrieval. it returns a future, not a stream.
    var raw = (await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .collection('tracked_classes')
            .get())
        .docs;
    var classes = raw.map((e) => Class.fromMap(e.data())).toList();
    return classes;
  }

  static Stream<List<Class>> listenToClassesForAStudent(User user) async* {
    // this function retreives updates continuously.
    List<Class> classes;
    await for (var data in FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .collection('tracked_classes')
        .snapshots()) {
      classes = data.docs.map((e) => Class.fromMap(e.data())).toList();
      yield classes;
    }
  }
}
