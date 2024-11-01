// welcome_view.dart
import 'package:flutter/material.dart';
import 'package:fitness/view/home/home_view.dart';

class WelcomeView extends StatelessWidget {
  final String username; // 接收用户名

  const WelcomeView({super.key, required this.username}); // 构造函数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 欢迎信息
            Text(
              'Welcome, $username',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'You are all set now, let\'s reach your goals together with us.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            // 添加 Confirm 按钮
            ElevatedButton(
              onPressed: () {
                // 在导航时传递用户名
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomeView(), // 传递用户名
                  ),
                );
                print('Confirm button clicked'); // 这里可以替换为实际的导航逻辑
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 设置按钮颜色
                minimumSize: const Size(150, 50), // 设置按钮最小大小
              ),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
