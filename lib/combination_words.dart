import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_first_flutter_project/widgets/decomopseLetter.dart';
import 'package:practice_first_flutter_project/widgets/combineLetter.dart';

class CombinationWordsPage extends StatefulWidget {
  @override
  _CombinationWordsPageState createState() => _CombinationWordsPageState();
}

class _CombinationWordsPageState extends State<CombinationWordsPage> {
  int combinePermissions = 2;
  List<String> retainedLetters = ["인", "킹", "도", "주", "하", "올"];
  List<String> selectedLetters = [];
  List<String> decomposedCharacters = [];
  String? leftConsonant;
  String? leftVowel;
  String? leftFinalConsonant;
  String? rightConsonant;
  String? rightVowel;
  String? rightFinalConsonant;
  bool isLeftBoxSelected = false;
  bool isRightBoxSelected = false;

  void _copyLinkAndIncreaseCount() {
    Clipboard.setData(ClipboardData(text: "http://yesterpay.com/share"));
    setState(() {
      combinePermissions++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("링크가 복사되었습니다")),
    );
  }

  void _selectLetter(String letter) {
    setState(() {
      if (selectedLetters.contains(letter)) {
        selectedLetters.remove(letter);
      } else {
        if (selectedLetters.length < 2) {
          selectedLetters.add(letter);
        } else {
          selectedLetters.removeAt(0);
          selectedLetters.add(letter);
        }
      }

      decomposedCharacters = [];
      for (String selectedLetter in selectedLetters) {
        decomposedCharacters.addAll(decomposeLetter(selectedLetter));
      }
    });
  }

  void _moveCharacterToBox(String character) {
    setState(() {
      // Only allow moving characters if a box is selected
      if (!isLeftBoxSelected && !isRightBoxSelected) return;

      decomposedCharacters.remove(character);

      if (isLeftBoxSelected) {
        if (leftConsonant == null) {
          leftConsonant = character;
        } else if (leftVowel == null) {
          leftVowel = character;
        } else {
          leftFinalConsonant = character;
        }
      } else if (isRightBoxSelected) {
        if (rightConsonant == null) {
          rightConsonant = character;
        } else if (rightVowel == null) {
          rightVowel = character;
        } else {
          rightFinalConsonant = character;
        }
      }
    });
  }

  void _selectBox(bool isLeft) {
    setState(() {
      isLeftBoxSelected = isLeft;
      isRightBoxSelected = !isLeft;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("남은 자모음은 버려집니다."),
          content: Text("조합을 반영할까요?"),
          actions: [
            TextButton(
              child: Text("아니오"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("예"),
              onPressed: () {
                _applyCombination();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _applyCombination() {
    setState(() {
      if (selectedLetters.length == 2) {
        // 결합된 한글 생성
        String leftCombined = CombineLetter(
          consonant: leftConsonant ?? "",
          vowel: leftVowel ?? "",
          finalConsonant: leftFinalConsonant,
        ).combineKoreanLetters(leftConsonant ?? "", leftVowel ?? "", leftFinalConsonant);

        String rightCombined = CombineLetter(
          consonant: rightConsonant ?? "",
          vowel: rightVowel ?? "",
          finalConsonant: rightFinalConsonant,
        ).combineKoreanLetters(rightConsonant ?? "", rightVowel ?? "", rightFinalConsonant);

        // 결합된 결과를 보유 글자에 반영
        int firstIndex = retainedLetters.indexOf(selectedLetters[0]);
        int secondIndex = retainedLetters.indexOf(selectedLetters[1]);
        if (firstIndex != -1) retainedLetters[firstIndex] = leftCombined;
        if (secondIndex != -1) retainedLetters[secondIndex] = rightCombined;

        // 상태 초기화
        selectedLetters = [];
        decomposedCharacters = [];
        leftConsonant = null;
        leftVowel = null;
        leftFinalConsonant = null;
        rightConsonant = null;
        rightVowel = null;
        rightFinalConsonant = null;
        isLeftBoxSelected = false;
        isRightBoxSelected = false;

        // 조합권 차감
        if (combinePermissions > 0) {
          combinePermissions--;
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("단어 조합하기"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Area
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("두 글자를 조합해서", style: TextStyle(color: Colors.white, fontSize: 20)),
                          Text("원하는 글자를 만들어보세요!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 110,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text("조합권", style: TextStyle(fontSize: 12, color: Colors.black87)),
                                    SizedBox(width: 6),
                                    Text("$combinePermissions 개", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              ElevatedButton(
                                onPressed: _copyLinkAndIncreaseCount,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("공유하고 조합권 받기", style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Image.asset('assets/images/scoop2.png', width: 77, height: 77),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Retained Letters
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("보유 글자", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: retainedLetters.map((letter) {
                        bool isSelected = selectedLetters.contains(letter);
                        return GestureDetector(
                          onTap: () => _selectLetter(letter),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: isSelected ? Colors.green[100] : Colors.white,
                            child: Text(letter, style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    // Combine Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _selectBox(true),
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              border: Border.all(color: isLeftBoxSelected ? Colors.orange : Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: leftConsonant != null
                                  ? CombineLetter(
                                consonant: leftConsonant ?? "",
                                vowel: leftVowel ?? "",
                                finalConsonant: leftFinalConsonant,
                              )
                                  : Text("+", style: TextStyle(color: Colors.grey, fontSize: 32)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectBox(false),
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              border: Border.all(color: isRightBoxSelected ? Colors.orange : Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: rightConsonant != null
                                  ? CombineLetter(
                                consonant: rightConsonant ?? "",
                                vowel: rightVowel ?? "",
                                finalConsonant: rightFinalConsonant,
                              )
                                  : Text("+", style: TextStyle(color: Colors.grey, fontSize: 32)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Decomposed Characters
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Wrap(
                        spacing: 10,
                        children: decomposedCharacters.map((char) {
                          return GestureDetector(
                            onTap: () => _moveCharacterToBox(char),
                            child: Text(char, style: TextStyle(fontSize: 20)),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedLetters = [];
                              decomposedCharacters = [];
                              leftConsonant = null;
                              leftVowel = null;
                              leftFinalConsonant = null;
                              rightConsonant = null;
                              rightVowel = null;
                              rightFinalConsonant = null;
                              isLeftBoxSelected = false;
                              isRightBoxSelected = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12)),
                          child: Text("초기화", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (combinePermissions > 0) {
                              _showConfirmationDialog();
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("조합권이 없습니다."),
                                    content: Text("친구에게 공유하고 조합권을 얻겠습니까?"),
                                    actions: [
                                      TextButton(
                                        child: Text("아니오"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("예"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _copyLinkAndIncreaseCount();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12)),
                          child: Text("완성", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "주의사항\n• 자신이 가진 단어 중 2개를 선택합니다.\n• 원하는 글자로 재조합 할 수 있습니다.\n• 사용된 글자 자료들은 변경됩니다.\n• 카카오톡 공유를 통해 조합권을 획득할 수 있습니다.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}