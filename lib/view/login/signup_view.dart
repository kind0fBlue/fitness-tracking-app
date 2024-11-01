// signup_view.dart
import 'package:fitness/common/authentication.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 确保导入
import 'package:fitness/view/personinfo/profile_completion_view.dart';
import 'package:fitness/common/colo_extension.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 打开链接的函数
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url); // 将字符串转换为 Uri 对象
    if (await canLaunchUrl(uri)) {
      // 使用 canLaunchUrl
      await launchUrl(uri); // 使用 launchUrl
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: media.height * 0.1), // 顶部间距
                const Text("Hi,", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const Text("Please create account",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: media.height * 0.05),

                // 名字文本框
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: media.height * 0.02),

                // 姓氏文本框
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: media.height * 0.02),

                // 电子邮件文本框
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: media.height * 0.02),

                // 密码文本框
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // 切换密码可见性
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible, // 根据状态隐藏或显示密码
                ),
                SizedBox(height: media.height * 0.02),

                // 条款和条件复选框以及隐私政策
   
                SizedBox(height: media.height * 0.02),

                // 注册按钮
                ElevatedButton(
                  onPressed: () async {
                    // 执行注册逻辑
                    bool registrationSuccess =
                        await signUpWithNameEmailPassword(
                            _firstNameController.text +
                                _lastNameController.text,
                            _emailController.text,
                            _passwordController.text);

                    // 检查注册是否成功
                    if (registrationSuccess) {
                      // 如果成功，跳转到个人资料完成页面，传递名字和姓氏
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ProfileCompletionView(),
                        ),
                      );
                    } else {
                      // 处理注册失败的情况，例如显示错误消息
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Registration failed")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Tcolor.primaryColor1,
                    minimumSize: Size(media.width * 0.8, 50),
                  ),
                  child: const Text("Sign Up",
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: media.height * 0.03),

                // 已有账户登录提示
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  },
                  child: const Text("Already have an account? Login",
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
