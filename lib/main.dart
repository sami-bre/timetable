import 'package:class_scheduler/firebase_options.dart';
import 'package:class_scheduler/ui/class_catalog.dart';
import 'package:class_scheduler/ui/register.dart';
import 'package:class_scheduler/ui/sign_in.dart';
import 'package:class_scheduler/ui/student_home_page.dart';
import 'package:class_scheduler/ui/section_view.dart';
import 'package:class_scheduler/ui/teacher_view.dart';
import 'package:class_scheduler/util/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

// TODO: enfore the rule that the duration of any schedule should not go into the next day.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  // this is a really important static method that allows
  // me to get a refrence of the state of this (root) widget.
  // for the purpose of the dark theme functionality
  static AppState of(BuildContext context) {
    return context.findAncestorStateOfType<AppState>()!;
  }

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  // this is the themeMode of the app. it switches between light and dark.
  ThemeMode themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      this.themeMode = themeMode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/launch',
      routes: {
        '/sign_in': (context) => const SignInPage(),
        '/launch': (context) => const LaunchScreen(),
        '/register': (context) => const Registerpage(),
      },
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {

  void doRouting() {
    String? userId = Authentication().getUserId();
    if (userId != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            (Authentication().getUser()!.email!.toLowerCase().contains('aait'))
                ? TeacherView(Authentication().getUser()!)
                : StudentHomePage(Authentication().getUser()!),
      ));
    } else {
      Navigator.of(context).pushReplacementNamed('/sign_in');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1)).then((value) => doRouting());
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
