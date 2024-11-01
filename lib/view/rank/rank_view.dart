// rank_view.dart
import 'package:flutter/material.dart';

class RankView extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const RankView({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    // 对用户数据进行排序

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Ranking'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'), // 显示排名
            ),
            title: Text(user['userName']),
            subtitle: Text(
                'Calories: ${user['totalCalories'].round().toString()} kcal'),
            trailing:
                const Icon(Icons.local_fire_department, color: Colors.red),
          );
        },
      ),
    );
  }
}
