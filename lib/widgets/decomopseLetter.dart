// lib/widgets/decomposeLetter.dart

List<String> decomposeLetter(String letter) {
  // 초성, 중성, 종성 배열 정의
  final List<String> chosungs = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];
  final List<String> jungsungs = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"];
  final List<String> jongsungs = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];

  // 한글 유니코드 시작점 (가)
  const int baseCode = 0xAC00;

  // 한글이 아닐 경우 빈 배열 반환
  if (letter.length != 1 || letter.codeUnitAt(0) < baseCode || letter.codeUnitAt(0) > baseCode + 11171) {
    return [];
  }

  // 유니코드에서 초성, 중성, 종성 인덱스 추출
  int uniCode = letter.codeUnitAt(0) - baseCode;
  int chosungIndex = uniCode ~/ (21 * 28);
  int jungsungIndex = (uniCode ~/ 28) % 21;
  int jongsungIndex = uniCode % 28;

  // 초성, 중성, 종성으로 분해하여 반환
  return [
    chosungs[chosungIndex],
    jungsungs[jungsungIndex],
    if (jongsungIndex > 0) jongsungs[jongsungIndex]
  ];
}
