// home_view.dart
import 'dart:async';
import 'dart:io';

// import 'dart:ffi';
import 'package:intl/intl.dart';
import 'package:fitness/common/authentication.dart';
import 'package:fitness/common/calorie_ranking.dart';
import 'package:fitness/common/running_history.dart';
import 'package:fitness/common/photo_result_view.dart';
import 'package:fitness/common/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:fitness/view/personinfo/profile_view.dart'; // 确保导入 ProfileView
import 'package:fitness/view/run/running_page.dart';
import 'package:fitness/view/rank/rank_view.dart'; // 导入 RankView 页面
import 'package:fl_chart/fl_chart.dart';

import '../../common/colo_extension.dart'; // 导入 fl_chart

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const platform = MethodChannel('com.example.light_sensor/brightness');
  final TextEditingController _targetController = TextEditingController();
  double _brightness = 0.5;
  Timer? _timer;
  Map<String, dynamic>? userData;
  double todayCalories = 0.0;
  bool isLoading = true;

  List<Map<String, dynamic>> leaderboardData = [];
  Map<String, double> lastSevenDaysCalories = {};

  File? _selectedImage; // Declare _selectedImage here

  @override
  void initState() {
    super.initState();
    loadUserData();
    _startMonitoringBrightness();
  }

  void _startMonitoringBrightness() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _getLightSensorData();
      await _setScreenBrightness();
    });
  }

  Future<void> _setScreenBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(_brightness);
    } catch (e) {
      print("Cannot set screen brightness: $e");
    }
  }

  Future<void> _getLightSensorData() async {
    try {
      final double lightIntensity =
          await platform.invokeMethod('getLightIntensity');
      setState(() {
        _brightness = _calculateBrightness(lightIntensity);
      });
    } on PlatformException catch (e) {
      print("Cannot get light intensity: '${e.message}'");
    }
  }

  double _calculateBrightness(double lightIntensity) {
    double result = (lightIntensity / 1000) + 0.2;
    return result > 1.0 ? 1.0 : result;
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? data = await checkUserAndLoadData(context);
    double calories = await getTodayCalorieConsumption(data!['uid']);
    Map<String, double> lastSevenDaysCalories =
        await getLastSevenDaysCalorieConsumption(data['uid']);
    setState(() {
      userData = data;
      isLoading = false;
      todayCalories = calories;
      this.lastSevenDaysCalories = lastSevenDaysCalories;
    });
  }

  @override
  void dispose() {
    _targetController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 头像和用户名部分
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileView(
                                username: userData?['name'] ?? 'Username',
                                initialHeight: userData?['height'] ?? '0.0',
                                initialWeight: userData?['weight'] ?? '0.0',
                                initialTargetCalories:
                                    userData?['targetCalories'] ?? '0.00',
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              // 如果返回值为 true，则执行刷新数据逻辑
                              setState(() {
                                isLoading = true;
                              });
                              loadUserData();
                            }
                          });
                        },
                        child: const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 40),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        userData?['name'] ?? 'Username',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // 排行榜按钮
                  IconButton(
                    icon: const Icon(Icons.leaderboard, size: 30),
                    onPressed: () async {
                      List<Map<String, dynamic>> topTen =
                          await getTopCaloriesLeaderboard();
                      // 导航到 RankView 并将排行榜数据传递给它
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RankView(leaderboard: topTen),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Calories(kcal)',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleCard('Target', userData!['targetCalories']),
                    _buildCircleCard(
                        'Burned', todayCalories.round().toString()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Exercises',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildExerciseCircle('Running', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RunningPage()),
                      ).then((value) {
                        if (value == true) {
                          // 如果返回值为 true，则执行刷新数据逻辑
                          setState(() {
                            isLoading = true;
                          });
                          loadUserData();
                        }
                      });
                    }),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 22.0), // 控制 Text 的左边距
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF75AF86),
                        Color(0xFF5c899c),
                      ],
                    ),
                  ),
                  height: 200,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.transparent,
                      minY: 0,
                      maxY: 2500,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 99, 93, 93),
                              width: 0.5),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateSpots(lastSevenDaysCalories),
                          isCurved: false,
                          colors: [const Color.fromARGB(255, 247, 234, 234)],
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 2,
                              color: const Color.fromARGB(255, 247, 234, 234),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            colors: [
                              const Color.fromARGB(255, 250, 236, 236)
                                  .withOpacity(0.3)
                            ],
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTextStyles: (value) => const TextStyle(
                            color: Color.fromARGB(255, 247, 234, 234),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          getTitles: (value) {
                            List<String> sortedKeys =
                                lastSevenDaysCalories.keys.toList()..sort();
                            if (value.toInt() >= 0 &&
                                value.toInt() < sortedKeys.length) {
                              return _formatDate(
                                  sortedKeys[value.toInt()]); // 显示月-日
                            }
                            return '';
                          },
                          margin: 8,
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipRoundedRadius: 8,
                          tooltipMargin: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              return LineTooltipItem(
                                '${touchedSpot.x.toInt()}, ${touchedSpot.y.toInt()}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildSection(
                title: 'Calorie Estimation',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final selectedImage = await Navigator.push<File?>(
                          context,
                          MaterialPageRoute(builder: (context) => PhotoPicker()),
                        );

                        if (selectedImage != null) {
                          // Navigate to the new result view and pass the selected image
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PhotoResultView(imageFile: selectedImage),
                            ),
                          );
                        }
                      },
                      child: const Text("Upload Food Photo"),
                    ),
                  ],
                ),
              ),

              // In the ElevatedButton in HomeView:
              /*ElevatedButton(
                onPressed: () async {
                  final selectedImage = await Navigator.push<File?>(
                    context,
                    MaterialPageRoute(builder: (context) => PhotoPicker()),
                  );

                  if (selectedImage != null) {
                    // Navigate to the new result view and pass the selected image
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoResultView(imageFile: selectedImage),
                      ),
                    );
                  }
                },
                child: const Text("Upload Food Photo"),
              ),*/

              // ElevatedButton(
              //   onPressed: () async {
              //     List<Map<String, dynamic>> topTen =
              //         await getTopCaloriesLeaderboard();
              //     setState(() {
              //       leaderboardData = topTen;
              //     });
              //     // 打印排行榜数据到控制台进行调试
              //     leaderboardData.forEach((entry) {
              //       print(
              //           'User Name: ${entry['userName']}, Total Calories: ${entry['totalCalories']}');
              //     });
              //   },
              //   child: Text('Get Calorie Leaderboard'),
              // ),
              // ElevatedButton(
              //   onPressed: () async {
              //     double calories =
              //         await getTodayCalorieConsumption(userData!['uid']);
              //     setState(() {
              //       todayCalories = calories;
              //     });
              //   },
              //   child: Text(
              //       'Today\'s Calories: ${todayCalories.toStringAsFixed(2)}'),
              // ),
              // ElevatedButton(
              //   onPressed: () async {
              //     Map<String, double> calories =
              //         await getLastSevenDaysCalorieConsumption(
              //             userData!['uid']);
              //     setState(() {
              //       lastSevenDaysCalories = calories;
              //     });
              //     lastSevenDaysCalories.forEach((date, calorie) {
              //       print(
              //           'Date: $date, Calories: ${calorie.toStringAsFixed(2)}');
              //     });
              //   },
              //   child: const Text('Get Last 7 Days Calories'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(Map<String, double> data) {
    List<String> sortedKeys = data.keys.toList()..sort(); // 按日期升序排序
    List<FlSpot> spots = [];

    for (int i = 0; i < sortedKeys.length; i++) {
      String key = sortedKeys[i];
      double value = data[key] ?? 0.0; // 处理可能为空的情况
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('MM-dd').format(date); // 只显示月-日
  }

  Widget _buildCircleCard(String label, String value) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildExerciseCircle(String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.fitness_center, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Tcolor.pageG, // 传入颜色列表
         ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}
