import 'package:class_scheduler/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'ui/home_page.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/sign-in': (context) => const Gate()
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
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

