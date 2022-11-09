import 'package:class_scheduler/ui/student_home_page.dart';
import 'package:class_scheduler/ui/section_view.dart';
import 'package:class_scheduler/ui/teacher_view.dart';
import 'package:class_scheduler/util/authentication.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authentication = Authentication();
  String message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      if (message.isNotEmpty) ...[
                        _buildErrorMessage(),
                        const SizedBox(height: 20),
                      ],
                      const SizedBox(height: 20),
                      _buildActionButtons()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/register');
          },
          child: const Text('Register'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: submitForSignIn,
          child: const Text("Sign in"),
        ),
      ],
    );
  }

  void submitForSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? userId =
            await Authentication().signIn(txtEmail.text, txtPassword.text);
        if (userId != null) {
          if (authentication.getUser()!.email!.toLowerCase().contains('aait')) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => TeacherView(authentication.getUser()!),
            ));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => StudentHomePage(authentication.getUser()!),
            ));
          }
        } else {
          throw Exception(
            "Signing in didn't throw an error but uid is null",
          );
        }
      } on FirebaseAuthException catch (e) {
        print("we're in the catch clause");
        // TODO: this error message is not showing up. fix it.
        setState(() {
          message = e.message!;
        });
      }
    }
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: txtPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        if (value.length < 6) {
          return "Please enter your correct password";
        }
        return null;
      },
      decoration: const InputDecoration(
        label: Text("Your password"),
      ),
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: txtEmail,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        if (!EmailValidator.validate(value)) {
          return "Please enter a valid email";
        }
        return null;
      },
      decoration: const InputDecoration(
        label: Text("Your email"),
      ),
    );
  }
}
