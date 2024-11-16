import 'package:flutter/material.dart';

import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';
import 'package:practice_first_flutter_project/puzzle/proposal_word.dart';
import 'package:practice_first_flutter_project/puzzle/team_info.dart';

class CrosswordPage extends StatefulWidget {
  const CrosswordPage({super.key});

  @override
  _CrosswordPageState createState() => _CrosswordPageState();
}

class _CrosswordPageState extends State<CrosswordPage> {
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);
  final int gridSize = 7;
  final List<Map<String, dynamic>> wordClues = [
    {
      'word': '리브',
      'start': [1, 1],
      'orientation': 'r',
      'no': 1,
      'clue': 'KB국민은행의 모바일 뱅킹 앱 이름은?',
    },
    {
      'word': '비대면',
      'start': [3, 1],
      'orientation': 'r',
      'no': 2,
      'clue': '은행 지점에 직접 방문하지 않고, 모바일 앱으로 처리할 수 있는 서비스는?',
    },
    {
      'word': '지성인',
      'start': [4, 5],
      'orientation': 'c',
      'no': 3,
      'clue': '지성을 지닌 사람을 뜻하는 단어는?',
    },
    {
      'word': '지구',
      'start': [4, 5],
      'orientation': 'r',
      'no': 3,
      'clue': '우리가 살고 있는 곳은?',
    },
  ];

  List<List<String?>> gridData = List.generate(7, (_) => List.filled(7, null));
  List<String> correctWords = ['리브']; // 현재 정답 단어 배열

  @override
  void initState() {
    super.initState();
    for (var word in wordClues) {
      int x = word['start'][0];
      int y = word['start'][1];
      for (int i = 0; i < word['word'].length; i++) {
        if (word['orientation'] == 'r') {
          gridData[x][y + i] = '';
        } else {
          gridData[x + i][y] = '';
        }
      }
    }

    for (var word in correctWords) {
      final wordData = wordClues.firstWhere((w) => w['word'] == word);
      _fillGridWithWord(wordData);
    }
  }

  void _showLetterInputDialog(
      BuildContext context, Map<String, dynamic> wordData) {
    final TextEditingController letterController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 공간 확보를 위한 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 높이만큼 여백 추가
          ),
          child: SingleChildScrollView(
            // 내용이 많을 때 스크롤 가능
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${wordData['orientation'] == 'r' ? '가로' : '세로'} ${wordData['no']}번",
                  style: TextStyle(
                    fontSize: 18,
                    color: wordData['orientation'] == 'r'
                        ? Colors.lightBlue
                        : Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: letterController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "단어를 입력하세요",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cancelBtnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "취소",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (letterController.text == wordData['word']) {
                          setState(() {
                            _fillGridWithWord(wordData);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("정답이 아닙니다.")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emissionBtnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "확인",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fillGridWithWord(Map<String, dynamic> wordData) {
    int x = wordData['start'][0];
    int y = wordData['start'][1];
    for (int i = 0; i < wordData['word'].length; i++) {
      if (wordData['orientation'] == 'r') {
        gridData[x][y + i] = wordData['word'][i];
      } else {
        gridData[x + i][y] = wordData['word'][i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // 십자말 풀이 타이틀
                Positioned(
                  top: 25,
                  left: MediaQuery.of(context).size.width * 0.08,
                  child: Transform.scale(
                    scale: 1.7,
                    child: Image.asset(
                      'assets/images/puzzleTitle.png',
                      width: MediaQuery.of(context).size.width * 0.35,
                    ),
                  ),
                ),

                // 십자말 풀이판
                Padding(
                  padding: const EdgeInsets.only(top: 150.0),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDCC58C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 6.0,
                          crossAxisSpacing: 6.0,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (BuildContext context, int index) {
                          int row = index ~/ gridSize;
                          int col = index % gridSize;

                          final wordData = wordClues.firstWhere(
                            (w) =>
                                (w['orientation'] == 'r' &&
                                    w['start'][0] == row &&
                                    w['start'][1] <= col &&
                                    w['start'][1] + w['word'].length > col) ||
                                (w['orientation'] == 'c' &&
                                    w['start'][1] == col &&
                                    w['start'][0] <= row &&
                                    w['start'][0] + w['word'].length > row),
                            orElse: () => {},
                          );

                          bool isStartPosition = wordData.isNotEmpty &&
                              wordData['start'][0] == row &&
                              wordData['start'][1] == col;

                          bool isCorrect = gridData[row][col] != null &&
                              gridData[row][col]!.isNotEmpty &&
                              wordData.isNotEmpty &&
                              gridData[row][col] ==
                                  wordData['word'][col -
                                      wordData['start'][1]]; // 정답 여부 판단 로직

                          return GestureDetector(
                            onTap: wordData.isNotEmpty
                                ? () =>
                                    _showLetterInputDialog(context, wordData)
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: wordData.isNotEmpty
                                    ? Colors.white
                                    : Color(0xFFF8A70C),
                                border: Border.all(
                                  color: isCorrect
                                      ? const Color.fromARGB(255, 1, 170, 7)
                                      : Colors.transparent, // 정답이면 초록색 테두리
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (isStartPosition)
                                    Positioned(
                                      top: 2,
                                      left: 2,
                                      child: Text(
                                        wordData['no'].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Text(
                                      gridData[row][col] ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, // 위쪽 여백을 조정
                  right: -5,
                  child: Transform.scale(
                    scale: 1.1,
                    child: Image.asset(
                      'assets/images/friends.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // 버튼 추가
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuggestedWordPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cancelBtnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Text(
                      '제안단어 보기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamInfoPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emissionBtnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Text(
                      '팀정보 보기',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // 십자말 풀이 설명
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "가로 풀이)",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue),
                    ),
                    ...wordClues
                        .where((w) => w['orientation'] == 'r')
                        .map((w) => GestureDetector(
                              onTap: () => _showLetterInputDialog(context, w),
                              child: Text(
                                "${w['no']}. ${w['clue']}",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )),
                    SizedBox(height: 10),
                    Text(
                      "세로 풀이)",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                    ...wordClues.where((w) => w['orientation'] == 'c').map(
                          (w) => GestureDetector(
                            onTap: () => _showLetterInputDialog(context, w),
                            child: Text(
                              "${w['no']}. ${w['clue']}",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
      ), // 메인 하단바와 동일하게 유지
    );
  }
}
