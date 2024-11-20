import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HiddenWordOpenPage extends StatefulWidget {
  @override
  _HiddenWordOpenPageState createState() => _HiddenWordOpenPageState();
}

class _HiddenWordOpenPageState extends State<HiddenWordOpenPage> {
  List<String> ownedLetters = [];
  String selectedLetter = '';
  String hiddenWord = '';
  bool isHiddenWordSuccess = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> showHiddenWordPopup() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://3.34.102.55:8080/member/1/payment/is-include-hidden-letter?date=2024-11-19'),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        final isInclude = data['isInclude'];
        final letter = data['letter'];

        setState(() {
          hiddenWord = letter;
          isHiddenWordSuccess = isInclude;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isInclude
                        ? '히든 글자는 "$letter" 입니다!\n새로운 글자를 획득하셨습니다!'
                        : '히든 글자는 "$letter" 입니다.\n아쉽지만 획득하지 못했어요.\n내일 기회를 잡아보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF6E6053),
                      padding:
                      EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isInclude && !ownedLetters.contains(letter)) {
                        addHiddenWordToOwnedLetters(letter);
                      }
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        _showErrorDialog();
      }
    } catch (e) {
      print('Exception occurred: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            '서버와의 연결에 실패했습니다.\n잠시 후 다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void addHiddenWordToOwnedLetters(String letter) {
    if (!ownedLetters.contains(letter)) {
      setState(() {
        if (ownedLetters.length < 6) {
          ownedLetters.add(letter);
        } else {
          showReplaceDialog(letter);
        }
      });
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
        print('Letter replacement successful');
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('히든글자 공개', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'KB Pay 로 결제한 가게에\n히든글자가 있다면 포인트리 지급!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Image.asset(
                  'assets/images/payment_image.png',
                  height: 350,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: showHiddenWordPopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '어제의 히든 글자 확인하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 보유 글자',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (var letter in ownedLetters)
                          Padding(
                            padding: const EdgeInsets.only(right: 9.0),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.amber[100],
                              child: Text(
                                letter,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '서비스 이용 안내',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '• KB Pay로 4,000원 이상 결제한 내역 중 상호명에 히든 글자가 \n포함된 경우 포인트리가 적립됩니다.\n'
                            '• 히든글자는 매일 오전 9시에 공개됩니다.\n'
                            '• 히든글자는 최대 6개의 글자를 소유할 수 있습니다.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}