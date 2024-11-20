import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'NotificationController.dart';
import 'package:intl/intl.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final notificationController = Get.find<NotificationController>();
  String selectedCategory = '전체';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await notificationController.fetchNotifications();
      notificationController.setunreadNotificationCount(0);
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        final notifications = selectedCategory == '전체'
            ? notificationController.unreadNotifications
            : notificationController.unreadNotifications
                .where((notification) =>
                    notification['category'] == selectedCategory)
                .toList();

        if (notifications.isEmpty) {
          return Center(child: Text('해당 카테고리에 알림이 없습니다.'));
        }

        return Column(
          children: [
            // 카테고리 선택 버튼
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('전체', selectedCategory == '전체'),
                  _buildTabButton('결제', selectedCategory == '결제'),
                  _buildTabButton('이벤트/혜택', selectedCategory == '이벤트/혜택'),
                  _buildTabButton('가입', selectedCategory == '가입'),
                  _buildTabButton('기타', selectedCategory == '기타'),
                ].map((button) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0), // 패딩 값을 8.0에서 4.0으로 줄임
                    child: button,
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = title;
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.orange : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(title),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    String formattedDate = '날짜 없음';
    if (notification['date'] != null) {
      final DateTime date = DateTime.parse(notification['date']);
      formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(date);
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    notificationController
                        .removeNotification(notification['id']);
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              notification['category'],
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            SizedBox(height: 8),
            Text(
              notification['title'],
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
