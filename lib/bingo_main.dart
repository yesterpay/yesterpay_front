import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'NotificationController.dart';
import 'main.dart';
import 'widgets/app_above_bar.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BingoDTO {
  final int bingoBoardId;
  final int level;
  final int requiredBingoCount;
  final List<BingoCellDTO> bingoLetterList;

  BingoDTO({
    required this.bingoBoardId,
    required this.level,
    required this.requiredBingoCount,
    required this.bingoLetterList,
  });

  factory BingoDTO.fromJson(Map<String, dynamic> json) {
    return BingoDTO(
      bingoBoardId: json['bingoBoardId'],
      level: json['level'],
      requiredBingoCount: json['requiredBingoCount'],
      bingoLetterList: (json['bingoLetterList'] as List)
          .map((cell) => BingoCellDTO.fromJson(cell))
          .toList(),
    );
  }
}

class BingoCellDTO {
  final int bingoLetterId;
  final int index;
  final String letter;
  final bool isCheck;

  BingoCellDTO({
    required this.bingoLetterId,
    required this.index,
    required this.letter,
    required this.isCheck,
  });

  factory BingoCellDTO.fromJson(Map<String, dynamic> json) {
    return BingoCellDTO(
      bingoLetterId: json['bingoLetterId'],
      index: json['index'],
      letter: json['letter'],
      isCheck: json['isCheck'],
    );
  }
}

class BingoMain extends StatefulWidget {
  const BingoMain({super.key});

  @override
  _BingoMainState createState() => _BingoMainState();
}

class _BingoMainState extends State<BingoMain> with TickerProviderStateMixin {
  List<String> bingoItems = List.filled(9, '');
  final List<String?> images = [
    null,
    'assets/images/img_characters05.png',
    null,
    null,
    null,
    null,
    'assets/images/img_characters04.png', // 중간에 위치한 캐릭터 이미지
    null,
    'assets/images/img_characters02.png', // 상단 왼쪽 캐릭터 이미지
  ];

  late int memberId;

  final List<Alignment> imageAlignments = [
    Alignment.center,
    Alignment.bottomRight,
    Alignment.center,
    Alignment.center,
    Alignment.topLeft,
    Alignment.center,
    Alignment.bottomLeft,
    Alignment.center,
    Alignment.topRight,
  ];

  final Map<int, AnimationController> _controllers =
      {}; // 각 M 칸에 대한 AnimationController
  final Map<int, Animation<double>> _flipAnimations = {}; // 각 M 칸에 대한 Animation
  List<bool> isFlipped = List.filled(9, false); // 각 칸의 뒤집힘 상태를 저장
  bool isLoading = true; // 로딩 상태 추가
  bool hasError = false; // 에러 상태 추가
  String? missionText;

  @override
  void initState() {
    super.initState();
    final GlobalProvider pro = Get.find<GlobalProvider>();
    memberId = pro.getMemberId();
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    _initializeData();
  }

  void _animationInit() {
    // 기존 컨트롤러 정리
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _flipAnimations.clear();

    for (int i = 0; i < bingoItems.length; i++) {
      if (bingoItems[i] == 'M' || isFlipped[i]) {
        final controller = AnimationController(
            vsync: this, duration: Duration(milliseconds: 500));
        final animation = Tween(begin: 0.0, end: pi).animate(controller);
        _controllers[i] = controller;
        _flipAnimations[i] = animation;

        if (isFlipped[i]) {
          controller.value = pi; // 뒤집힌 상태로 초기화
        }
      }
    }
  }

  Future<void> _initializeData() async {
    try {
      await _fetchMission();
      await _fetchBingoBoard();
      // _animationInit();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error initializing data: $e');
    }
  }

  Future<void> _fetchBingoBoard() async {
    const String serverUrl = 'http://3.34.102.55:8080/bingo/board';
    final url =
        Uri.parse('$serverUrl?memberId=$memberId'); // memberId를 적절히 설정하세요.

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final bingoBoard = BingoDTO.fromJson(jsonData);

        // bingoItems 및 isFlipped 상태 업데이트
        setState(() {
          bingoItems = List.generate(9, (index) {
            final cell = bingoBoard.bingoLetterList.firstWhere(
              (cell) => cell.index == index,
              orElse: () => BingoCellDTO(
                bingoLetterId: 0,
                index: index,
                letter: '',
                isCheck: false,
              ),
            );
            return cell.letter;
          });

          isFlipped = List.generate(9, (index) {
            final cell = bingoBoard.bingoLetterList.firstWhere(
              (cell) => cell.index == index,
              orElse: () => BingoCellDTO(
                bingoLetterId: 0,
                index: index,
                letter: '',
                isCheck: false,
              ),
            );
            return cell.isCheck; // isCheck 값에 따라 뒤집힘 상태 설정
          });

          for (int i = 0; i < isFlipped.length; i++) {
            if (isFlipped[i]) {
              _controllers[i]?.forward(from: 0.0); // 애니메이션 실행
            }
          }
          // 초기화된 데이터로 애니메이션 설정
          _animationInit();
        });
      } else {
        print('Failed to fetch bingo board: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bingo board: $e');
    }
  }

  Future<void> _fetchMission() async {
    const String serverUrl = 'http://3.34.102.55:8080/bingo/mission';
    final url = Uri.parse('$serverUrl?memberId=$memberId'); // memberId 설정

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('미션 확인 $jsonData');
        setState(() {
          missionText = jsonData['mission']; // 미션 텍스트 저장
        });
      } else {
        print('Failed to fetch mission: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching mission: $e');
    }
  }

  Future<void> _missionExecution(int index) async {
    const String serverUrl = 'http://3.34.102.55:8080/bingo/mission/success';
    final url = Uri.parse(serverUrl);

    final Map<String, dynamic> data = {
      'memberId': memberId,
      'index': index,
      'isSuccess': true
    };

    try {
      final response = await http.post(url, body: jsonEncode(data), headers: {
        'Content-Type': 'application/json',
      });
      print('미션됐나?? ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('미션결과 $jsonData');
        if (jsonData['isBingoBoardFinished']) {
          _showBingoSuccessModal();
        }
      }
    } catch (e) {
      print('Error ececution mission: $e');
    }
  }

  void _showBingoSuccessModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                '빙고 완성!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '축하합니다! 빙고판을 완성했습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 모달 닫기
                  await _refreshBingoBoard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshBingoBoard() async {
    setState(() {
      isLoading = true; // 로딩 상태로 전환
      bingoItems = List.filled(9, ''); // 기존 데이터를 초기화
      isFlipped = List.filled(9, false); // 플립 상태 초기화
    });

    try {
      await _fetchBingoBoard(); // 새로운 빙고 데이터를 가져옴
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
      _animationInit(); // 애니메이션 재초기화
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true; // 에러 상태 설정
      });
      print('Error refreshing bingo board: $e');
    }
  }

  @override
  void dispose() {
    // M 칸에 대한 애니메이션 컨트롤러 정리
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMissionDialog(int index) {
    if (isFlipped[index]) return; // 뒤집힌 칸은 모달이 뜨지 않도록 처리

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'M미션',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                missionText ?? '미션을 불러오는 중...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _missionExecution(index);
                  _flipCard(index); // 선택한 M 칸만 뒤집기
                },
                child: Text(
                  '미션 수행하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _flipCard(int index) {
    setState(() {
      isFlipped[index] = true; // 뒤집힘 상태로 설정
    });
    _controllers[index]?.forward(from: 0.0).then((_) {
      // 애니메이션이 완료된 후 위치를 로그로 출력
      print("Bingo판에서  ${index + 1}번째 빙고판이 뒤집혔습니다.");
    });
  }

  Widget _buildBingoCard(int index) {
    final isFront = !isFlipped[index];

    // 애니메이션이 없는 경우 기본 컨테이너 반환
    if (_flipAnimations[index] == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              bingoItems[index],
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: bingoItems[index] == 'M' ? Colors.orange : Colors.black,
              ),
            ),
            if (images[index] != null)
              Align(
                alignment: imageAlignments[index],
                child: Image.asset(
                  images[index]!,
                  width: 60,
                  height: 60,
                ),
              ),
          ],
        ),
      );
    }

    // 애니메이션이 있는 경우 AnimatedBuilder 사용
    return GestureDetector(
      onTap: () {
        if (isFlipped[index]) return; // 뒤집힌 상태라면 아무 동작도 하지 않음
        _showMissionDialog(index);
      },
      child: AnimatedBuilder(
        animation: _flipAnimations[index]!,
        builder: (context, child) {
          final rotationValue = _flipAnimations[index]!.value;
          final bool showFront = rotationValue < pi / 2;

          return Transform(
            transform: Matrix4.rotationY(rotationValue),
            alignment: Alignment.center,
            child: showFront
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          bingoItems[index],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: bingoItems[index] == 'M'
                                ? Colors.orange
                                : Colors.black,
                          ),
                        ),
                        if (images[index] != null)
                          Align(
                            alignment: imageAlignments[index],
                            child: Image.asset(
                              images[index]!,
                              width: 60,
                              height: 60,
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/complete_bingo.png',
                        fit: BoxFit.cover, // 박스에 이미지를 꽉 차게 설정
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalProvider pro = Get.find<GlobalProvider>();

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Obx(() => Text('Member ID: ${pro.getMemberId()}')),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 2 / 1,
                    child: Image.asset(
                      'assets/images/Paygo_Bingo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF8DFAD),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  key: ValueKey(bingoItems),
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildBingoCard(index);
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                '서비스 이용 안내',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '\t • 최대 3개의 빙고까지만 완성할 수 있으며, 3개의 빙고를 모두 완성하면 새로운 빙고판이 제공됩니다.\n'
                '\t • "M" 칸은 미션 칸으로, 미션 성공시 해당 칸을 채울 수 있습니다.\n'
                '\t • 빙고는 글자 획득 시 자동으로 해당 칸을 채울 수 있습니다.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
