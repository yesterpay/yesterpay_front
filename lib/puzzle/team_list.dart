import 'package:flutter/material.dart';

import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';

class TeamRecruitmentPage extends StatefulWidget {
  const TeamRecruitmentPage({super.key});

  @override
  _TeamRecruitmentPageState createState() => _TeamRecruitmentPageState();
}

class _TeamRecruitmentPageState extends State<TeamRecruitmentPage> {
  int currentIndex = 1;
  final Color emissionBtnColor = Color(0xFFFAB809);
  final Color cancelBtnColor = Color(0xFF6E6053);

  final List<Map<String, dynamic>> teamList = [
    {
      'teamName': '박민주팀 모집',
      'memberCount': 5,
      'joined': false,
    },
    {
      'teamName': '정인겸팀 모집',
      'memberCount': 4,
      'joined': false,
    },
    {
      'teamName': '한가연팀 모집',
      'memberCount': 5,
      'joined': true,
    },
    {
      'teamName': '김민지팀 모집',
      'memberCount': 5,
      'joined': false,
    },
    {
      'teamName': '조성혁팀 모집',
      'memberCount': 5,
      'joined': false,
    },
  ];

  static const int maxMembers = 6;
  String? selectedTeam;

  void _showJoinConfirmationDialog(BuildContext context, String teamName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("팀 가입 확인"),
        content: Text("정말 $teamName에 가입하시겠습니까?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: cancelBtnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "취소",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _joinTeam(teamName);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: emissionBtnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("확인"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _joinTeam(String teamName) {
    setState(() {
      selectedTeam = teamName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 양옆 배치
                  Positioned(
                    left: 30,
                    child: Transform.scale(
                      scale: 1.7,
                      child: Image.asset(
                        'assets/images/puzzleTitle.png',
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 40,
                    child: Transform.scale(
                      scale: 1.35,
                      child: Image.asset(
                        'assets/images/friends.png',
                        width: MediaQuery.of(context).size.width * 0.45,
                      ),
                    ),
                  ),
                  // 위치를 조정하려면 Align이나 Padding을 사용
                ],
              ),
            ),
            // 팀 생성 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    '팀 생성',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            // 팀 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: teamList.length,
              itemBuilder: (context, index) {
                final team = teamList[index];
                final isJoined = selectedTeam == team['teamName'];
                final isFull = team['memberCount'] == maxMembers;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  child: Card(
                    color: Colors.amber[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              team['teamName'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(
                              maxMembers,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: index < team['memberCount']
                                      ? Icon(Icons.person_outline)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${team['memberCount']}/$maxMembers 명',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: isJoined || isFull
                                    ? null
                                    : () => _showJoinConfirmationDialog(
                                          context,
                                          team['teamName'],
                                        ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isJoined ? Colors.grey : Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  isJoined
                                      ? '신청완료'
                                      : isFull
                                          ? '팀 가득참'
                                          : '가입신청',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
      ),
    );
  }
}
