import 'package:class_scheduler/ui/home_page.dart';
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
    // TODO: ADD AN ERROR MESSAGE WIDGET
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Authenticate the user
              try {
                Authentication()
                    .signIn(txtEmail.text, txtPassword.text)
                    .then((value) {
                  if (value != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomePage(value),
                    ));
                  } else {
                    throw Exception(
                        "Signing in didn't throw an error but uid is null");
                  }
                });
              } on FirebaseAuthException catch (e) {
                print(e);
                setState(() {
                  message = e.message!;
                });
              }
            }
            ;
          },
          child: const Text("Sign in"),
        ),
      ],
    );
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
