import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:practice_first_flutter_project/main.dart';
import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';
import 'package:practice_first_flutter_project/combination_words.dart';

class ProposalWord {
  final int proposalWordId;
  final int wordId;
  final int puzzleTeamId;
  final String word;
  final int? memberId;
  final List<String> submitList;
  final List<String> necessaryList;

  ProposalWord({
    required this.proposalWordId,
    required this.wordId,
    required this.puzzleTeamId,
    required this.word,
    this.memberId,
    required this.submitList,
    required this.necessaryList,
  });

  factory ProposalWord.fromJson(Map<String, dynamic> json) {
    return ProposalWord(
      proposalWordId: json['proposalWordId'],
      wordId: json['wordId'],
      puzzleTeamId: json['puzzleTeamId'],
      word: json['word'],
      memberId: json['memberId'],
      submitList: List<String>.from(json['submitList']),
      necessaryList: List<String>.from(json['necessaryList']),
    );
  }
}

class SuggestedWordPage extends StatefulWidget {
  const SuggestedWordPage({super.key});

  @override
  _SuggestedWordPageState createState() => _SuggestedWordPageState();
}

class _SuggestedWordPageState extends State<SuggestedWordPage> {
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);

  List<ProposalWord> suggestedWords = [];
  bool isLoading = true; // 로딩 상태 추가
  bool hasError = false; // 에러 상태 추가

  List<String> myLetters = [];
  String? selectedLetter;
  // List<String> letters = [];
  late int memberId;
  late int teamId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final GlobalProvider pro = Get.find<GlobalProvider>();
    memberId = pro.getMemberId();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchMemberInfo(); // teamId 값을 초기화
      await _fetchSuggestLetters(teamId); // 초기화된 teamId를 사용
      await _fetchLetterCollections(memberId);
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

  Future<void> _submitSuggestedWord(
      ProposalWord wordData, String selectedLetter) async {
    const String serverUrl = 'http://3.34.102.55:8080/puzzle/suggest'; // 서버 주소
    final url = Uri.parse(serverUrl);

    final Map<String, dynamic> data = {
      'proposalWordId': wordData.proposalWordId,
      'puzzleTeamId': teamId,
      'word': selectedLetter,
      'memberId': memberId,
    };

    try {
      final response = await http.post(url, body: jsonEncode(data), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        print('제안단어 제출 $data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제안단어가 성공적으로 제출되었습니다.')),
        );
        _initializeData();
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

  Future<void> fetchLetters() async {
    final memberId = Get.find<GlobalProvider>().getMemberId();
    try {
      final response = await http
          .get(Uri.parse('http://3.34.102.55:8080/member/$memberId/letter'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List;
        print('단어 받아오나요? $data');
        setState(() {
          myLetters = data.map((item) => item.toString()).toList();
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          myLetters = [];
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        myLetters = [];
      });
    }
  }

  void _showSubmitDialog(BuildContext context, ProposalWord proposalWord) {
    List<String> matchLetters = myLetters
        .where((letter) => proposalWord.necessaryList.contains(letter))
        .toList();

    if (matchLetters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('필요 글자에 해당하는 글자가 없습니다.')),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposalWord.word,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '제출 가능 글자',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: matchLetters.map((letter) {
                        bool isSelected = selectedLetter == letter;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedLetter = isSelected ? null : letter;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.amber : Colors.black,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: isSelected
                                  ? Colors.amber
                                  : Colors.transparent,
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              selectedLetter = null; // 선택된 글자 초기화
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: cancelBtnColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: Text(
                              '취소',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedLetter != null) {
                                _submitSuggestedWord(
                                    proposalWord, selectedLetter!);
                                String? submitLetter;
                                submitLetter = selectedLetter;
                                Navigator.of(context).pop(); // 모달 닫기
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('제출된 글자: $submitLetter')),
                                );
                              } else {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('제출 가능한 글자가 없습니다 !'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: emissionBtnColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: Text('제출'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
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

  Future<void> _fetchSuggestLetters(int teamId) async {
    const String serverUrl = 'http://3.34.102.55:8080/puzzle';
    final url = Uri.parse('$serverUrl/board/$teamId/suggest');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        // print("제안단어들 $responseData");
        setState(() {
          suggestedWords =
              responseData.map((data) => ProposalWord.fromJson(data)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to fetch suggested words: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching suggested words: $e')),
      );
    }
  }

  Future<void> _fetchLetterCollections(int memberId) async {
    const String serverUrl = 'http://3.34.102.55:8080/member';
    final url = Uri.parse('$serverUrl/$memberId/letter');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        myLetters =
            List<String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
        // print(letters);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch letters : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching letter : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('제안 단어'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // 로딩 상태 표시
                  : hasError
                      ? Center(child: Text('데이터를 가져오는데 실패했습니다.'))
                      : suggestedWords.isEmpty
                          ? Center(child: Text('제안된 단어가 없습니다.'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              itemCount: suggestedWords.length,
                              itemBuilder: (context, index) {
                                final proposalWord = suggestedWords[index];
                                double size = 60;
                                if (proposalWord.necessaryList.length > 3 ||
                                    proposalWord.submitList.length > 3) {
                                  size = 110;
                                }
                                return GestureDetector(
                                  onTap: () =>
                                      _showSubmitDialog(context, proposalWord),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: Colors.amber[100],
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '제안단어',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  proposalWord.word,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                _buildLetterContainer(
                                                    '제출된 글자',
                                                    proposalWord.submitList,
                                                    size),
                                                SizedBox(width: 10),
                                                _buildLetterContainer(
                                                    '필요글자',
                                                    proposalWord.necessaryList,
                                                    size),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '내 단어',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CombinationWordsPage(),
                                  ),
                                ).then((value) {
                                  if (value) {
                                    fetchLetters();
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cancelBtnColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(4),
                              ),
                              child: Text(
                                '조합',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: myLetters.map((letter) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Text(letter,
                                        style: TextStyle(color: Colors.black)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildLetterContainer(
      String title, List<String> letters, double size) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            width: double.infinity,
            height: size,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: letters.isNotEmpty
                  ? letters
                      .map((letter) => CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Text(letter,
                                style: TextStyle(color: Colors.black)),
                          ))
                      .toList()
                  : [SizedBox.shrink()], // 빈 상태일 때 공간 유지
            ),
          ),
        ],
      ),
    );
  }
}
