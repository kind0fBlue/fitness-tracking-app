// running_page.dart
import 'dart:async'; // 导入异步支持库
import 'package:fitness/common/authentication.dart';
import 'package:fitness/common/running_history.dart';
import 'package:flutter/material.dart'; // 导入Flutter UI库
import 'package:geolocator/geolocator.dart'; // 导入地理定位库
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 导入Google地图Flutter插件
import 'package:pedometer/pedometer.dart'; // 导入计步器插件
import 'package:permission_handler/permission_handler.dart'; // 导入权限处理库

class RunningPage extends StatefulWidget {
  const RunningPage({super.key});

  @override
  _RunningPageState createState() => _RunningPageState(); // 创建状态
}

class _RunningPageState extends State<RunningPage> {
  GoogleMapController? _mapController; // 地图控制器，用于操作地图
  final List<LatLng> _routeCoordinates = []; // 跑步路径的坐标列表
  double _totalDistance = 0.0; // 跑步总距离（米）
  double _currentSpeed = 0.0; // 当前速度（米/秒）
  final Stopwatch _stopwatch = Stopwatch(); // 秒表，用于计时
  Timer? _timer; // 定时器，用于更新时间显示
  String _formattedTime = "00:00:00"; // 格式化后的时间字符串
  int _stepCount = 0; // 步数计数
  double _caloriesBurned = 0.0; // 消耗的卡路里
  int _initialStepCount = 0;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  StreamSubscription<Position>? _positionStreamSubscription; // 位置流订阅
  StreamSubscription<StepCount>? _pedometerSubscription; // 计步器订阅

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((granted) {
      if (granted) {
        // 在请求权限之后再进行初始化，确保权限已经被授予
        _initializePedometer(); // 初始化计步器
        _startTracking(); // 开始位置跟踪
        _startStopwatch(); // 开始计时
        loadUserData();
      }
    });
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? data = await checkUserAndLoadData(context);

    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  // 请求必要的权限
  Future<bool> _requestPermissions() async {
    // 请求位置权限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // 如果权限被永久拒绝，提示用户手动开启
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // 请求活动识别权限（计步器需要）
    PermissionStatus activityStatus =
        await Permission.activityRecognition.request();
    if (activityStatus != PermissionStatus.granted) {
      // 如果权限未授予，打印提示信息
      print('Activity Recognition Permission Denied');
      return false;
    }

    return true; // 如果所有权限都已授予
  }

  void _initializePedometer() {
    Pedometer.stepCountStream.first.then((StepCount event) {
      setState(() {
        _initialStepCount = event.steps; // 获取初始步数
      });
      // 订阅步数流
      _pedometerSubscription = Pedometer.stepCountStream.listen(
        _onStepCount, // 当步数更新时的回调
        onError: _onStepCountError, // 当发生错误时的回调
        cancelOnError: true, // 发生错误时取消订阅
      );
    }).catchError((error) {
      // 处理错误
      print('Pedometer error: $error');
    });
  }

  // 当步数更新时的回调函数
  void _onStepCount(StepCount event) {
    setState(() {
      if (_initialStepCount == 0) {
        // 记录第一次获取到的步数为初始步数
        _initialStepCount = event.steps;
      }
      _stepCount = event.steps - _initialStepCount; // 计算相对变化的步数
      _caloriesBurned = _calculateCalories(_stepCount); // 计算消耗的卡路里
    });
  }

  // 计算消耗的卡路里
  double _calculateCalories(int steps) {
    const double caloriesPerStep = 0.04; // 每步消耗的卡路里（估计值）
    return steps * caloriesPerStep; // 总消耗的卡路里
  }

  // 当计步器发生错误时的回调函数
  void _onStepCountError(error) {
    print('Pedometer Error: $error'); // 打印错误信息
  }

  // 开始位置跟踪
  Future<void> _startTracking() async {
    // 检查位置服务是否启用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 如果位置服务未启用，打印提示信息
      print('Location services are disabled.');
      return;
    }

    // 定义位置更新设置
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, // 高精度
      distanceFilter: 5, // 每移动5米更新一次
    );

    // 订阅位置更新流
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      // 获取当前位置的经纬度
      final LatLng currentLocation =
          LatLng(position.latitude, position.longitude);

      // 如果已有坐标点，计算与上一个点的距离和速度
      if (_routeCoordinates.isNotEmpty) {
        // 使用 Geolocator 的方法计算两点之间的距离
        double distance = Geolocator.distanceBetween(
          _routeCoordinates.last.latitude,
          _routeCoordinates.last.longitude,
          currentLocation.latitude,
          currentLocation.longitude,
        );
        _totalDistance += distance; // 累加总距离
        _currentSpeed = position.speed; // 更新当前速度（米/秒）
      }

      setState(() {
        _routeCoordinates.add(currentLocation); // 添加当前坐标到路径列表
      });

      // 更新地图中心点到当前位置
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLocation),
        );
      }
    });
  }

  // 开始计时器
  void _startStopwatch() {
    _stopwatch.start(); // 启动秒表
    // 每秒更新一次界面显示的时间
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _formattedTime = _formatElapsedTime(_stopwatch.elapsed); // 格式化时间
      });
    });
  }

  // 格式化时间为 HH:MM:SS 格式
  String _formatElapsedTime(Duration elapsed) {
    String hours = elapsed.inHours.toString().padLeft(2, '0'); // 小时
    String minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0'); // 分钟
    String seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0'); // 秒
    return "$hours:$minutes:$seconds"; // 返回格式化的时间字符串
  }

  @override
  void dispose() {
    _timer?.cancel(); // 取消计时器
    _stopwatch.stop(); // 停止秒表
    _pedometerSubscription?.cancel(); // 取消计步器订阅
    _positionStreamSubscription?.cancel(); // 取消位置订阅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 创建数据行的小部件
    Widget _buildDataRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Running Tracker"), // 应用栏标题
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center, // 地图居中显示
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 四周添加边距
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9, // 设置地图宽度为屏幕宽度的90%
                  height: MediaQuery.of(context).size.height * 0.5, // 设置地图高度为屏幕高度的50%
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _routeCoordinates.isNotEmpty
                          ? _routeCoordinates.last // 如果有坐标点，设置地图中心为最新位置
                          : const LatLng(37.7749, -122.4194), // 否则设置为默认位置
                      zoom: 15, // 缩放级别
                    ),
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('running_route'), // 路径的唯一标识
                        points: _routeCoordinates, // 路径的坐标点列表
                        color: Colors.blue, // 路径颜色
                        width: 5, // 路径宽度
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller; // 地图创建完成后获取控制器
                    },
                    myLocationEnabled: true, // 显示当前位置
                    myLocationButtonEnabled: true, // 显示定位按钮
                  ),
                ),
              ),
            ),

            // 显示跑步数据
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 20), // 上方空白
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // 阴影位置
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDataRow("Distance", "${(_totalDistance / 1000).toStringAsFixed(2)} km"),
                        _buildDataRow("Speed", "${(_currentSpeed * 3.6).toStringAsFixed(2)} km/h"),
                        _buildDataRow("Time", _formattedTime),
                        _buildDataRow("Steps", "$_stepCount"),
                        _buildDataRow("Calories Consumption", "${_caloriesBurned.toStringAsFixed(2)} kcal"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // 间距
                  ElevatedButton(
                    onPressed: () {
                      _stopwatch.stop(); // 停止计时
                      _timer?.cancel(); // 取消定时器
                      _pedometerSubscription?.cancel(); // 取消计步器订阅
                      _positionStreamSubscription?.cancel(); // 取消位置订阅
                      addCalorieRecord(userData!['uid'], _caloriesBurned, DateTime.now());
                      _showTotalStats(); // 显示跑步统计数据
                    },
                    child: const Text("Stop Running"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  // 显示跑步统计数据的对话框
  void _showTotalStats() {
    // 存储外部的 BuildContext
    BuildContext outerContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Running Summary"), // 对话框标题
          content: Text(
              "Distance：${(_totalDistance / 1000).toStringAsFixed(2)} km\n"
              "Average Speed：${(_totalDistance / _stopwatch.elapsed.inSeconds * 3.6).toStringAsFixed(2)} km/h\n"
              "Time：$_formattedTime\n"
              "Steps：$_stepCount\n"
              "Calories Consumption：${_caloriesBurned.toStringAsFixed(2)} kcal"),
          actions: [
            TextButton(
              child: const Text("Confirm"), // 按钮文本
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 关闭对话框
                Navigator.of(outerContext).pop(true); // 返回上一个页面
              },
            ),
          ],
        );
      },
    );
  }
}
