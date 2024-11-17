import 'package:flutter/material.dart';
import 'package:practice_first_flutter_project/mypage/mypage.dart';
import '../bingo_main.dart';
import '../main.dart';
import '../puzzle/puzzle.dart';
import 'package:practice_first_flutter_project/ranking/ranking.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;

  CustomBottomNavigationBar(
      {super.key, required this.currentIndex});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WeeklyRankingPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CrosswordPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => YesterPayMainContent()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BingoMain()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 0
                ? 'assets/icons/yellow_rank.png'
                : 'assets/icons/gray_rank.png',
            width: 40,
            height: 40,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 1
                ? 'assets/icons/yellow_crossword.png'
                : 'assets/icons/gray_crossword.png',
            width: 40,
            height: 40,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 2
                ? 'assets/icons/yellow_home.png'
                : 'assets/icons/gray_home.png',
            width: 40,
            height: 40,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 3
                ? 'assets/icons/yellow_bingo.png'
                : 'assets/icons/gray_bingo.png',
            width: 40,
            height: 40,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 4
                ? 'assets/icons/yellow_mypage.png'
                : 'assets/icons/gray_mypage.png',
            width: 40,
            height: 40,
          ),
          label: '',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
