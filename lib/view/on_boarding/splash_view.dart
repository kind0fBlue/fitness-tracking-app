// splash_view.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/view/home/home_view.dart';
import 'package:fitness/view/login/signup_view.dart';
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // 用户已登录，跳转到主页面
          return const HomeView();
        } else {
          // 用户未登录，跳转到登录页面
          return const SignupView();
        }
      },
    );
  }
}
