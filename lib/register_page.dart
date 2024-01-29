import 'package:final_atoz/components/button.dart';
import 'package:final_atoz/components/text_field.dart';
import 'package:final_atoz/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final restaurantNameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();

  //sign up user
  void signUp() async {
    if (passController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      //show error
      return;
    }

    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.createUserWithEmailAndPassword(
          emailController.text, passController.text);

      final user = authService.firebaseAuth.currentUser;

      // Store additional information in Firestore
      await authService.storeAdditionalUserInfo(
        user?.uid,
        restaurantNameController.text,
        addressController.text,
        contactController.text,
      );
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

            // register email account
            const Text(
              "Register account here",
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

            const SizedBox(height: 10),

            //confirm pass
            MyTextField(
              controller: confirmPassController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),

            const SizedBox(height: 10),
            MyTextField(
              controller: restaurantNameController,
              hintText: 'Restaurant Name',
              obscureText: false,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: addressController,
              hintText: 'Address',
              obscureText: false,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: contactController,
              hintText: 'Contact',
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //sign up
            MyButton(onTap: signUp, text: "Sign up"),

            const SizedBox(height: 25),

            //register
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  'Login here',
                ),
              )
            ])
          ]),
        ),
      ),
    ));
  }
}
