import 'package:final_atoz/home_screen.dart';
import 'package:final_atoz/services/auth/login_register.dart';
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
            return HomeScreen();
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
