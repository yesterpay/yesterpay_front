import 'dart:async';
import 'package:flutter/material.dart';
import 'package:practice_first_flutter_project/puzzle/puzzle.dart';
import 'package:practice_first_flutter_project/login/login.dart';
import 'bingo_main.dart';
import 'combination_words.dart';
import 'widgets/app_above_bar.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'hiddenword/hiddenword_prediction.dart';
import 'hiddenword/hiddenword_open.dart';
import 'package:http/http.dart' as http;

List<Map<String, dynamic>> notifications = [
  {
    'id': 1,
    'date': '24.10.31',
    'category': '가입',
    'title': '정인겸님이 가입신청하였습니다.',
    'actions': [
      {'label': '수락', 'onPressed': () {}},
      {'label': '거절', 'onPressed': () {}}
    ],
  },
  {
    'id': 2,
    'date': '24.10.30',
    'category': '이벤트/혜택',
    'title': '[광고] [히든 글자 확인하러 가기]\n어제 KB Pay로 결제하셨네요!\n히든 글자를 확인해보세요.',
    'actions': [
      {
        'label': '자세히 보기',
        'onPressed': (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HiddenWordOpenPage(hiddenWord: '차'),
            ),
          );
        }
      }
    ],
  },
  {
    'id': 3,
    'date': '24.10.28',
    'category': '결제',
    'title': '[KB Pay 사용 알림] 체크 7306\n4,500원\n스타벅스 광화문점 승인',
  },
];

void main() {
  runApp(YesterPayApp());
}

class YesterPayApp extends StatelessWidget {
  const YesterPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class YesterPayMainContent extends StatefulWidget {
  final int memberId;

  const YesterPayMainContent({super.key, required this.memberId});

  @override
  _YesterPayMainContentState createState() => _YesterPayMainContentState();
}

class _YesterPayMainContentState extends State<YesterPayMainContent> {
  final PageController _pageController = PageController();
  int _currentPage = 2;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Timer.periodic(Duration(seconds: 3), (Timer timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % 5;
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        hasNotifications: notifications.isNotEmpty, // 전역 변수 사용
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'YesterPay 메인 화면 - 회원 ID: ${widget.memberId}',
              ),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/up_home_yeseterpay.png',
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: 180,
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    left: 14,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HiddenWordOpenPage(hiddenWord: '차'),
                          ),
                        );
                      },
                      child: Text('글자 확인하러 가기  ➔',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD9D9D9), width: 1), // 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게 처리
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/free-icon-bingo-home.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Row(
                    children: const [
                      Text('PAYGO! BINGO!',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('1빙고 / 3빙고', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  subtitle: Text('빙고 완성하러 가기'),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 0.0), // 아이콘 오른쪽으로 이동
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // BingoMain 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => BingoMain()),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16), // 여백 추가
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD9D9D9), width: 1), // 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게 처리
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/free-icon-crossword-home.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Row(
                    children: const [
                      Text('십자말 풀이',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('완성률 : 55%', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  subtitle: Text('십자말 완성하러 가기'),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 0.0), // 아이콘 오른쪽으로 이동
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // CrosswordPage 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CrosswordPage()),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/down_yesterpay_home.png',
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: 240,
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    left: 10,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HiddenWordPredictionPage(),
                          ),
                        );
                      },
                      child: Text('글자 예측하러 가기  ➜',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '내 단어',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // 조합하기 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CombinationWordsPage()),
                            );
                          },
                          child: Text('조합하기 >'),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        for (var word in ['인', '킹', '도', '주', '하', '연'])
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              shape: BoxShape.circle,
                            ),
                            child: Text(word, style: TextStyle(fontSize: 18)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 310,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: 5,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/season_ad_${index + 1}.png',
                                fit: BoxFit.fitHeight,
                                width: double.infinity,
                                height: 300,
                              ),

                              // Padding(
                              //   padding: EdgeInsets.all(8.0),
                              // ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Positioned(
                    //   bottom: 16,
                    //   left: 16,
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    //     decoration: BoxDecoration(
                    //       color: Colors.black54,
                    //       borderRadius: BorderRadius.circular(8.0),
                    //     ),
                    //     child: Text(
                    //       'Page ${_currentPage + 1} of 5',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
