import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart'; // CustomBottomNavigationBar가 정의된 파일
import 'package:practice_first_flutter_project/bingo_main.dart';
import 'package:practice_first_flutter_project/combination_words.dart'; // CombinationWordsPage 파일을 불러옴
import '../NotificationController.dart';
import '../main.dart'; // bingo_main.dart 파일을 불러옴
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String nickName = '로딩 중...';
  String point = '로딩 중...';
  String bingoLevel = '로딩 중...';
  String combiCount = '로딩 중...';
  String title = '로딩 중...';
  String requiredBingoCount = '로딩 중...';
  List<String> letters = [];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    fetchMemberData();
    fetchLetters();
    fetchBingoLevel();
    fetchRequiredBingoCount();
  }

  Future<void> fetchMemberData() async {
    try {
      final response = await http.get(Uri.parse('http://3.34.102.55:8080/member/1'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        print('Response Data: $data');

        setState(() {
          nickName = data['nickName'] ?? '닉네임 없음';
          point = data['point']?.toString() ?? '0';
          combiCount = data['combiCount']?.toString() ?? '0';
          title = data['title']?.toString() ?? '0';
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          nickName = '닉네임 불러오기 실패';
          point = '0';
          combiCount = '0';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        nickName = '예외 발생';
        point = '0';
        combiCount = '0';
      });
    }
  }

  Future<void> fetchLetters() async {
    try {
      final response = await http.get(Uri.parse('http://3.34.102.55:8080/member/1/letter'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List;
        print('Letters Response Data: $data');

        setState(() {
          // API 응답 데이터를 리스트로 저장
          letters = data.map((item) => item.toString()).toList();
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          letters = [];
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        letters = [];
      });
    }
  }

  Future<void> fetchBingoLevel() async {
    try {
      final response = await http.get(Uri.parse('http://3.34.102.55:8080/bingo/board?memberId=1'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        print('Bingo Level Response Data: $data');

        setState(() {
          bingoLevel = data['level']?.toString() ?? '0'; // 빙고 레벨 값 저장
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          bingoLevel = '0';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        bingoLevel = '0';
      });
    }
  }

  Future<void> fetchRequiredBingoCount() async {
    try {
      final response = await http.get(Uri.parse('http://3.34.102.55:8080/bingo/status?memberId=1'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        print('Required Bingo Count Response Data: $data');

        setState(() {
          requiredBingoCount = data['requiredBingoCount']?.toString() ?? '0'; // 남은 빙고 수 값 저장
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          requiredBingoCount = '0';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        requiredBingoCount = '0';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFFF8F6F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/profile_image.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nickName, // API에서 가져온 nick_name 표시
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildStatBox(point, '포인트리')), // 포인트리 값
                  SizedBox(width: 10),
                  Expanded(child: _buildStatBox(bingoLevel, '빙고 level')), // 빙고 레벨 값
                  SizedBox(width: 10),
                  Expanded(child: _buildStatBoxWithImage('assets/images/newbie.png', title)),
                ],
              ),
              SizedBox(height: 20),
              _buildWordRow(letters), // 보유 글자 표시
              SizedBox(height: 20),
              _buildOptionsBox(context), // 단어 조합하기와 프로필 수정을 포함한 박스
              SizedBox(height: 30),
              _buildBingoSection(context), // 빙고 섹션
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4), // 하단 네비게이션 바
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBoxWithImage(String imagePath, String label) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWordRow(List<String> words) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 단어',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: words.map((word) {
              return CircleAvatar(
                backgroundColor: Color(0xFF9E7E49),
                radius: 20,
                child: Text(
                  word,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '단어 조합하기 ('),
                  TextSpan(
                    text: '$combiCount개', // combiCount 값을 동적으로 표시
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' 보유)'),
                ],
                style: TextStyle(fontSize: 16), // 기본 스타일
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CombinationWordsPage(),
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
          ListTile(
            title: Text('프로필 수정하기'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 프로필 수정 페이지로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBingoSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Paygo_Bingo.png',
                  width: 300,
                  height: 100,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '남은 빙고 : $requiredBingoCount빙고',
                  style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '남은 글자',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: letters.map((letter) {
              return Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B5E00),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            '참여 가능한 미션',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• KB 스타적금 II 상품 가입하기', style: TextStyle(fontSize: 14)),
              Text('• KB 부동산 APP 설치하기', style: TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}