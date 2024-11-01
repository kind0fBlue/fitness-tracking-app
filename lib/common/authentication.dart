// authentication.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/view/home/home_view.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:flutter/material.dart';

Future<void> loginUser(
    String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("User logged in: ${userCredential.user?.email}");
    // 登录成功后跳转到主界面
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeView()),
    );
  } on FirebaseAuthException catch (e) {
    print("Error: $e");
  }
}

// Future<bool> registerUser(String email, String password) async {
//   try {
//     UserCredential userCredential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     print("User registered: ${userCredential.user?.email}");
//     return true; // 注册成功，返回 true
//   } on FirebaseAuthException catch (e) {
//     print("Error: $e");
//     return false; // 注册失败，返回 false
//   }
// }
Future<bool> signUpWithNameEmailPassword(
    String name, String email, String password) async {
  try {
    // Sign up the user with FirebaseAuth
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      // Store user's name and email in Firestore
      // print("users/${user.uid}");
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      await users.doc(user.uid).set({
        'name': name,
        'email': email,
      });

      return true;
    }
    return false;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> updateUserProfile(
    String gender, String birthday, String height, String weight) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reference the Firestore collection and document for the user
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Update user profile information in Firestore
      await userRef.update({
        'gender': gender,
        'birthday': birthday,
        'height': height,
        'weight': weight,
      });

      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> updateUserProfileCalories(
    String height, String weight, String Calorie) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reference the Firestore collection and document for the user
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Update user profile information in Firestore
      await userRef.update({
        'targetCalories': Calorie,
        'height': height,
        'weight': weight,
      });

      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<void> logoutUser(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  // 登出后，跳转到登录页面
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const LoginView()),
  );
}

Future<Map<String, dynamic>?> checkUserAndLoadData(BuildContext context) async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String uid = currentUser.uid;

    // 从 Firestore 中获取用户文档
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // 将用户数据和 uid 一起返回
    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
    data['uid'] = uid;
    if (!data.containsKey('targetCalories')) {
      // 如果不存在，则设置为默认值 0
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'targetCalories': "0",
      });
      data['targetCalories'] = "0"; // 更新数据
      print('Target calories set to default value of 0');
    }

    return data;
  }
  Navigator.of(context).pushReplacementNamed('/login');
  return null;
}
