import 'package:flutter/material.dart';
import 'package:memorize/util.dart';

typedef RunesBuffer = List<int>;

class Chars {
  final RunesBuffer runes = [];
  final List<Segment> segments = [Segment(0, 0)];
  final List<int> lines = [0];
  final List<Hurigana> huriganas = [];
  final List<Blank> blanks = [];

  Chars(String script) {
    final scriptRunes = codeNumber(script);

    bool modeHurigana = false;
    bool modeBlank = false;
    bool modeTag = false;
    int lastNoReqHurigana = -1;

    for (var rune in scriptRunes) {
      final c = String.fromCharCode(rune);

      if (modeHurigana) {
        if (c == '}') {
          modeHurigana = false;
        } else {
          huriganas.last.text += c;
        }
      } else if (modeTag) {
        if (c == ' ') {
          modeTag = false;
        } else {
          segments.last.tags.last += c;
        }
      } else if (modeBlank && c == '>') {
        modeBlank = false;
        blanks.last.end = runes.length;
      } else if (c == '\n') {
        lines.add(runes.length);
      } else if (c == '<') {
        modeBlank = true;
        blanks.add(Blank(id: blanks.length, start: runes.length));
      } else if (c == '#') {
        modeTag = true;
        segments.last.tags.add('');
      } else if (c == '{') {
        modeHurigana = true;
        huriganas.add(
            Hurigana(start: lastNoReqHurigana + 1, end: runes.length, text: ''));
        lastNoReqHurigana = runes.length - 1;
      } else if (c == '/') {
        segments.add(Segment(segments.length, runes.length));
      } else if (rune < 0x20) {
      } else {
        if (!((rune >= 0x2E80 && rune <= 0x2FDF) ||
            (rune == 0x3005) ||
            (rune >= 0x3400 && rune <= 0x4DBF) ||
            (rune >= 0x4E00 && rune <= 0x9FFF) ||
            (rune >= 0xF900 && rune <= 0xFAFF) ||
            (rune >= 0x20000 && rune <= 0x3FFFF))) {
          lastNoReqHurigana = runes.length;
        }

        runes.add(rune);
      }
    }
  }

  String toScript() {
    final Map<int, List<String>> insert = {};
    for (final segment in segments) {
      (insert[segment.start] ??= []).add(
          '${segment.start == 0 ? '' : '/'}${segment.tags.map((e) => '#$e ').join('')}');
    }
    for (final line in lines) {
      if (line != 0) (insert[line] ??= []).add('\n');
    }
    for (final blank in blanks) {
      if (blank.start > blank.end) continue;
      (insert[blank.start] ??= []).add('<');
      (insert[blank.end] ??= []).add('>');
    }
    for (final hurigana in huriganas) {
      if (hurigana.start > hurigana.end) continue;
      (insert[hurigana.end] ??= []).add('{${hurigana.text}}');
    }

    return decodeNumber(insertAtPositions(runes, insert));
  }

  RunesBuffer insertAtPositions(RunesBuffer input, Map<int, List<String>> insert) {
    RunesBuffer result = [];
    int inputLength = input.length;

    for (int i = 0; i <= inputLength; i++) {
      if (insert.containsKey(i)) {
        for (final s in insert[i]!) {
          result.addAll(s.runes);
        }
      }
      if (i < inputLength) {
        result.add(input.elementAt(i));
      }
    }

    return result;
  }
}


  RunesBuffer codeNumber(String str) {
    str = toHankaku(str);
    RegExp regExp = RegExp(r'\((\d+)\)');
    RunesBuffer runes = [];
    int lastMatchEnd = 0;

    Iterable<Match> matches = regExp.allMatches(str);

    for (Match match in matches) {
      runes.addAll(str.substring(lastMatchEnd, match.start).runes);
      int number = int.parse(match.group(1)!);
      int newCodePoint = clamp(EXTRA_FIRST_CODE + number, 0, 0x10FFFF) ;
      runes.add(newCodePoint);
      lastMatchEnd = match.end;
    }
  runes.addAll(str.substring(lastMatchEnd).runes);

  return runes;
}
const int EXTRA_FIRST_CODE = 0xE01F0;
  String decodeNumber(RunesBuffer runes) {
    
    StringBuffer modifiedString = StringBuffer();

    for (int i = 0; i < runes.length; i++) {
      final codePoint = runes.elementAt(i);
      if (codePoint >= EXTRA_FIRST_CODE) {
        int number = codePoint - EXTRA_FIRST_CODE;
        modifiedString.write('($number)');
      } else {
        modifiedString.writeCharCode(codePoint);
      }
    }

    return modifiedString.toString();
  }

String toHankaku(String input) {
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    int codeUnit = input.codeUnitAt(i);
    // 全角英数字および記号の場合
    if (codeUnit >= 0xFF01 && codeUnit <= 0xFF5E) {
      buffer.writeCharCode(codeUnit - 0xFEE0);
    } else if (codeUnit == 0x3000) {
      // 全角スペースの場合
      buffer.writeCharCode(0x0020);
    } else {
      // その他の文字はそのまま追加
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}


T? findRange<T extends Range>(List<T> list, int v) {
  for (var i = 0; i < list.length; i++) {
    if (v >= list[i].start && v < list[i].end) return list[i];
  }
  return null;
}

T? find<T>(Iterable<T> list, bool Function(T v) f) {
  for (var i = 0; i < list.length; i++) {
    if (f(list.elementAt(i))) return list.elementAt(i);
  }
  return null;
}

class Segment {
  int id;
  int start;
  final List<String> tags = [];
  Segment(this.id, this.start);
}

class Range {
  int start;
  int end;

  Range({this.start = 0, this.end = 0});
}

class Blank extends Range {
  int id;

  Blank({this.id = 0, int start = 0, int end = 0})
      : super(start: start, end: end);
}

class Hurigana extends Range {
  String text;

  Hurigana({this.text = '', int start = 0, int end = 0})
      : super(start: start, end: end);
}

const double fontSize = 20;
const TextStyle style =
    TextStyle(fontSize: fontSize, height: 1.1, fontFamily: 'Serif');
const TextStyle qstyle = TextStyle(
    fontSize: fontSize, height: 1.1, color: Colors.red, fontFamily: 'Serif');
const TextStyle hstyle =
    TextStyle(fontSize: fontSize * 0.35, height: 1.1, fontFamily: 'Serif');

Widget CharsView(Chars cs,
    {Widget Function(Chars cs, int pos) cview = noqchar}) {
  final List<Range> viewLines = [];
  int lineI = 0;
  int pos = cs.lines[lineI];
  for (;;) {
    final int end =
        lineI + 1 == cs.lines.length ? cs.runes.length : cs.lines[lineI + 1];
    final pre = pos;
    pos += 26;
    if (pos >= end) {
      pos = end;
      lineI++;
    }
    viewLines.add(Range(start: pre, end: pos));
    if (lineI >= cs.lines.length) break;
  }

  final space = (style.fontSize ?? 0) * 0.4;

  return Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.rtl,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final viewLine in viewLines)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: space),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = viewLine.start; i < viewLine.end; i++) cview(cs, i)
            ],
          ),
        ),
    ],
  );
}

Widget noqchar(Chars cs, int pos) {
  final hurigana = find(cs.huriganas, (h) => h.start == pos);
  final char = cs.runes[pos];
  if (hurigana == null) {
    return character(char, style);
  } else {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        character(char, style),
        Positioned(
          // ここでポップアップの位置を調整
          right: -(hstyle.fontSize ?? 0) - 1,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.from(
                  hurigana.text.characters.map((c) => character(c.codeUnits[0], hstyle))),
            ),
          ),
        ),
      ],
    );
  }
}

Widget character(int rune, TextStyle style) {
  if(rune >= EXTRA_FIRST_CODE){
    return Text('(${rune - EXTRA_FIRST_CODE})', style: style);
  }

  final char = String.fromCharCode(rune);

  if (VerticalRotated.map[char] != null) {
    return Text(VerticalRotated.map[char]!, style: style);
  }
  else {
    return Text(char, style: style);
  }
}

Map<String, String> romajis = {
  'あ': 'a',
  'い': 'i',
  'う': 'u',
  'え': 'e',
  'お': 'o',
  'か': 'ka',
  'き': 'ki',
  'く': 'ku',
  'け': 'ke',
  'こ': 'ko',
  'さ': 'sa',
  'し': 'si',
  'す': 'su',
  'せ': 'se',
  'そ': 'so',
  'た': 'ta',
  'ち': 'ti',
  'つ': 'tu',
  'て': 'te',
  'と': 'to',
  'な': 'na',
  'に': 'ni',
  'ぬ': 'nu',
  'ね': 'ne',
  'の': 'no',
  'は': 'ha',
  'ひ': 'hi',
  'ふ': 'hu',
  'へ': 'he',
  'ほ': 'ho',
  'ま': 'ma',
  'み': 'mi',
  'む': 'mu',
  'め': 'me',
  'も': 'mo',
  'や': 'ya',
  'ゆ': 'yu',
  'よ': 'yo',
  'ら': 'ra',
  'り': 'ri',
  'る': 'ru',
  'れ': 're',
  'ろ': 'ro',
  'わ': 'wa',
  'を': 'wo',
  'ん': 'nn',
  'が': 'ga',
  'ぎ': 'gi',
  'ぐ': 'gu',
  'げ': 'ge',
  'ご': 'go',
  'ざ': 'za',
  'じ': 'zi',
  'ず': 'zu',
  'ぜ': 'ze',
  'ぞ': 'zo',
  'だ': 'da',
  'ぢ': 'di',
  'づ': 'du',
  'で': 'de',
  'ど': 'do',
  'ば': 'ba',
  'び': 'bi',
  'ぶ': 'bu',
  'べ': 'be',
  'ぼ': 'bo',
  'ぱ': 'pa',
  'ぴ': 'pi',
  'ぷ': 'pu',
  'ぺ': 'pe',
  'ぽ': 'po',
  'ゃ': 'xya',
  'ゅ': 'xyu',
  'ょ': 'xyo',
};

class VerticalRotated {
  static const map = {
    ' ': '　',
    '↑': '→',
    '↓': '←',
    '←': '↑',
    '→': '↓',
    '。': '︒',
    '、': '︑',
    'ー': '丨',
    '─': '丨',
    '-': '丨',
    'ｰ': '丨',
    '_': '丨 ',
    '−': '丨',
    '－': '丨',
    '—': '丨',
    '〜': '丨',
    '～': '丨',
    '／': '＼',
    '…': '︙',
    '‥': '︰',
    '︙': '…',
    '：': '︓',
    ':': '︓',
    '；': '︔',
    ';': '︔',
    '＝': '॥',
    '=': '॥',
    '（': '︵',
    '(': '︵',
    '）': '︶',
    ')': '︶',
    '［': '﹇',
    "[": '﹇',
    '］': '﹈',
    ']': '﹈',
    '｛': '︷',
    '{': '︷',
    '＜': '︿',
    '<': '︿',
    '＞': '﹀',
    '>': '﹀',
    '｝': '︸',
    '}': '︸',
    '「': '﹁',
    '」': '﹂',
    '『': '﹃',
    '』': '﹄',
    '【': '︻',
    '】': '︼',
    '〖': '︗',
    '〗': '︘',
    '｢': '﹁',
    '｣': '﹂',
    ',': '︐',
    '､': '︑',
    '―': '丨'
  };
}
