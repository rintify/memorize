import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:memorize/data.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/main.dart';
import 'package:memorize/ModeNormal.dart';

class Card{
  String answer;
  String question;
  Set<String> tags;

  Card(this.question, this.answer, this.tags);
}

class TextsProvider with ChangeNotifier {
  List<Card> texts = [Card('', '', {})];
  int start = 0;

  List<int> filter(){
    final List<int> indexs = [];
    for(var i = 0; i < texts.length; i ++){
      if(texts[i].tags.contains('bookmark')) indexs.add(i);
    }
    return indexs;
  }

  Future<void> addBookmark(int index) async {
    texts[index].tags.add('bookmark');
    notifyListeners();
    await saveToFile();
  }

  Future<void> removeBookmark(int index) async {
    texts[index].tags.remove('bookmark');
    notifyListeners();
    await saveToFile();
  }

  String toScripts(){
    return List.generate(texts.length, (i){
      return toScript(i);
    }).join('\n###\n');
  }

  void fromScripts(String script){
    texts.clear();

    final cardBlocks = script.split('\n###\n');
    for(var i = 0; i < cardBlocks.length; i ++){
      fromScript(i, cardBlocks[i]);
    }

    if(texts.isEmpty) texts = [Card('', '', {})];

    notifyListeners();
  }

  String toScript(int index) {
    final script = [
      texts[index].question,
      texts[index].answer,
      texts[index].tags.join(' '),
    ].join('\n##\n');
    return script;
  }

  void fromScript(int index, String script) {
    final a = script.split('\n##\n');
    final blocks = List.generate(3,(i) => i < a.length ? a[i] : '');
    final card = Card(blocks[0],blocks[1],Set.from(blocks[2].split(' ')));
    if(index < texts.length) texts[index] = card;
    else texts.add(card);

    notifyListeners();
  }

  Future<void> saveToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.txt');
    await file.writeAsString(toScripts());
  }

  Future<void> loadFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data.txt');
      final read = await file.readAsString();
      fromScripts(read);
    } catch (e) {
      print("Error reading file: $e");
    }
  }
}
