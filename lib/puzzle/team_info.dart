import 'package:flutter/material.dart';

// import '/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';
import 'team_list.dart';

class TeamMember {
  final String name;
  final String role;
  final bool isLeader;
  final List<String> hiddenLetters;

  TeamMember(
      {required this.name,
      required this.role,
      required this.isLeader,
      required this.hiddenLetters});

  // JSON 데이터를 TeamMember 객체로 변환하는 factory 생성자
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      name: json['name'],
      role: json['role'],
      isLeader: json['isLeader'],
      hiddenLetters: List<String>.from(json['hiddenLetters']),
    );
  }
}

class TeamInfoPage extends StatefulWidget {
  const TeamInfoPage({super.key});

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  late Future<List<TeamMember>> futureTeamMembers;
  final bool isLeader = true; // 현재 사용자가 팀장인지 여부
  final String leaderName = '김킥긱'; // 팀장의 이름 (예시)
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);

  @override
  void initState() {
    super.initState();
    futureTeamMembers = fetchTeamMembers();
  }

  // 서버에서 팀원 정보를 가져오는 함수 (예제용 비동기 함수)
  Future<List<TeamMember>> fetchTeamMembers() async {
    await Future.delayed(
        Duration(seconds: 1)); // 데이터를 가져오는 데 시간이 걸리는 것처럼 딜레이 추가
    // 이 부분을 실제 API 요청으로 대체해야 합니다.
    return [
      TeamMember(
          name: '김킥긱',
          role: '팀장',
          isLeader: true,
          hiddenLetters: ['김', '팀', '장']),
      TeamMember(
          name: '이시시',
          role: '은행원1',
          isLeader: false,
          hiddenLetters: ['이', '은', '행', '원']),
      TeamMember(
          name: '박민주',
          role: '은행원2',
          isLeader: false,
          hiddenLetters: ['박', '은', '행', '원']),
    ];
  }

  void _removeMember(TeamMember member) {
    setState(() {
      futureTeamMembers = Future.value(futureTeamMembers.then((members) =>
          members.where((m) => m != member).toList())); // 멤버 삭제 후 갱신
    });
  }

  void _showConfirmDialog(TeamMember member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 방출'),
          content: Text('${member.name} 회원님을 방출하시겠습니까?'),
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
                    style: TextButton.styleFrom(
                      backgroundColor: cancelBtnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 창 닫기
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 100,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: emissionBtnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text('확인'),
                    onPressed: () {
                      _removeMember(member);
                      Navigator.of(context).pop(); // 모달 창 닫기
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _performExit() async {
    // 탈퇴 처리 로직 (예시)
    await Future.delayed(Duration(seconds: 1)); // 비동기 작업 시뮬레이션

    if (mounted) {
      // 화면 전환
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeamRecruitmentPage()),
      ).then((_) {
        // 화면 전환 후 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀에서 탈퇴되었습니다.')),
        );
      });
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('팀 탈퇴'),
          content: Text('탈퇴하시겠습니까?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 취소 버튼
                SizedBox(
                  width: 100,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: cancelBtnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 창 닫기
                    },
                  ),
                ),
                SizedBox(width: 10),
                // 확인 버튼
                SizedBox(
                  width: 100,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: emissionBtnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 닫기
                      _performExit(); // 탈퇴 실행 메서드 호출
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<TeamMember>>(
        future: futureTeamMembers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('팀원 정보가 없습니다.'));
          } else {
            final members = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isSelf = member.name == leaderName;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            // 투명 배경의 Container
                            Container(
                              color: Colors
                                  .transparent, // 감싸는 Container의 배경을 투명하게 설정
                              child: Column(
                                children: [
                                  // 프로필 이미지와 이름 부분
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.brown[200], // 프로필과 이름 부분의 배경색
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          child: Transform.scale(
                                            scale: 0.8,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.amber.withOpacity(0),
                                              backgroundImage: AssetImage(
                                                  'assets/images/Popcorn.png'),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          member.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        if (isLeader && !isSelf)
                                          ElevatedButton(
                                            onPressed: () {
                                              _showConfirmDialog(
                                                  member); // 방출 확인 모달 창 호출
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  emissionBtnColor, // 방출 버튼의 배경색
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            child: Text(
                                              '방출',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // 보유 글자 부분
                                  Transform.translate(
                                    offset: Offset(0, -5),
                                    child: Container(
                                      height: 70,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.grey[200], // 보유 글자 부분의 배경색
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        children:
                                            member.hiddenLetters.map((char) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Colors.amber,
                                              child: Text(
                                                char,
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // 그림자 색상 및 투명도
                        offset: Offset(0, -3), // 위쪽에만 그림자 적용
                        blurRadius: 6, // 그림자의 흐림 정도
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.of(context).pop();
                      _showExitDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emissionBtnColor,
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '팀 탈퇴하기',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
      ), // 메인 하단바와 동일하게 유지
    );
  }
}
