import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get/get_core/src/get_main.dart';

import 'package:practice_first_flutter_project/widgets/app_above_bar.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';
import 'package:practice_first_flutter_project/puzzle/proposal_word.dart';
import 'package:practice_first_flutter_project/puzzle/team_info.dart';

import '../NotificationController.dart';
import '../main.dart';
import '../widgets/app_above_bar.dart';

class CrosswordWord {
  final int wordId;
  final List<int> start;
  final String teamWord;
  final String answer;
  final int no;
  final String orientation;
  final String clue;
  final bool check;
  final bool completion;

  CrosswordWord({
    required this.wordId,
    required this.start,
    required this.teamWord,
    required this.answer,
    required this.no,
    required this.orientation,
    required this.clue,
    required this.check,
    required this.completion,
  });

  factory CrosswordWord.fromJson(Map<String, dynamic> json) {
    return CrosswordWord(
      wordId: json['wordId'],
      start: List<int>.from(json['start']),
      teamWord: json['teamWord'],
      answer: json['answer'],
      no: json['no'],
      orientation: json['orientation'],
      clue: json['clue'],
      check: json['check'],
      completion: json['completion'],
    );
  }

  // Convert CrosswordWord to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'wordId': wordId,
      'start': start,
      'teamWord': teamWord,
      'answer': answer,
      'no': no,
      'orientation': orientation,
      'clue': clue,
      'check': check,
    };
  }
}

class CrosswordPage extends StatefulWidget {
  const CrosswordPage({super.key});

  @override
  _CrosswordPageState createState() => _CrosswordPageState();
}

class _CrosswordPageState extends State<CrosswordPage> {
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);
  final int gridSize = 7;

  late int memberId;
  late int teamId;
  bool completion = false;
  List<CrosswordWord> wordClues = [];
  List<List<String?>> gridData = List.generate(7, (_) => List.filled(7, null));
  List<String> correctWords = []; // 여기서는 빈 배열로 시작합니다.

  @override
  void initState() {
    super.initState();
    final GlobalProvider pro = Get.find<GlobalProvider>();
    memberId = pro.getMemberId();
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    _fetchMemberInfo().then((_) {
      _fetchPuzzleWords(teamId); // teamId를 사용하여 단어 목록을 받아옵니다
    });
  }

  Future<void> _fetchMemberInfo() async {
    const String serverUrl = 'http://3.34.102.55:8080/member'; // API 주소
    final url = Uri.parse('$serverUrl/$memberId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final memberInfo = jsonDecode(utf8.decode(response.bodyBytes));
        teamId = memberInfo['puzzleTeamId'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch member info')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching member info')),
      );
    }
  }

  Future<void> _fetchPuzzleWords(int teamId) async {
    const String serverUrl = 'http://3.34.102.55:8080/puzzle/board'; // API 주소
    final url = Uri.parse('$serverUrl/$teamId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<CrosswordWord> words =
            data.map((json) => CrosswordWord.fromJson(json)).toList();
        if (words[0].completion) {
          completion = true;
          print('퍼즐판 완료 !!!');
        }
        setState(() {
          wordClues.clear();
          wordClues.addAll(words);
          // 정답 단어 목록을 `check`가 true인 단어로만 업데이트
          correctWords = words
              .where((word) => word.check)
              .map((word) => word.answer)
              .toList();

          // check가 true인 단어를 gridData에 자동으로 채우기
          for (var word in wordClues) {
            if (word.check) {
              _fillGridWithWord(word);
            }
          }
        });

        print('data : $data');
        print('words : $words');
        print('correctWords : $correctWords'); // debug 출력 추가
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch puzzle words')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching puzzle words: $e')),
      );
    }
  }

  void _showLetterInputDialog(BuildContext context, CrosswordWord wordData) {
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
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 20, // 키보드 높이만큼 여백 추가
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${wordData.orientation == 'r' ? '가로' : '세로'} ${wordData.no}번",
                  style: TextStyle(
                    fontSize: 18,
                    color: wordData.orientation == 'r'
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
                        String word = letterController.text;
                        _submitSuggestedWord(wordData, word);
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

  void _fillGridWithWord(CrosswordWord wordData) {
    int x = wordData.start[0];
    int y = wordData.start[1];
    for (int i = 0; i < wordData.answer.length; i++) {
      if (wordData.orientation == 'r') {
        gridData[x][y + i] = wordData.answer[i];
      } else {
        gridData[x + i][y] = wordData.answer[i];
      }
    }
  }

  Future<void> _submitSuggestedWord(CrosswordWord wordData, String word) async {
    const String serverUrl =
        'http://3.34.102.55:8080/puzzle/board/word'; // 서버 주소
    final url = Uri.parse(serverUrl);

    final Map<String, dynamic> data = {
      'wordId': wordData.wordId,
      'puzzleTeamId': teamId,
      'word': word,
    };

    try {
      final response = await http.post(url, body: jsonEncode(data), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제안단어가 성공적으로 제출되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('단어 제출 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제안단어 제출 중 오류 발생')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 25,
                  left: MediaQuery.of(context).size.width * 0.08,
                  child: Transform.scale(
                    scale: 1.7,
                    child: Image.asset(
                      'assets/images/puzzleTitle.png',
                      width: MediaQuery.of(context).size.width * 0.38,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150.0),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFDCC58C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                    (w.orientation == 'r' &&
                                        w.start[0] == row &&
                                        w.start[1] <= col &&
                                        w.start[1] + w.answer.length > col) ||
                                    (w.orientation == 'c' &&
                                        w.start[1] == col &&
                                        w.start[0] <= row &&
                                        w.start[0] + w.answer.length > row),
                                orElse: () => CrosswordWord(
                                  wordId: -1,
                                  start: [],
                                  teamWord: '',
                                  answer: '',
                                  no: 0,
                                  orientation: '',
                                  clue: '',
                                  check: false,
                                  completion: false,
                                ),
                              );

                              bool isStartPosition =
                                  wordData.start.isNotEmpty &&
                                      wordData.start[0] == row &&
                                      wordData.start[1] == col;

                              bool isCorrect = gridData[row][col] != null &&
                                  gridData[row][col]!.isNotEmpty &&
                                  wordData.answer.isNotEmpty &&
                                  ((wordData.orientation == 'r' &&
                                          row == wordData.start[0] &&
                                          wordData.answer[
                                                  col - wordData.start[1]] ==
                                              gridData[row][col]) ||
                                      (wordData.orientation == 'c' &&
                                          col == wordData.start[1] &&
                                          wordData.answer[
                                                  row - wordData.start[0]] ==
                                              gridData[row][col]));

                              return GestureDetector(
                                onTap: wordData.wordId != -1
                                    ? () => _showLetterInputDialog(
                                        context, wordData)
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: wordData.wordId != -1
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
                                            wordData.no.toString(),
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
                        if (completion) // 십자말판 덮개
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "십자말 성공!! \n포인트가 지급됐습니다.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 48,
                  right: MediaQuery.of(context).size.width * 0.13,
                  child: Transform.scale(
                    scale: 1.6,
                    child: Image.asset(
                      'assets/images/friends.png',
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
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
                      ).then((value) {
                        if (value) {
                          _fetchMemberInfo().then((_) {
                            _fetchPuzzleWords(
                                teamId); // teamId를 사용하여 단어 목록을 받아옵니다
                          });
                        }
                      });
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
            // 추가된 부분: 단어 설명 출력
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
                        .where((w) => w.orientation == 'r')
                        .map((w) => GestureDetector(
                              onTap: () => _showLetterInputDialog(context, w),
                              child: Text(
                                "${w.no}. ${w.clue}",
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
                    ...wordClues.where((w) => w.orientation == 'c').map(
                          (w) => GestureDetector(
                            onTap: () => _showLetterInputDialog(context, w),
                            child: Text(
                              "${w.no}. ${w.clue}",
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
      ),
    );
  }
}
