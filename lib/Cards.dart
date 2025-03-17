
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:memorize/TagPicker.dart';
import 'package:memorize/parser.dart';
import 'package:memorize/util.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'card.dart';
import 'package:flutter/services.dart' show rootBundle;

class Cards with ChangeNotifier {
  List<String> _cardScripts = [''];
  List<int> _deck = [];
  int current = -1;
  FilterQuery _filter = FilterQuery('');

  FilterQuery get filter => _filter;

  String _tag = '#ふせん';

  String get tag => _tag;

  List<String> filterHistory = [];

  void setTag(String value) {
    if(!isTag(value)) return;
    _tag = value;
    notifyListeners();
  }

  UnmodifiableListView<int> get deck{
    return UnmodifiableListView(_deck);
  }

  UnmodifiableListView<String> get cardScripts{
    return UnmodifiableListView(_cardScripts);
  }

  void setCurrent(int card, [bool notify = true]){
    current = card;
    /*if(notify) */notifyListeners();
  }

  void setCard(int i, Card card, [bool notify = true]){
    if(i < 0 || i >= _cardScripts.length) return;
    _cardScripts[i] = card.getScript();
    if(notify) updateDeck();
  }

  Card? getCard(int i){
    if(i < 0 || i >= _cardScripts.length) return null;
    return Card(i,_cardScripts[i]);
  }

  void setFilter(String script) {
    script = script.trim();
    _filter = FilterQuery(script);
    updateDeck();

    if(_deck.isEmpty || script.isEmpty) return;

    filterHistory.remove(script);

    filterHistory.add(script);
    
    if(filterHistory.length > 10) filterHistory.removeRange(0,filterHistory.length - 10);
  }

  void updateDeck() {
    _deck = filter.execute((i) => _cardScripts[i], _cardScripts.length);

    current = findClosestCard(current,_deck);

    notifyListeners();
  }

  void setScripts(String script) {

    _cardScripts = script.split('\n###\n');
    updateDeck();

    notifyListeners();
  }

  String getScripts() {
    return _cardScripts.join('\n###\n');
  }

  void editDeckScript(String Function(String script) edit, {bool applyAll = false}){
    for (var i in applyAll ? List.generate(_cardScripts.length, (i) => i) : deck) {
      _cardScripts[i] = edit(_cardScripts[i]);
    }
    notifyListeners();
  }

  Future<void> save() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.txt');
    await file.writeAsString(getScripts());
  }

  Future<void> load() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data.txt');
      final read = await file.readAsString();
      setScripts(read);
      setTag(extractHashTags(_cardScripts).first);
    } catch (e) {
      try{
      final defaultContent = await rootBundle.loadString('assets/data.txt');
      setScripts(defaultContent);
      }catch(e){
        print("Error reading file: $e");
      }
    }
  }

  Future<bool> download() async {
    try {
      final response = await http.get(Uri.parse('https://rintify.sakura.ne.jp/wg0t394hgoihj3oghwoihioh2/fetch.php'));

      print(response.statusCode);
      if (response.statusCode != 200) return false;

      print(response.body);
      final script = decryptData(response.body);
      print(script);
      setScripts(script);

      return true;
    } catch (e) {
      print('fetch: $e');
      return false;
    }
  }

  Future<bool> upload() async {
    try {
      final encryptedData = encryptData(getScripts());
      print('Sending encrypted data...');
      final response = await http.post(
        Uri.parse('https://rintify.sakura.ne.jp/wg0t394hgoihj3oghwoihioh2/send.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'password': 'wvLb5bkBkDgK2UfTXYhAtHEJyNqtaZUf',
          'data': encryptedData
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send data. Status code: ${response.statusCode}');
        return false;
      }

      print('Response received: ${response.body}');

      if (response.body != 'Data saved successfully') return false;

      print('Data sent successfully.');
      return true;
    } catch (e) {
      print('Exception occurred: $e');
      return false;
    }
  }
}

bool isTag(String value){
  return RegExp(r'^#[^ #\n*]+$').hasMatch(value);
}

String markTag(String tag){
  return '#*${tag.substring(1)}';
}