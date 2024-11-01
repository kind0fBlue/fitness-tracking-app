// running_history.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addCalorieRecord(
    String userId, double calories, DateTime date) async {
  try {
    // 获取用户的 calorieRecords 子集合的引用
    CollectionReference calorieRecords = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('calorieRecords');

    // 创建一个新文档，并添加卡路里记录
    await calorieRecords.add({
      'calories': calories,
      'date': date,
    });

    print('Calorie record added successfully');
  } catch (e) {
    print('Error adding calorie record: $e');
  }
}

Future<double> getTodayCalorieConsumption(String userId) async {
  try {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    CollectionReference calorieRecords = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('calorieRecords');

    QuerySnapshot snapshot = await calorieRecords
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double totalCalories = 0.0;
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double calories = data['calories'] ?? 0.0;
      totalCalories += calories;
    }

    return totalCalories;
  } catch (e) {
    print('Error getting today\'s calorie intake: $e');
    return 0.0;
  }
}

Future<Map<String, double>> getLastSevenDaysCalorieConsumption(
    String userId) async {
  try {
    // 获取今天的日期和七天前的开始时间
    DateTime now = DateTime.now();
    DateTime startOfSevenDaysAgo = now.subtract(const Duration(days: 6));
    DateTime startOfToday = DateTime(now.year, now.month, now.day);

    // 获取用户的 calorieRecords 子集合的引用
    CollectionReference calorieRecords = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('calorieRecords');

    // 查询过去七天的所有卡路里记录
    QuerySnapshot snapshot = await calorieRecords
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfSevenDaysAgo))
        .where('date',
            isLessThanOrEqualTo:
                Timestamp.fromDate(startOfToday.add(const Duration(days: 1))))
        .get();

    // 定义一个 Map 来存储过去七天的卡路里消耗
    Map<String, double> dailyCalories = {
      for (int i = 0; i < 7; i++)
        DateTime(now.year, now.month, now.day - i).toString().split(' ')[0]: 0.0
    };

    // 遍历所有文档并累加卡路里
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Timestamp timestamp = data['date'];
      DateTime date = timestamp.toDate();

      // 将日期格式化为 yyyy-MM-dd 的字符串
      String dateString = '${date.year}-${date.month}-${date.day}';

      // 累加每一天的卡路里消耗
      if (dailyCalories.containsKey(dateString)) {
        dailyCalories[dateString] =
            dailyCalories[dateString]! + (data['calories'] ?? 0.0);
      }
    }

    return dailyCalories;
  } catch (e) {
    print('Error getting last seven days calorie intake: $e');
    return {};
  }
}

Future<void> setUserTargetCalories(String userId, double targetCalories) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'targetCalories': targetCalories,
    }, SetOptions(merge: true)); // merge: true 确保保留其他字段
    print('Target calories set successfully');
  } catch (e) {
    print('Error setting target calories: $e');
  }
}
