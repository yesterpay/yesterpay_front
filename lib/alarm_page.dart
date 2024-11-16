import 'package:flutter/material.dart';
import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'hiddenword/hiddenword_open.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  String selectedCategory = '전체'; // 선택된 카테고리

  // 알림 데이터
  final List<Map<String, dynamic>> notifications = [
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

  @override
  Widget build(BuildContext context) {
    // 선택된 카테고리에 따라 필터링된 알림 리스트
    final filteredNotifications = selectedCategory == '전체'
        ? notifications
        : notifications
        .where((notification) => notification['category'] == selectedCategory)
        .toList();

    return Scaffold(
      appBar: CustomAppBar(hasNotifications: notifications.isNotEmpty),
      backgroundColor: Color(0xFFF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 탭 버튼 섹션
            Row(
              children: [
                _buildTabButton(context, '전체', selectedCategory == '전체'),
                SizedBox(width: 8),
                _buildTabButton(context, '결제', selectedCategory == '결제'),
                SizedBox(width: 8),
                _buildTabButton(context, '이벤트/혜택', selectedCategory == '이벤트/혜택'),
                SizedBox(width: 8),
                _buildTabButton(context, '가입', selectedCategory == '가입'),
              ],
            ),
            SizedBox(height: 16),
            // 알림 리스트 섹션
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
                child: Text(
                  '해당 카테고리에 알림이 없습니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return _buildNotificationCard(
                    context,
                    notification: notification,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String title, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = title; // 선택된 카테고리 업데이트
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
    );
  }

  Widget _buildNotificationCard(BuildContext context, {required Map<String, dynamic> notification}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification['date'],
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 25, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      // 알림 삭제
                      notifications.removeWhere((n) => n['id'] == notification['id']);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              notification['category'],
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            SizedBox(height: 8),
            Text(
              notification['title'],
              style: TextStyle(fontSize: 14),
            ),
            if (notification['actions'] != null) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: (notification['actions'] as List)
                    .map(
                      (action) => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: OutlinedButton(
                      onPressed: () => action['onPressed'](context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        action['label'],
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
