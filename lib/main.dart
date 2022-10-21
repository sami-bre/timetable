import 'package:class_scheduler/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'ui/home_page.dart';

// TODO: enfore the rule that the duration of any schedule should not go into the next day.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterFireUIAuth.configureProviders(const [
    EmailProviderConfiguration(),
    PhoneProviderConfiguration(),
    GoogleProviderConfiguration(
        clientId:
            "789207632368-ta1cggn7hsfq7gsj681b8h00sgfj0o44.apps.googleusercontent.com"),
  ]);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  // this is a really important static method that allows
  // me to get a refrence of the state of this (root) widget.
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
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/sign-in': (context) => const Gate()
      },
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class Gate extends StatelessWidget {
  const Gate({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        AuthStateChangeAction((context, state) {
          if (state is SignedIn) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        })
      ],
    );
  }
}
