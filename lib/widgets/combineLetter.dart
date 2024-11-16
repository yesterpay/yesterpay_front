import 'package:flutter/material.dart';

class CombineLetter extends StatelessWidget {
  final String consonant;
  final String vowel;
  final String? finalConsonant;

  CombineLetter({
    required this.consonant,
    required this.vowel,
    this.finalConsonant,
  });

  @override
  Widget build(BuildContext context) {
    if (vowel.isEmpty) {
      // 중성이 아직 입력되지 않았을 때는 초성만 표시
      return Text(consonant, style: TextStyle(fontSize: 32));
    }

    // 초성, 중성, 종성을 조합하여 한글 글자 생성
    String combinedLetter = combineKoreanLetters(consonant, vowel, finalConsonant);

    return Text(combinedLetter, style: TextStyle(fontSize: 32));
  }

  String combineKoreanLetters(String cho, String jung, String? jong) {
    const List<String> chosungs = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];
    const List<String> jungsungs = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"];
    const List<String> jongsungs = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];

    int choIndex = chosungs.indexOf(cho);
    int jungIndex = jungsungs.indexOf(jung);
    int jongIndex = jong != null ? jongsungs.indexOf(jong) : 0;

    if (choIndex < 0 || jungIndex < 0 || jongIndex < 0) {
      return ""; // Invalid combination
    }

    int unicode = 0xAC00 + (choIndex * 21 * 28) + (jungIndex * 28) + jongIndex;
    return String.fromCharCode(unicode);
  }
}
