import 'package:flutter/material.dart';
import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';
import 'package:practice_first_flutter_project/main.dart';
import 'package:intl/intl.dart';

class WeeklyRankingPage extends StatefulWidget {
  const WeeklyRankingPage({Key? key}) : super(key: key);

  @override
  _WeeklyRankingPageState createState() => _WeeklyRankingPageState();
}

class _WeeklyRankingPageState extends State<WeeklyRankingPage> {
  String _selectedTab = '글자예측';

  // 승리 수 데이터
  final List<Map<String, dynamic>> rankings = [
    {"rank": 1, "wins": 5, "participants": 34120, "percentage": 22.75},
    {"rank": 2, "wins": 4, "participants": 25394, "percentage": 16.93},
    {"rank": 3, "wins": 3, "participants": 13108, "percentage": 8.74},
    {"rank": 4, "wins": 2, "participants": 12157, "percentage": 8.10},
    {"rank": 5, "wins": 1, "participants": 10483, "percentage": 6.99},
    {"rank": 6, "wins": 0, "participants": 36338, "percentage": 24.19},
  ];

  String formatNumber(int number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        hasNotifications: notifications.isNotEmpty,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/images/weekly_ranking.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabButton('글자예측', Colors.orange),
                  _buildTabButton('십자말풀이', Colors.amber),
                  _buildTabButton('BINGO', Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Text(
                    '내 순위 2등',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '(150,000명 참여)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '히든글자는 4개를 획득했어요.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: rankings.map((ranking) {
                  final rank = ranking['rank'];
                  String? medalImage;
                  if (rank == 1) {
                    medalImage = 'assets/images/gold_medal.png';
                  } else if (rank == 2) {
                    medalImage = 'assets/images/silver_medal.png';
                  } else if (rank == 3) {
                    medalImage = 'assets/images/bronze_medal.png';
                  }

                  return ListTile(
                    leading: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          if (medalImage != null)
                            Image.asset(
                              medalImage,
                              width: 24,
                              height: 24,
                            ),
                          if (medalImage != null) const SizedBox(width: 8),
                          if (medalImage == null)
                            const SizedBox(width: 32),
                          Text(
                            '$rank등',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                              color: rank <= 3 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      '${ranking['wins']}승',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: rank == 2
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${formatNumber(ranking['participants'])}명',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Text(
                      '${ranking['percentage']}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildTabButton(String title, Color color) {
    final bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.7) : color,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.black, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: WeeklyRankingPage(),
  ));
}