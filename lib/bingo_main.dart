import 'package:flutter/material.dart';
import 'dart:math';
import 'widgets/app_above_bar.dart';
import 'widgets/bottom_navigation_bar.dart';

class BingoMain extends StatefulWidget {
  @override
  _BingoMainState createState() => _BingoMainState();
}

class _BingoMainState extends State<BingoMain> with TickerProviderStateMixin {
  final List<String> bingoItems = ['페', '템', 'M', 'M', '제', '빙', '상', 'M', '응'];
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

  Map<int, AnimationController> _controllers = {}; // 각 M 칸에 대한 AnimationController
  Map<int, Animation<double>> _flipAnimations = {}; // 각 M 칸에 대한 Animation
  List<bool> isFlipped = List.generate(9, (_) => false); // 각 칸의 뒤집힘 상태를 저장

  @override
  void initState() {
    super.initState();
    // 각 M 칸에 대해서만 애니메이션 컨트롤러와 애니메이션 초기화
    for (int i = 0; i < bingoItems.length; i++) {
      if (bingoItems[i] == 'M') {
        final controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
        final animation = Tween(begin: 0.0, end: pi).animate(controller);
        _controllers[i] = controller;
        _flipAnimations[i] = animation;
      }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Text('KB 스타적금 II 상품 가입하기'),
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
      print("Bingo판에서  ${index+1}번째 빙고판이 뒤집혔습니다.");
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
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
