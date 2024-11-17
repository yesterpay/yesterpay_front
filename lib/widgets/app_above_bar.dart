import 'package:flutter/material.dart';

import '../alarm_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasNotifications; // 알림 유무를 나타내는 변수

  CustomAppBar({required this.hasNotifications});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation:0,
      title: Image.asset(
        'assets/icons/YesterPay.png', // YesterPay 로고 이미지
        height: 20, // 이미지 높이 조정
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Image.asset(
            hasNotifications
                ? 'assets/icons/yes_alarm.png' // 알림 있음
                : 'assets/icons/no_alarm.png', // 알림 없음
            height: 24, // 아이콘 크기 조정
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlarmPage()),
            ); // 알림 페이지로 이동
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
