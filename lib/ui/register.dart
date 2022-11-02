import 'package:class_scheduler/ui/home_page.dart';
import 'package:class_scheduler/util/authentication.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthMode { student, teacher }

// TODO: ADD ALL THE AVAILABLE DEPARTMENTS
// TODO: ADD SERVER-SIDE CONTROLL OVER THE DEPARTMENT ENTRIES.
enum Department { software, electrical, mechanical, biomedical, civil }

enum Year { one, two, three, four, five, other }

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  // TODO: RELEASE ALL THESE CONTROLLERS IN THE dispose METHOD

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtPasswordConfirmation = TextEditingController();
  TextEditingController txtPhoneNumber = TextEditingController();
  TextEditingController txtUserName = TextEditingController();
  TextEditingController txtSection = TextEditingController();
  AuthMode authMode = AuthMode.student;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final authentication = Authentication();
  String message = "";
  Department? department;
  Year? year;

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
                      Row(
                        children: [
                          Radio(
                              value: AuthMode.student,
                              groupValue: authMode,
                              onChanged: _handleAuthModeChange),
                          const SizedBox(width: 5),
                          const Text("Register as student")
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                              value: AuthMode.teacher,
                              groupValue: authMode,
                              onChanged: _handleAuthModeChange),
                          const SizedBox(width: 5),
                          const Text("Register as teacher")
                        ],
                      ),
                      _buildUserNameField(),
                      const SizedBox(height: 20),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildPasswordConfirmationField(),
                      const SizedBox(height: 20),
                      if (authMode == AuthMode.teacher) ...[
                        _buildPhoneNumberField(),
                        const SizedBox(height: 20),
                      ],
                      if (authMode == AuthMode.student) ...[
                        _buildDepartmentDropDown(),
                        const SizedBox(height: 20),
                        _buildYearDropDown(),
                        const SizedBox(height: 20),
                        _buildSectionField(),
                        const SizedBox(height: 20),
                      ],
                      if (message.isNotEmpty) ...[
                        _buildErrorMessage(),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildUserNameField() {
    return TextFormField(
      controller: txtUserName,
      decoration: const InputDecoration(labelText: "Choose a username"),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please Enter a username";
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentDropDown() {
    return DropdownButtonFormField(
      value: department,
      hint: const Text('Department'),
      items: const [
        DropdownMenuItem(
          value: Department.software,
          child: Text('software'),
        ),
        DropdownMenuItem(
          value: Department.electrical,
          child: Text('electrical'),
        ),
        DropdownMenuItem(
          value: Department.mechanical,
          child: Text('mechanical'),
        ),
        DropdownMenuItem(
          value: Department.biomedical,
          child: Text('biomedical'),
        ),
        DropdownMenuItem(
          value: Department.civil,
          child: Text('civil'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          department = value;
        });
      },
      validator: (value) {
        if (department == null) {
          return "Please choose a department";
        }
        return null;
      },
    );
  }

  _buildYearDropDown() {
    return DropdownButtonFormField(
      value: year,
      hint: const Text('Year'),
      items: const [
        DropdownMenuItem(
          value: Year.one,
          child: Text('one'),
        ),
        DropdownMenuItem(
          value: Year.two,
          child: Text('two'),
        ),
        DropdownMenuItem(
          value: Year.three,
          child: Text('three'),
        ),
        DropdownMenuItem(
          value: Year.four,
          child: Text('four'),
        ),
        DropdownMenuItem(
          value: Year.five,
          child: Text('five'),
        ),
        DropdownMenuItem(
          value: Year.other,
          child: Text('other'),
        ),
      ],
      validator: (value) {
        if (value == null) {
          return 'Please enter year';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          year = value!;
        });
      },
    );
  }

  Widget _buildSectionField() {
    return TextFormField(
      controller: txtSection,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: "Your section"),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please Enter your section";
        }
        try {
          int.parse(value);
        } on Exception {
          return "Please enter numbers only";
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/sign_in');
          },
          child: const Text('Sign in'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              message = "";
            });
            if (_formKey.currentState!.validate()) {
              try {
                if (authMode == AuthMode.teacher) {
                  // make sure the username is not duplicate and register the teacher
                  if (!await FirestoreHelper.teacherUserNameAlreadyExists(
                      txtUserName.text)) {
                    String? userId = await authentication.registerTeacher(
                      txtUserName.text,
                      txtPhoneNumber.text,
                      txtEmail.text,
                      txtPassword.text,
                    );
                    if (userId != null) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomePage(userId)));
                    }
                  } else {
                    // we'll catch this down the road.
                    throw Exception();
                  }
                } else {
                  // registering a student
                  if (!await FirestoreHelper.studentUserNameAlreadyExists(
                      txtUserName.text)) {
                    String? userId = await authentication.registerStudent(
                      txtUserName.text,
                      txtEmail.text,
                      txtPassword.text,
                      department!,
                      year!,
                      int.parse(txtSection.text),
                    );
                    if (userId != null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomePage(userId)));
                    }
                  } else {
                    throw Exception();
                  }
                }
              } on FirebaseAuthException catch (e) {
                setState(() {
                  message = e.message!;
                });
              } on Exception catch (e) {
                // if we're here, it's because the entered username already exists
                setState(() {
                  message =
                      "That ${authMode.name} username already exists. Please choose something else.";
                });
              }
              // if we're signed in, we push the home page
              if (authentication.getUserId() != null) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomePage(authentication.getUserId()!),
                ));
              }
            }
          },
          child: const Text("Register"),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.red),
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

  TextFormField _buildPasswordConfirmationField() {
    return TextFormField(
      controller: txtPasswordConfirmation,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password confirmation";
        }
        if (value != txtPassword.text) {
          return "Your passwords don't match";
        }
        return null;
      },
      decoration: const InputDecoration(
        label: Text("Confirm your password"),
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
        if (authMode == AuthMode.teacher && !value.contains("aait")) {
          return "Please enter your AAiT provided email";
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(
          (authMode == AuthMode.student)
              ? "Your email"
              : "Your AAiT provided email",
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: txtPhoneNumber,
      decoration: const InputDecoration(labelText: "Your phone number"),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your phone number";
        }
        if (!value.startsWith("09")) {
          return "Your phone number should start with 09...";
        }
        return null;
      },
    );
  }

  void _handleAuthModeChange(AuthMode? value) {
    setState(() {
      authMode = value!;
    });
  }
}
