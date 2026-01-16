import 'package:flutter/material.dart' hide Card;
import 'package:memorize/CardText.dart';
import 'package:memorize/util.dart';
import 'package:provider/provider.dart';

typedef RunesBuffer = List<int>;

RunesBuffer codeNumber(String str) {
  str = toHankaku(str);
  RegExp regExp = RegExp(r'\((\d+)\)');
  RunesBuffer runes = [];
  int lastMatchEnd = 0;

  Iterable<Match> matches = regExp.allMatches(str);

  for (Match match in matches) {
    runes.addAll(str.substring(lastMatchEnd, match.start).runes);
    int number = int.parse(match.group(1)!);
    int newCodePoint = clamp(EXTRA_FIRST_CODE + number, 0, 0x10FFFF);
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
  int shift;
  final List<String> tags = [];
  Segment(this.id, this.start, {this.shift = 0});
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
  bool question;

  Hurigana({this.text = '', int start = 0, int end = 0, this.question = false})
      : super(start: start, end: end);
}

const double fontSize = 17;
const TextStyle style = TextStyle(
    fontSize: fontSize, color: Colors.black, height: 1, fontFamily: 'Sex');
const TextStyle qstyle = TextStyle(
    fontSize: fontSize, color: Colors.red, height: 1, fontFamily: 'Sex');
const TextStyle hstyle =
    TextStyle(fontSize: fontSize * 0.4, height: 1, fontFamily: 'Sex');
final space = (style.fontSize ?? 0) * 0.4;

final textPainter = TextPainter(
    text: const TextSpan(
      text: 'あ',
      style: style,
    ),
    textDirection: TextDirection.ltr);

final fontoRatio = (textPainter..layout()).height / fontSize;

Widget CardTextView(CardText cs,
    {Widget Function(CardText cs, int pos) cview = noqchar,
    bool end = false,
    int? maxLines}) {
  final List<Range> viewLines = [];
  int lineI = 0;
  int pos = cs.lines[lineI];
  var loopCount = 0;
  for (;;) {
    if (maxLines != null && loopCount >= maxLines) break;
    final int end =
        lineI + 1 == cs.lines.length ? cs.runes.length : cs.lines[lineI + 1];
    final pre = pos;
    pos += 26;
    if (pos >= end) {
      pos = end;
      lineI++;
    }
    viewLines.add(Range(start: pre, end: pos));
    loopCount++;
    if (lineI >= cs.lines.length) break;
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.rtl,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (int j = 0; j < viewLines.length; j++)
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = viewLines[j].start; i < viewLines[j].end; i++)
              cview(cs, i),
            ...(end && j == viewLines.length - 1
                ? [
                    const Text('﹂',
                        style:
                            TextStyle(fontSize: 20, color: Colors.blueAccent))
                  ]
                : [])
          ],
        ),
    ],
  );
}

Widget noqchar(CardText cs, int pos) {
  final hurigana = find(cs.huriganas, (h) => h.start == pos);
  final char = cs.runes[pos];
  final isMarked = cs.marks.contains(pos);

  Widget charWidget = character(char, style);

  if (hurigana != null) {
    charWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        charWidget,
        Positioned(
          // ここでポップアップの位置を調整
          right: -(hstyle.fontSize ?? 0) - 1,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.from(hurigana.text.characters
                  .map((c) => character(c.codeUnits[0], hstyle))),
            ),
          ),
        ),
      ],
    );
  }

  if (isMarked) {
    charWidget = Container(
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1), // ハイライトの色を選択
        shape: BoxShape.circle, // これで円形にする
      ),
      child: Center(child: charWidget), // 子ウィジェットを中央に配置
    );
  }

  return charWidget;
}

Widget character(int rune, TextStyle style) {
  final fontSize = style.fontSize ?? 1;
  final h = fontSize * 1.03, w = space * 2 + fontSize;

  if (rune >= EXTRA_FIRST_CODE) {
    return Container(
        alignment: Alignment.center,
        height: h,
        width: w,
        child: Text('(${rune - EXTRA_FIRST_CODE})', style: style));
  }

  final char = String.fromCharCode(rune);

  if (char == '─') {
    return Container(
      alignment: Alignment.center,
      width: w,
      child: Container(
        width: 1, // 太さ1px
        height: h,
        color: style.color, // 線の色
      ),
    );
  }

  if (char == '│') {
    return Container(
      alignment: Alignment.center,
      height: h,
      child: Container(
        width: w, // 太さ1px
        height: 1,
        color: style.color, // 線の色
      ),
    );
  }

  return Container(
    height: h,
    width: w,
    alignment: Alignment.center,
    color: const Color(0x00000000),
    child: VerticalRotated.map[char] != null
        ? Text(VerticalRotated.map[char]!, style: style)
        : Text(
            char,
            style: style,
            textScaler: TextScaler.noScaling,
          ),
  );
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
