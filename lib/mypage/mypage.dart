import 'package:flutter/material.dart';
import 'package:practice_first_flutter_project/widgets/app_above_bar.dart'; // CustomAppBar가 정의된 파일
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart'; // CustomBottomNavigationBar가 정의된 파일
import 'package:practice_first_flutter_project/bingo_main.dart'; // bingo_main.dart 파일을 불러옴
import 'package:practice_first_flutter_project/combination_words.dart'; // CombinationWordsPage 파일을 불러옴

class MyPage extends StatelessWidget {
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
                    '호랑깍두기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildStatBox('100,000', '포인트리')),
                  SizedBox(width: 10),
                  Expanded(child: _buildStatBox('3', '빙고 level')),
                  SizedBox(width: 10),
                  Expanded(child: _buildStatBoxWithImage('assets/images/newbie.png', '뉴비')),
                ],
              ),
              SizedBox(height: 20),
              _buildWordRow(['인', '킹', '도', '주', '하', '올']),
              SizedBox(height: 20),
              _buildOptionsBox(context), // 단어 조합하기와 프로필 수정을 포함한 박스
              SizedBox(height: 30),
              _buildBingoSection(context), // 수정된 빙고 섹션
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
            children: words
                .map(
                  (word) => CircleAvatar(
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
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsBox(BuildContext context) { // context를 전달받음
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
                    text: '8개',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' 보유)'),
                ],
                style: TextStyle(fontSize: 16), // 기본 스타일
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 단어 조합하기 페이지로 이동
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
          // PayGO! BINGO! 이미지와 남은 빙고 텍스트를 함께 배치
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
                  '남은 빙고 : 1빙고',
                  style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // 남은 글자 제목
          Text(
            '남은 글자',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // 남은 글자 아이콘들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['템', '템', '템', '템', '템'].map((letter) {
              return Container(
                width: 50, // 정사각형을 위해 가로 세로 고정
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(10), // 둥근 네모 스타일
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
          // 참여 가능한 미션 제목과 내용
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
          SizedBox(height: 5),
          // 빙고 완성하러 가기 버튼
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BingoMain()), // bingo_main.dart로 이동
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '빙고 완성하러 가기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}