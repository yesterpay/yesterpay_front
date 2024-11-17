import 'package:flutter/material.dart';

class HiddenWordOpenPage extends StatefulWidget {
  final String hiddenWord;
  final List<String> paymentHistory = ['공차', '도미노피자', '버거킹']; // 예시 결제 내역

  HiddenWordOpenPage({required this.hiddenWord});

  @override
  _HiddenWordOpenPageState createState() => _HiddenWordOpenPageState();
}

class _HiddenWordOpenPageState extends State<HiddenWordOpenPage> {
  List<String> ownedLetters = ['인', '킹', '도', '주', '하', '올']; // 초기 보유 글자 목록 (6개로 설정)
  String selectedLetter = ''; // selectedLetter를 여기서 선언하여 팝업 전체에서 접근 가능하게 함

  bool checkHiddenWordInHistory() {
    return widget.paymentHistory.any((entry) => entry.contains(widget.hiddenWord));
  }

  void showReplaceDialog() {
    setState(() {
      selectedLetter = ownedLetters[0]; // Dialog가 열릴 때 selectedLetter를 초기화
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
                    if (selectedLetter != "바꾸지 않기" && ownedLetters.contains(selectedLetter)) {
                      setState(() {
                        ownedLetters[ownedLetters.indexOf(selectedLetter)] = widget.hiddenWord;
                      });
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
      rows.add(SizedBox(height: 10)); // 각 줄 사이의 간격 추가
    }
    return rows;
  }

  void addHiddenWordToOwnedLetters() {
    if (!ownedLetters.contains(widget.hiddenWord)) {
      setState(() {
        if (ownedLetters.length < 6) {
          ownedLetters.add(widget.hiddenWord);
        } else {
          showReplaceDialog();
        }
      });
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
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0), // 위쪽 여백 추가
              child: Text(
                'KB Pay 로 결제한 가게에\n히든글자가 있다면 포인트리 지급!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0), // 이미지와 버튼 사이의 여백 설정
                child: Image.asset(
                  'assets/images/payment_image.png',
                  height: 350,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                bool hasHiddenWord = checkHiddenWordInHistory();
                String contentMessage = hasHiddenWord
                    ? '히든 글자는 ${widget.hiddenWord} 입니다!\n새로운 글자를 획득하셨습니다!'
                    : '히든 글자는 ${widget.hiddenWord} 입니다.\n아쉽지만 획득하지 못했어요.\n내일 기회를 잡아보세요.';

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Text(
                        contentMessage,
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        Center(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF6E6053),
                              padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '닫기',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ).then((_) {
                  if (hasHiddenWord) {
                    addHiddenWordToOwnedLetters();
                  }
                });
              },
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
                  crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
                  children: [
                    Text(
                      '현재 보유 글자',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 글자 아이템을 왼쪽 정렬
                      children: [
                        for (var letter in ownedLetters)
                          Padding(
                            padding: const EdgeInsets.only(right: 9.0), // 글자 간격 설정
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.amber[100],
                              child: Text(
                                letter,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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