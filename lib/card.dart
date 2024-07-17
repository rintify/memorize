import 'dart:collection';

import 'package:flutter/material.dart' hide Card;
import 'package:memorize/CardText.dart';
import 'package:memorize/Cards.dart';
import 'package:provider/provider.dart';

class Card with ChangeNotifier{
  late CardText _question;
  late CardText _answer;
  late Set<String> _tags;
  final int key;

  Card(this.key, String script){
    setScript(script);
  }

  UnmodifiableListView<String> get tags{
    return UnmodifiableListView(_tags);
  }

  CardText get question => _question;

  CardText get answer => _answer;

  void notify(){
    notifyListeners();
  }

  void addTag(String tag){
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag){
    _tags.remove(tag);
    notifyListeners();
  }

  void setScript(String script) {
    final a = script.split('\n##\n');
    final blocks = List.generate(3,(i) => i < a.length ? a[i] : '');

    _question = CardText(blocks[0]);
    _answer = CardText(blocks[1]);
    _tags = Set.from(blocks[2].split(' '));
    
    notifyListeners();
  }

  String getScript() {
    final script = [
      _question.toScript(),
      _answer.toScript(),
      _tags.join(' '),
    ].join('\n##\n');
    return script;
  }
}