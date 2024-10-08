import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/auth/login_or_register.dart';
import 'package:homehunt/components/bottompagenav.dart';
import 'package:homehunt/pages/home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          //user is logged in
          if (snapshot.hasData) {
            return Bottompagenav();
          }
          //user is NOT logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}