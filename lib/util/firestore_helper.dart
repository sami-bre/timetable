import 'dart:math';

import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/models/student.dart';
import 'package:class_scheduler/models/teacher.dart';
import 'package:class_scheduler/ui/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

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
    // the id of the student document will be the uid of the corresponding user from firebase auth
    FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .set(student.tomap());
  }

  static void addClass(Class clas) {
    FirebaseFirestore.instance.collection('classes').add(clas.toMap());
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

  static Future<void> populateRandomClassesTest() async {
    var randomClasses = <Class>[];
    for (int i = 0; i < 20; i++) {
      randomClasses.add(
        Class(
          // the course
          "Course: ${'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[i]}",

          /// the department
          Department.values[Random().nextInt(5)],
          // the section
          ['1', '2', '3', '4', '5', '6'][Random().nextInt(6)],
          // the year
          Year.values[Random().nextInt(6)],
          // the teacher id
          [
            // these are the uids of currently registered teachers from firebase auth.
            'zWLdgnXRQVOqOK2RLxm4xnZSGAt2',
            '5KxMt3WwTIeyZACL294ud1M7cSK2',
            'l1e9B4gjk6eOSe47FQrmCfww2Qw1',
            '8jfxemznh4g58Ai9dWXsoSqxf8z1',
          ][Random().nextInt(4)],
          // the sessions
          Random().nextBool()
              ? [
                  {
                    'day': Random().nextInt(6),
                    'start_hour': Random().nextInt(7) + 8,
                    'start_minute': Random().nextInt(60),
                    'duration_minute': Random().nextInt(210) + 30
                  },
                  {
                    'day': Random().nextInt(6),
                    'start_hour': Random().nextInt(7) + 8,
                    'start_minute': Random().nextInt(60),
                    'duration_minute': Random().nextInt(210) + 30
                  },
                  {
                    'day': Random().nextInt(6),
                    'start_hour': Random().nextInt(7) + 8,
                    'start_minute': Random().nextInt(60),
                    'duration_minute': Random().nextInt(210) + 30
                  }
                ]
              : [
                  {
                    'day': Random().nextInt(6),
                    'start_hour': Random().nextInt(7) + 8,
                    'start_minute': Random().nextInt(60),
                    'duration_minute': Random().nextInt(270) + 90
                  },
                  {
                    'day': Random().nextInt(6),
                    'start_hour': Random().nextInt(7) + 8,
                    'start_minute': Random().nextInt(60),
                    'duration_minute': Random().nextInt(270) + 90
                  },
                ],
        ),
      );
    }
    for (Class clas in randomClasses) {
      addClass(clas);
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
