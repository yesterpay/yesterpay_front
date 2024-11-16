import 'package:flutter/material.dart';

class HiddenWordPredictionPage extends StatefulWidget {
  @override
  _HiddenWordPredictionPageState createState() => _HiddenWordPredictionPageState();
}

class _HiddenWordPredictionPageState extends State<HiddenWordPredictionPage> {
  String selectedWord = '';
  bool isSelectionLocked = false;

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
                            '2승',
                            style: TextStyle(fontSize: 25, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("참여 결과", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              content: Text("로딩중 ...."),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // GridView 좌우 여백 추가
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildPredictionOption('비'),
                  buildPredictionOption('바'),
                  buildPredictionOption('보'),
                  buildPredictionOption('당'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Container(
              padding: const EdgeInsets.all(15.0), // 내부 여백
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '서비스 이용 안내',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('• 매일 08:00~23:00에 참여 가능합니다.'),
                  SizedBox(height: 5), // 항목 간 간격
                  Text('• 4개의 글자가 제공되며 1개의 글자를 선택할 수 있습니다.'),
                  SizedBox(height: 5), // 항목 간 간격
                  Text('• 선택한 히든 글자는 변경 불가합니다.'),
                  SizedBox(height: 5), // 항목 간 간격
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
          }
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("히든글자 예측 완료", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Text("히든글자는 내일 9시에 공개됩니다!"),
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