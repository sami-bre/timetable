import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: Icon(
                    size: 36,
                    Theme.of(context).brightness == Brightness.light
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                  ),
                  onPressed: () {
                    App.of(context).changeTheme(
                        App.of(context).themeMode == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light);
                  },
                )
              ],
            ),
            const Divider(),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/sign_in');
              },
              child: const Text(
                'Sign out',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
