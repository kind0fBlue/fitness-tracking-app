import 'package:fitness/common/authentication.dart';
import 'package:fitness/view/personinfo/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // 导入 intl 包以格式化日期

class ProfileCompletionView extends StatefulWidget {
  const ProfileCompletionView({super.key});

  @override
  State<ProfileCompletionView> createState() => _ProfileCompletionViewState();
}

class _ProfileCompletionViewState extends State<ProfileCompletionView> {
  String? _selectedGender;
  DateTime? _selectedDate;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); // 添加控制器

  // 选择性别
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // 选择出生日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // 格式化日期并更新日期控制器的文本
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: media.height * 0.05), // 顶部间距
                const Text(
                  "Let's complete your profile",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "It will help us to know more about you!",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: media.height * 0.05), // 间距

                // 选择性别
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  hint: const Text("Choose Gender"),
                  items: _genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                ),
                SizedBox(height: media.height * 0.02), // 间距

                // 选择出生日期
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController, // 使用日期控制器
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                        border: OutlineInputBorder(),
                        hintText: "Select Date", // 可以设置为默认提示
                      ),
                    ),
                  ),
                ),
                SizedBox(height: media.height * 0.02), // 间距

                // 体重文本框
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: "Your Weight",
                    border: OutlineInputBorder(),
                    suffixText: "KG",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 限制为数字输入
                  ],
                ),
                SizedBox(height: media.height * 0.02), // 间距

                // 身高文本框
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: "Your Height",
                    border: OutlineInputBorder(),
                    suffixText: "CM",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 限制为数字输入
                  ],
                ),
                SizedBox(height: media.height * 0.05), // 间距

                // 下一步按钮
                ElevatedButton(
                  onPressed: () async {
                    // 执行注册逻辑
                    bool updateSuccess = await updateUserProfile(
                        _selectedGender!,
                        _dateController.text,
                        _weightController.text,
                        _heightController.text);

                    // 检查注册是否成功
                    if (updateSuccess) {
                      // 如果成功，跳转到个人资料完成页面，传递名字和姓氏
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WelcomeView(
                            username: 'user',
                          ),
                        ),
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registration failed")),
                        );
                      }
                      // 处理注册失败的情况，例如显示错误消息
                    }
                  },
                  child: const Text("Next"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
