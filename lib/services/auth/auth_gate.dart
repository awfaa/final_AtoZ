import 'package:finalatoz/home_screen.dart';
import 'package:finalatoz/main.dart';
import 'package:finalatoz/services/auth/login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user logged in
          if (snapshot.hasData) {
            return MainScreen();
          }

          //user not logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
