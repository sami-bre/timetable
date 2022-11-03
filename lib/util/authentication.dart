import 'package:class_scheduler/models/student.dart';
import 'package:class_scheduler/models/teacher.dart';
import 'package:class_scheduler/ui/register.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static final _singleton = Authentication._internal();

  Authentication._internal();

  factory Authentication() {
    return _singleton;
  }

  Future<String?> signIn(String email, String password) async {
    UserCredential credential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user?.uid;
  }

  Future<String?> registerTeacher(
    String name,
    String phoneNumber,
    String email,
    String password,
  ) async {
    UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (credential.user?.uid != null) {
      // create a document for the teacher
      Teacher teacher = Teacher(name, email, phoneNumber);
      // the uid of the account will be assigned to the 'id' field of the corresponding teacher document
      teacher.id = credential.user!.uid;
      FirestoreHelper.addTeacher(teacher);
    }
    return credential.user?.uid;
  }

  Future<void> signOut() async {
    var result = await auth.signOut();
    return result;
  }

  String? getUserId() {
    return auth.currentUser?.uid;
  }

  User? getUser() {
    return auth.currentUser;
  }

  Future<String?> registerStudent(
    String userName,
    String email,
    String password,
    Department department,
    Year year,
    int section,
  ) async {
    UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (credential.user?.uid != null) {
      // create a document for the student
      Student student = Student(userName, email, department, year, section);
      // the uid of the account will be assigned to the 'id' field of the corresponding student document
      student.id = credential.user!.uid;
      FirestoreHelper.addStudent(student, credential.user!);
    }
    return credential.user?.uid;
  }
}
