import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

class Card{
  String answer;
  String question;
  Set<String> tags;

  Card(this.question, this.answer, this.tags);
}

class TextsProvider with ChangeNotifier {
  List<Card> texts = [Card('', '', {})];
  int start = 0;
  bool online = false;

  List<int> filter(){
    final List<int> indexs = [];
    for(var i = 0; i < texts.length; i ++){
      if(texts[i].tags.contains('bookmark')) indexs.add(i);
    }
    return indexs;
  }

  Future<void> addTag(int index, String name) async {
    texts[index].tags.add(name);
    notifyListeners();
    await saveToFile();
  }

  Future<void> removTag(int index, String name) async {
    texts[index].tags.remove(name);
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


  Future<bool> fetch() async {try{
    final response = await http.get(Uri.parse('https://ri-n.com/fetch.php'));

    print(response.statusCode);
    if (response.statusCode != 200) return false;

    print(response.body);
    final script = decryptData(response.body);
    print(script);
    fromScripts(script);
    
    return true;
  }catch(e){print('fetch: $e'); return false;}}

Future<bool> send() async {
  try {
    final encryptedData = encryptData(toScripts());
    print('Sending encrypted data...');
    final response = await http.post(
      Uri.parse('https://ri-n.com/send.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'password': 'wvLb5bkBkDgK2UfTXYhAtHEJyNqtaZUf', 'data': encryptedData}),
    );

    if (response.statusCode != 200) {
      print('Failed to send data. Status code: ${response.statusCode}');
      return false;
    }

    print('Response received: ${response.body}');

    if(response.body != 'Data saved successfully') return false;

    print('Data sent successfully.');
    return true;
  } catch (e) {
    print('Exception occurred: $e');
    return false;
  }
}


}

final key = encrypt.Key.fromUtf8('dUyrHy3WF3cBciZKd5Harzs1fPlkASY7'); // 32文字のキーを指定
final iv = encrypt.IV.fromUtf8('gT70hlCvkM5VpXqR');

String encryptData(String plainText) {
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

String decryptData(String encryptedText) {
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  return decrypted;
}
