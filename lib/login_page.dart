import 'package:final_atoz/components/button.dart';
import 'package:final_atoz/components/text_field.dart';
import 'package:final_atoz/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final emailController = TextEditingController();
  final passController = TextEditingController();

  //sign in user
  void singIn() async {
    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailAndPassword(
          emailController.text, passController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 50),

            // welcome
            const Text(
              "Welcome to Food Waste Manager",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            //email
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            const SizedBox(height: 10),

            //pass
            MyTextField(
              controller: passController,
              hintText: 'Password',
              obscureText: true,
            ),

            const SizedBox(height: 25),

            //sign in
            MyButton(onTap: singIn, text: "Sign In"),

            const SizedBox(height: 25),

            //register
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  'Register here',
                ),
              )
            ])
          ]),
        ),
      ),
    ));
  }
}
