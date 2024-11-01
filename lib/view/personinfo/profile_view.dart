// profile_view.dart
import 'package:fitness/common/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileView extends StatefulWidget {
  final String username;
  final String initialHeight;
  final String initialWeight;
  final String initialTargetCalories;

  const ProfileView({
    super.key,
    required this.username,
    required this.initialHeight,
    required this.initialWeight,
    required this.initialTargetCalories,
  });

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  bool _isEditing = false;
  bool _edited = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _heightController.text = widget.initialHeight;
    _weightController.text = widget.initialWeight;
    _caloriesController.text = widget.initialTargetCalories;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      await _saveChanges();
      setState(() {
        _edited = true;
      });
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      await updateUserProfileCalories(
        _heightController.text,
        _weightController.text,
        _caloriesController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          Navigator.pop(context, true);
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            title: Text('${widget.username}\'s Profile'),
            actions: [
              IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () async {
                    await _toggleEdit();
                  }),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction, // 自动验证模式
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color.fromRGBO(207, 143, 207, 1.0),
                        child:
                            Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEditableCard('Height', _heightController),
                      Container(
                        width: 1, // 宽度为 1，表示竖线的宽度
                        height: 50, // 竖线的高度
                        color: Colors.grey[300], // 浅灰色
                      ),
                      _buildEditableCard('Weight', _weightController),
                      Container(
                        width: 1, // 宽度为 1，表示竖线的宽度
                        height: 50, // 竖线的高度
                        color: Colors.grey[300], // 浅灰色
                      ),
                      _buildEditableCard('Calories', _caloriesController),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        logoutUser(context);
                      },
                      child: const Text('Log out current user'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildEditableCard(String label, TextEditingController controller) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          _isEditing
              ? SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      } else if (int.tryParse(value) == null) {
                        return 'Enter numbers only';
                      }
                      return null;
                    },
                  ),
                )
              : Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }
}
