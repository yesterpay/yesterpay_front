import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HiddenWordPredictionPage extends StatefulWidget {
  @override
  _HiddenWordPredictionPageState createState() =>
      _HiddenWordPredictionPageState();
}

class _HiddenWordPredictionPageState extends State<HiddenWordPredictionPage> {
  String selectedWord = '';
  bool isSelectionLocked = false;
  List<String> words = [];
  int successCount = 0;
  List<Map<String, dynamic>> participationResults = [];
  bool isLoadingResults = false;
  List<String> ownedLetters = [];
  String selectedLetter = '';

  @override
  void initState() {
    super.initState();
    fetchWords();
    fetchSuccessCount();
    fetchParticipationResults();
    fetchOwnedLetters();
  }

  Future<void> fetchOwnedLetters() async {
    try {
      final response = await http.get(
        Uri.parse('http://3.34.102.55:8080/member/1/letter'),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List;

        setState(() {
          ownedLetters = data.map((item) => item.toString()).toList();
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          ownedLetters = [];
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        ownedLetters = [];
      });
    }
  }

  Future<void> fetchWords() async {
    try {
      final response =
      await http.get(Uri.parse('http://3.34.102.55:8080/predict/candidate'));

      if (response.statusCode == 200) {
        setState(() {
          String decodedResponse = utf8.decode(response.bodyBytes);
          words = List<String>.from(json.decode(decodedResponse));
        });
      } else {
        throw Exception('Failed to load words');
      }
    } catch (e) {
      print('Error fetching words: $e');
    }
  }

  Future<void> fetchSuccessCount() async {
    try {
      final response = await http.get(Uri.parse(
          'http://3.34.102.55:8080/predict/success-count/this-week?memberId=1'));

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        setState(() {
          successCount = int.parse(decodedResponse);
        });
      } else {
        setState(() {
          successCount = 0;
        });
      }
    } catch (e) {
      setState(() {
        successCount = 0;
      });
    }
  }

  Future<void> fetchParticipationResults() async {
    setState(() {
      isLoadingResults = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'http://3.34.102.55:8080/predict/history/this-week?memberId=1'));
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> resultList = json.decode(decodedResponse);

        setState(() {
          participationResults = resultList
              .map<Map<String, dynamic>>(
                  (result) => Map<String, dynamic>.from(result))
              .toList();
          isLoadingResults = false;
        });
      } else {
        setState(() {
          isLoadingResults = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingResults = false;
      });
    }
  }

  Future<void> fetchHiddenLetter(String date) async {
    try {
      final response = await http.get(
        Uri.parse('http://3.34.102.55:8080/predict/history/this-week?memberId=1'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> historyList = json.decode(decodedResponse);

        final selectedResult = historyList.firstWhere(
              (result) => result['date'] == date && result['isSuccess'] == true,
          orElse: () => null,
        );

        if (selectedResult != null && selectedResult.containsKey('hiddenLetter')) {
          final hiddenLetter = selectedResult['hiddenLetter'];

          // 히든 글자를 보유 목록에 추가
          addHiddenWordToOwnedLetters(hiddenLetter); // << 추가 처리

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "히든 글자 획득!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "획득한 히든 글자:",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      hiddenLetter,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "확인",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          throw Exception('히든 글자를 찾을 수 없습니다.');
        }
      } else {
        throw Exception('히든 글자를 가져올 수 없습니다.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("오류 발생",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Text("히든 글자를 가져오는 중 오류가 발생했습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  void addHiddenWordToOwnedLetters(String letter) {
    print("추가하려는 글자: $letter");
    print("현재 보유 글자 목록: $ownedLetters");

    if (!ownedLetters.contains(letter)) {
      setState(() {
        if (ownedLetters.length < 6) {
          ownedLetters.add(letter);
          print("글자 추가됨: $ownedLetters");
        } else {
          // 보유 글자가 6개일 경우 교체 다이얼로그 호출
          print("교체 팝업 호출");
          showReplaceDialog(letter);
        }
      });
    } else {
      print("이미 보유 중인 글자: $letter");
    }
  }


  Future<void> replaceLetter(String existingLetter, String newLetter) async {
    try {
      final response = await http.post(
        Uri.parse('http://3.34.102.55:8080/member/1/letter/new'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'existingLetterList': [existingLetter],
          'newLetterList': [newLetter],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          ownedLetters[ownedLetters.indexOf(existingLetter)] = newLetter;
        });
        print('Letter replacement successful. New ownedLetters: $ownedLetters');
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }


  void showReplaceDialog(String newLetter) {
    setState(() {
      selectedLetter = ownedLetters.isNotEmpty ? ownedLetters[0] : '';
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "글자 보유 가능 개수를 초과하였습니다.\n어떤 글자와 바꾸시겠습니까?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: _buildFixedLetterRows(setDialogState),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedLetter != "바꾸지 않기" &&
                        ownedLetters.contains(selectedLetter)) {
                      setState(() {
                        ownedLetters[ownedLetters.indexOf(selectedLetter)] =
                            newLetter;
                      });
                      replaceLetter(selectedLetter, newLetter);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text("확인"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("바꾸지 않기"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildFixedLetterRows(Function setDialogState) {
    List<Widget> rows = [];
    for (int i = 0; i < ownedLetters.length; i += 3) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ownedLetters
              .skip(i)
              .take(3)
              .map((letter) => ChoiceChip(
            label: Text(letter),
            selected: selectedLetter == letter,
            selectedColor: Colors.amber[100],
            onSelected: (bool selected) {
              setDialogState(() {
                selectedLetter = letter;
              });
            },
          ))
              .toList(),
        ),
      );
      rows.add(SizedBox(height: 10));
    }
    return rows;
  }

  Future<void> sendSelectedWord(String word) async {
    try {
      final response = await http.post(
        Uri.parse('http://3.34.102.55:8080/predict/choose'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'memberId': 1,
          'letter': word,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("히든글자 예측 완료"),
            content: Text("히든글자는 내일 9시에 공개됩니다!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("확인"),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to send prediction');
      }
    } catch (e) {
      print('Error sending prediction: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("예측 실패"),
          content: Text("서버와의 연결에 실패했습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('히든 글자 예측하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/hidden_word_header.png',
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              '이번주 예측 결과',
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '$successCount승',
                            style: TextStyle(fontSize: 25, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await fetchParticipationResults();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("참여 결과", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              content: isLoadingResults
                                  ? Center(child: CircularProgressIndicator())
                                  : participationResults.isEmpty
                                  ? Text("이번 주 참여 기록이 없습니다.")
                                  : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: participationResults.map((result) {
                                  return ListTile(
                                    title: Text("${result['date']}"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("히든 글자: ${result['hiddenLetter']}"),
                                        Text("예측 글자: ${result['predictLetter']}"),
                                        Text("결과: ${result['isSuccess'] ? "성공" : "실패"}"),
                                        if (result['isSuccess'])
                                          ElevatedButton(
                                            onPressed: () {
                                              fetchHiddenLetter(result['date']);
                                            },
                                            child: Text("히든 글자 받기"),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("확인"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            '참여결과 보기',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: words.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: words.map((word) => buildPredictionOption(word)).toList(),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '서비스 이용 안내',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('• 매일 08:00~23:00에 참여 가능합니다.'),
                  SizedBox(height: 5),
                  Text('• 4개의 글자가 제공되며 1개의 글자를 선택할 수 있습니다.'),
                  SizedBox(height: 5),
                  Text('• 선택한 히든 글자는 변경 불가합니다.'),
                  SizedBox(height: 5),
                  Text('• 히든 글자는 매일 오전 9시에 공개됩니다.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPredictionOption(String word) {
    bool isSelected = selectedWord == word;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!isSelectionLocked) {
            selectedWord = word;
            isSelectionLocked = true;
            sendSelectedWord(word);
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Color(0xFFFFF3DC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.orange : Colors.transparent, width: 0.1),
        ),
        padding: EdgeInsets.all(8),
        child: Text(
          word,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
