import 'package:class_scheduler/models/teacher.dart';
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
      FirestoreHelper.addTeacher(Teacher(name, email, phoneNumber));
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
}
