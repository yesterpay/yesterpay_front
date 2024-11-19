import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../NotificationController.dart';
import '../alarm_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return AppBar(
      scrolledUnderElevation: 0,
      title: Image.asset(
        'assets/icons/YesterPay.png',
        height: 20,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Obx(() => IconButton(
          icon: Image.asset(
            notificationController.unreadNotificationCount > 0
                ? 'assets/icons/yes_alarm.png' // 읽지 않은 알림 있음
                : 'assets/icons/no_alarm.png', // 읽지 않은 알림 없음
            height: 24,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlarmPage()),
            );
          },
        )),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
