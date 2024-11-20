import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationController extends GetxController {
  RxList<Map<String, dynamic>> allNotifications =
      <Map<String, dynamic>>[].obs; // 전체 알림 데이터
  RxList<Map<String, dynamic>> unreadNotifications =
      <Map<String, dynamic>>[].obs; // 읽지 않은 알림 데이터
  RxInt unreadNotificationCount = 0.obs; // 읽지 않은 알림 개수

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(); // 초기화 시 알림 가져오기
    fetchUnreadNotificationCount(); // 초기화 시 읽지 않은 알림 개수 가져오기
  }

  void setunreadNotificationCount(int num) {
    unreadNotificationCount.value = num;
  }

  int getUnreadNotificationCount() {
    return unreadNotificationCount.value;
  }

  // 읽지 않은 알림 개수를 가져오는 메서드
  Future<void> fetchUnreadNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://3.34.102.55:8080/member/1/notification/unread-count'),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isNotEmpty) {
          unreadNotificationCount.value =
              int.tryParse(responseBody) ?? 0; // Null-safe 파싱
        } else {
          unreadNotificationCount.value = 0; // 응답이 비어 있을 경우 0으로 설정
        }
      } else {
        print(
            'Failed to fetch unread notification count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread notification count: $e');
    }
  }

  // 알림 데이터를 가져오기
  Future<void> fetchNotifications() async {
    try {
      final response = await http
          .get(Uri.parse('http://3.34.102.55:8080/member/1/notification'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        allNotifications.value = data.map((item) {
          String category = '';
          switch (item['type']) {
            case 1:
              category = '기타';
              break;
            case 2:
              category = '가입';
              break;
            case 3:
              category = '이벤트/혜택';
              break;
            case 4:
              category = '결제';
              break;
            default:
              category = '알 수 없음';
          }
          return {
            'id': item['notificationId'],
            'date': item['createdAt'] != null
                ? DateTime.parse(item['createdAt']).toString()
                : '날짜 없음',
            'category': category,
            'title': item['content'] ?? '내용 없음',
            'isRead': item['isRead'] ?? false,
          };
        }).toList();

        // 읽지 않은 알림 필터링
        unreadNotifications.value =
            allNotifications.where((item) => item['isRead'] == false).toList();
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  // 읽음 처리 메서드
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://3.34.102.55:8080/member/1/notification/$notificationId/read'),
      );
      if (response.statusCode == 200) {
        // 읽음 상태를 업데이트
        fetchNotifications();
        fetchUnreadNotificationCount(); // 읽지 않은 알림 개수 다시 가져오기
      } else {
        print('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // 알림 삭제 메서드
  void removeNotification(int id) {
    unreadNotifications.removeWhere((notification) => notification['id'] == id);
  }
}
