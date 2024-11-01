//calorie_ranking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getTopCaloriesLeaderboard() async {
  try {
    DateTime now = DateTime.now();
    DateTime startOfSevenDaysAgo = now.subtract(const Duration(days: 6));
    DateTime startOfToday = DateTime(now.year, now.month, now.day);

    // 获取所有用户的引用
    QuerySnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> leaderboard = [];

    // 遍历每个用户的文档
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      String userId = userDoc.id;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userName =
          userData['name'] ?? 'Unknown'; // 获取用户的 name 字段，如果不存在则默认为 'Unknown'

      // 获取用户的 calorieRecords 子集合的引用
      CollectionReference calorieRecords = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calorieRecords');

      // 查询最近七天的所有卡路里记录
      QuerySnapshot snapshot = await calorieRecords
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfSevenDaysAgo))
          .where('date',
              isLessThanOrEqualTo:
                  Timestamp.fromDate(startOfToday.add(const Duration(days: 1))))
          .get();

      // 计算用户七天的卡路里消耗总和
      double totalCalories = 0.0;
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalCalories += data['calories'] ?? 0.0;
      }
      if (totalCalories > 0.0) {
        leaderboard.add({
          'userId': userId,
          'userName': userName,
          'totalCalories': totalCalories,
        });
      }
      // 将用户的总卡路里消耗、userId 和 name 添加到 leaderboard
    }

    // 根据卡路里总和降序排序，获取前十名
    leaderboard
        .sort((a, b) => b['totalCalories'].compareTo(a['totalCalories']));
    return leaderboard.take(8).toList();
  } catch (e) {
    print('Error getting leaderboard: $e');
    return [];
  }
}
