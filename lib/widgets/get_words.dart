import 'package:flutter/material.dart';

class WordManager extends ChangeNotifier {
  List<String> _words = ["인", "킹", "도", "주", "하", "올"];

  List<String> get words => _words;

  void updateWord(int index, String newWord) {
    if (index >= 0 && index < _words.length) {
      _words[index] = newWord;
      notifyListeners();
    }
  }

  void resetWords() {
    _words = ["인", "킹", "도", "주", "하", "올"];
    notifyListeners();
  }
}
