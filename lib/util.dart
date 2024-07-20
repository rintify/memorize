  import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

int findClosestCard(int card, List<int> deck) {
    if(deck.isEmpty) return -1;
    int closestPage = deck.first;
    int minDifference = (deck.first - card).abs();

    for (int deckCard in deck.reversed) {
      int difference = (deckCard - card).abs();
      if (difference < minDifference) {
        closestPage = deckCard;
        minDifference = difference;
      }
    }
    return closestPage;
  }

class Use extends HookWidget {
  final Widget Function(BuildContext context) buildFunction;

  const Use(this.buildFunction, {super.key});

  @override
  Widget build(BuildContext context) {
    return buildFunction(context);
  }
}

int clamp(int v, int min, int max){
  if(v > max) v = max;
  if(v < min) v = min;
  return v;
}

E atClamp<E>(Iterable<E> a, int i){
  if(i < 0) i = 0;
  if(i >= a.length) i = a.length - 1;
  return a.elementAt(i);
}

final key =
    encrypt.Key.fromUtf8('dUyrHy3WF3cBciZKd5Harzs1fPlkASY7'); // 32文字のキーを指定
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

bool isInteger(num? value) {
  if(value == null) return false; 
  return value == value.floor();
}

final whiteSpace = RegExp('[ 　\n]+');

class FilterQuery{
  late List<String> _andWords;
  late String _last;

  get last => _last;

  FilterQuery(String script){
    _andWords = script.trim().split(whiteSpace);
    _last = _andWords.isEmpty ? '' : _andWords.last;
  }

  bool match(String str) {
    for (String word in _andWords) {
      if (!str.contains(word)) {
        return false;
      }
    }
    return true;
  }
  
}