import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/app_above_bar.dart';
import 'widgets/bottom_navigation_bar.dart';

void main() {
  runApp(YesterPayApp());
}

class YesterPayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YesterPayMainContent(),
    );
  }
}

class YesterPayMainContent extends StatefulWidget {
  @override
  _YesterPayMainContentState createState() => _YesterPayMainContentState();
}

class _YesterPayMainContentState extends State<YesterPayMainContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
      appBar: CustomAppBar(), // 분리된 상단바 사용
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 배너 이미지
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/up_home_yeseterpay.png'), // 상단 배너 이미지
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // 글자 확인 페이지로 이동
                        },
                        child: Text('글자 확인하러 가기'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // 빙고 섹션
              ListTile(
                leading: Icon(Icons.grid_view, color: Colors.orange),
                title: Row(
                  children: [
                    Text('PAYGO! BINGO!', style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text('1빙고 / 3빙고', style: TextStyle(color: Colors.red)),
                  ],
                ),
                subtitle: Text('빙고 완성하러 가기'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.pink),
                title: Row(
                  children: [
                    Text('십자말 풀이', style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text('완성률 : 55%', style: TextStyle(color: Colors.red)),
                  ],
                ),
                subtitle: Text('십자말 완성하러 가기'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              SizedBox(height: 16),
              // 중간 Yester Pay 배너 이미지
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/down_yesterpay_home.png'), // 중간 배너 이미지
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // 글자 예측 페이지로 이동
                        },
                        child: Text('글자 예측하러 가기'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // 내 단어 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '내 단어',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // 조합하기 페이지로 이동
                    },
                    child: Text('조합하기 >'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  Chip(label: Text('인')),
                  Chip(label: Text('킹')),
                  Chip(label: Text('도')),
                  Chip(label: Text('주')),
                  Chip(label: Text('하')),
                  Chip(label: Text('연')),
                ],
              ),
              SizedBox(height: 16),
              // 시즌 광고 슬라이드
              SizedBox(
                height: 310,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          Image.asset('assets/images/season_ad_${index + 1}.png'), // 시즌 광고 이미지
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Season Ad ${index + 1}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(), // 분리된 하단바 사용
    );
  }
}
