import 'package:flutter/material.dart';

import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';

class TeamRecruitmentPage extends StatefulWidget {
  const TeamRecruitmentPage({super.key});

  @override
  _TeamRecruitmentPageState createState() => _TeamRecruitmentPageState();
}

class _TeamRecruitmentPageState extends State<TeamRecruitmentPage> {
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);

  final List<Map<String, dynamic>> teamList = [
    {
      'teamName': '박민주팀 모집',
      'memberCount': 5, // 현재 팀원의 수
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
      'joined': true, // 이미 가입된 팀
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

  static const int maxMembers = 6; // 모든 팀의 최대 인원
  String? selectedTeam; // 사용자가 가입한 팀

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
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _joinTeam(teamName); // 팀 가입
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

  void _showCreateTeamConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("팀 생성 확인"),
        content: Text("새로운 팀을 생성하시겠습니까?"),
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
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _createTeam(); // 팀 생성
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

  void _createTeam() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("새로운 팀이 생성되었습니다.")),
    );
    // 팀 생성 로직 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('십자말 풀이 팀 모집'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1.4,
                  child: Image.asset(
                    'assets/images/puzzleTitle.jpg', // 십자말 풀이 이미지
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Image.asset(
                    'assets/images/friends.png', // 친구들 이미지
                    width: MediaQuery.of(context).size.width * 0.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _showCreateTeamConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    '팀 생성',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ...teamList.map((team) {
            final isJoined = selectedTeam == team['teamName'];
            final isFull = team['memberCount'] == maxMembers;

            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  color: Colors.amber[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team['teamName'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: List.generate(maxMembers, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: index < team['memberCount']
                                        ? Icon(Icons.person_outline_sharp
                                            // isJoined
                                            //     ? Icons.check_circle
                                            //     : Icons.person,
                                            // color: isJoined
                                            //     ? Colors.green
                                            //     : Colors.black,
                                            )
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${team['memberCount']}/$maxMembers 명',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
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
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
