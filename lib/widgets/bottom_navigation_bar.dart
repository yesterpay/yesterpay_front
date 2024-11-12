import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 0 ? 'assets/icons/yellow_rank.png' : 'assets/icons/gray_rank.png',
            width: 24,
            height: 24,
          ),
          label: '랭킹',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 1 ? 'assets/icons/yellow_crossword.png' : 'assets/icons/gray_crossword.png',
            width: 24,
            height: 24,
          ),
          label: '십자말',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 2 ? 'assets/icons/yellow_home.png' : 'assets/icons/gray_home.png',
            width: 24,
            height: 24,
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 3 ? 'assets/icons/yellow_bingo.png' : 'assets/icons/gray_bingo.png',
            width: 24,
            height: 24,
          ),
          label: '빙고',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 4 ? 'assets/icons/yellow_mypage.png' : 'assets/icons/gray_mypage.png',
            width: 24,
            height: 24,
          ),
          label: 'MY',
        ),
      ],
      type: BottomNavigationBarType.fixed, // 아이템이 4개 이상일 때 타입을 fixed로 설정
    );
  }
}
