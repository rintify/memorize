

import 'package:flutter/material.dart';
import 'package:memorize/util.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/petitparser.dart';

import 'package:petitparser/petitparser.dart';

class CardGrammarDefinition extends GrammarDefinition {

  @override
  Parser start() => (ref0(segment) & (ref0(SEG).plus() & ref0(segment)).map((v) => v[1]).star()).map((v) => [v[0],...v[1]]);

  Parser segment() => (ref0(tags).optional() & ref0(frag)).map((v) => Segment(v[0] == null ? {} : Set.from(v[0]), v[1]));

  Parser tags() => (ref0(TAG) & ref0(S)).map((v) => v[0]).plus();

  Parser frag() => (ref0(kanjis) | ref0(NUM) | ref0(word) | ref0(N)).plus();

  Parser word() => (ref0(MOJI) | ref0(S)).plus().flatten().map((v) => NormalWord(v));
  Parser kanjis() => (ref0(KANJI) & ref0(HURIGANA).optional()).map((v) => KanjiWord(v[0], v[1]??''));

  Parser NUM() => (char('(') & digit().plus().flatten() & char(')')).map((v) => NumberWord(parseInt(v[1])));
  Parser SEG() => char('/');
  Parser HURIGANA() => (char('{') & pattern('^}').star().flatten() & char('}')).map((v) => v[1]);
  Parser KANJI() => pattern('\u2E80-\u2FDF\u3005\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF').plus().flatten();
  Parser MOJI() => pattern('a-z').plus().flatten();
  Parser S() => char(' ');
  Parser N() => char('\n').map((v) => LineWord());
  Parser TAG() => (char('#') & ref0(MOJI)).flatten();
}

class Paper extends StatelessWidget{
  List<int> chars = [];
  List<int> huriganas = [];
  final lineCount = 20;
  final rowCount = 10;

  void put(String c, [String hurigana = '']){
    for(var rune in c.runes) {
      chars.add(rune);
    }
    for(var )
  }

  void newLine(){
    int remainder = chars.length % lineCount;
    if (remainder != 0) {
      chars.addAll(List.filled(lineCount - remainder, 0));
    }
  }

  @override
  Widget build(BuildContext context){

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int j = 0; j < chars.length/lineCount; j++)
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = j*lineCount; i < chars.length && i < j + lineCount; i++)
                chars[i]()
            ],
          ),
      ]
    );
  }
}
