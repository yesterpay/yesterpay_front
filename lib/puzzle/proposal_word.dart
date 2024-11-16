import 'package:flutter/material.dart';

import 'package:practice_first_flutter_project/widgets/bottom_navigation_bar.dart';

class SuggestedWordPage extends StatefulWidget {
  const SuggestedWordPage({super.key});

  @override
  _SuggestedWordPageState createState() => _SuggestedWordPageState();
}

class _SuggestedWordPageState extends State<SuggestedWordPage> {
  final emissionBtnColor = Color(0xFFFAB809);
  final cancelBtnColor = Color(0xFF6E6053);

  List<Map<String, dynamic>> suggestedWords = [
    {
      'word': '지성인',
      'providedLetters': ['지', '인'],
      'neededLetters': ['성']
    },
    {
      'word': '비대면',
      'providedLetters': ['비', '대'],
      'neededLetters': ['면']
    },
    {
      'word': '리브',
      'providedLetters': ['리'],
      'neededLetters': ['브']
    },
  ];

  List<String> myLetters = ['면', '리', '브', '아', '대', '떡'];
  String? selectedLetter;

  void _showSubmitDialog(BuildContext context, Map<String, dynamic> wordData) {
    List<String> matchLetters = myLetters
        .where((letter) => wordData['neededLetters'].contains(letter))
        .toList();

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
                    wordData['word'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            backgroundColor:
                                isSelected ? Colors.amber : Colors.transparent,
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
                              String? submitLetter;
                              setState(() {
                                myLetters = List.from(myLetters)
                                  ..remove(selectedLetter);

                                wordData['providedLetters'] = List<String>.from(
                                    wordData['providedLetters'])
                                  ..add(selectedLetter!);

                                wordData['neededLetters'] =
                                    List<String>.from(wordData['neededLetters'])
                                      ..remove(selectedLetter);
                                submitLetter = selectedLetter;
                                selectedLetter = null; // 선택된 글자 초기화
                              });
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: suggestedWords.length,
                itemBuilder: (context, index) {
                  final wordData = suggestedWords[index];
                  return GestureDetector(
                    onTap: () => _showSubmitDialog(context, wordData),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '제안단어',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    wordData['word'],
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
                                      '제출된 글자', wordData['providedLetters']),
                                  SizedBox(width: 10),
                                  _buildLetterContainer(
                                      '필요글자', wordData['neededLetters']),
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
                        Text(
                          '내 단어',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildLetterContainer(String title, List<String> letters) {
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
            height: 60, // 고정 높이 설정
            child: Wrap(
              spacing: 8.0,
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
