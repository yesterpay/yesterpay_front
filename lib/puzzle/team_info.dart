import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

// import '/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';
import 'team_list.dart';

import '../main.dart';

class TeamMember {
  final String name;
  final String role;
  final bool isLeader;
  final List<String> hiddenLetters;
  final String imageUrl;

  TeamMember({
    required this.name,
    required this.role,
    required this.isLeader,
    required this.hiddenLetters,
    required this.imageUrl,
  });

  // JSON 데이터를 TeamMember 객체로 변환하는 factory 생성자
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      name: json['nickName'],
      role: json['title'],
      isLeader: json['master'],
      hiddenLetters: List<String>.from(json['letterList']),
      imageUrl:
          json['imgUrl'] ?? 'https://oimg1.kbstar.com/img/oabout/2021/bibi.png',
    );
  }
}

class TeamInfoPage extends StatefulWidget {
  const TeamInfoPage({super.key});

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  Future<List<TeamMember>>? futureTeamMembers;
  bool isLoading = true; // 로딩 상태 추가
  bool hasError = false; // 에러 상태 추가
  late int memberId;
  late int teamId;
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);

  @override
  void initState() {
    super.initState();
    final GlobalProvider pro = Get.find<GlobalProvider>();
    memberId = pro.getMemberId();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchMemberInfo(); // teamId 값을 초기화
      setState(() {
        futureTeamMembers = fetchTeamMembers(); // teamId 초기화 후 호출
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error initializing data: $e');
    }
  }

  Future<void> _fetchMemberInfo() async {
    const String serverUrl = 'http://3.34.102.55:8080/member'; // API 주소
    final url = Uri.parse('$serverUrl/$memberId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final memberInfo = jsonDecode(utf8.decode(response.bodyBytes));
        teamId = memberInfo['puzzleTeamId'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch member info')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching member info')),
      );
    }
  }

  Future<List<TeamMember>> fetchTeamMembers() async {
    final String serverUrl =
        'http://3.34.102.55:8080/puzzle/$teamId/member'; // 실제 API 주소
    final url = Uri.parse(serverUrl);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);

        final List<dynamic> data = jsonDecode(decodedResponse);
        print('fetchTeam $data');
        return data.map((json) => TeamMember.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load team members');
      }
    } catch (e) {
      throw Exception('Error fetching team members: $e');
    }
  }

  // void _removeMember(TeamMember member) {
  //   setState(() {
  //     futureTeamMembers = Future.value(futureTeamMembers.then((members) =>
  //         members.where((m) => m != member).toList())); // 멤버 삭제 후 갱신
  //   });
  // }

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
                      // _removeMember(member);
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
      appBar: CustomAppBar(
        hasNotifications: notifications.isNotEmpty, // 전역 변수 사용
      ),
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
            final leader = members.firstWhere((member) => member.isLeader,
                orElse: () => members[0]);
            final teamMembers =
                members.where((member) => !member.isLeader).toList();

            return Column(
              children: [
                // 팀장이 가장 먼저 나오도록
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[200],
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
                                              backgroundImage:
                                                  NetworkImage(member.imageUrl),
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
                                        if (!member.isLeader)
                                          ElevatedButton(
                                            onPressed: () {
                                              _showConfirmDialog(member);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: emissionBtnColor,
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
                                  Transform.translate(
                                    offset: Offset(0, -5),
                                    child: Container(
                                      height: 70,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
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
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, -3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _showExitDialog,
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
      ),
    );
  }

  Widget _buildMemberList(TeamMember member, {required bool isLeader}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.brown[200],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Transform.scale(
                          scale: 0.8,
                          child: CircleAvatar(
                            backgroundColor: Colors.amber.withOpacity(0),
                            backgroundImage: NetworkImage(member.imageUrl),
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
                      // 팀 리더가 아니고 팀원이 방출 버튼을 볼 수 있도록
                      if (!isLeader)
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmDialog(member);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: emissionBtnColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            '방출',
                            style: TextStyle(color: Colors.black),
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      children: member.hiddenLetters.map((char) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.amber,
                            child: Text(
                              char,
                              style: TextStyle(color: Colors.black),
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
  }
}
