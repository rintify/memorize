
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/util.dart';

Widget NormalModeView(String text, ObjectRef<void Function()> onReset){
  return Use((context){
    print('a');
    final questions = useState<List<int>>([]);
    onReset.value = (){
    };

    final cs = useMemoized((){
      return translateText(text);
    },[text]);
    
    return Container(
      alignment: Alignment.center,
      child: CharsView(
        cs,
        (c) => noqchar(c)),
    );
  });
}

class C {
  final String c;
  final List<String> hurigana = [];
  final int? q;
  final int segment;

  C(this.c, this.q, this.segment);
}

const double fontSize = 20;
const TextStyle style =
    TextStyle(fontSize: fontSize, height: 1.1, fontFamily: 'Serif');
const TextStyle qstyle = TextStyle(
    fontSize: fontSize, height: 1.1, color: Colors.red, fontFamily: 'Serif');
const TextStyle hstyle =
    TextStyle(fontSize: fontSize*0.35, height: 1.1, fontFamily: 'Serif');

Widget CharsView(Iterable<Iterable<C>> cs, Widget Function(C c) charView) {
  final space = (style.fontSize ?? 0) * 0.4;
  return Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.rtl,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final line in cs)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: space),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final c in line) charView(c)],
          ),
        ),
    ],
  );
}

List<List<C>> translateText(String text) {
  C? reqHuri;
  bool huriMode = false;
  bool qMode = false;
  int qIndex = 0;
  List<List<C>> cs = [[]];
  int segment = 0;
  for (var rune in text.runes) {
    final c = String.fromCharCode(rune);
    if (huriMode && c == '}') {
      huriMode = false;
      reqHuri = null;
    } else if (huriMode && reqHuri != null) {
      reqHuri.hurigana.add(c);
    } else if (qMode && c == '>') {
      qMode = false;
    } else if (c == '<') {
      qMode = true;
      qIndex++;
    } else if (c == '\n') {
      cs.add([]);
      reqHuri = null;
    } else if(c == '/'){
      segment ++;
    } else if (c == '{')
      huriMode = true;
    else if (rune < 0x20) {
    } else if ((rune >= 0x2E80 && rune <= 0x2FDF) ||
        (rune == 0x3005) ||
        (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0xF900 && rune <= 0xFAFF) ||
        (rune >= 0x20000 && rune <= 0x3FFFF)) {
      final a = C(c, qMode ? qIndex : null, segment);
      cs.last.add(a);
      reqHuri ??= a;
    } else {
      reqHuri = null;
      cs.last.add(C(c, qMode ? qIndex : null, segment));
    }

    if (cs.last.length > 25) {
      cs.add([]);
    }
  }

  return cs;
}

Widget noqchar(C c) {
  if (c.hurigana.isEmpty) {
    return character(c.c, style);
  } else {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        character(c.c, style),
        Positioned(
          // ここでポップアップの位置を調整
          right: -(hstyle.fontSize ?? 0) - 1,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var furigana in c.hurigana) character(furigana, hstyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget character(String char, TextStyle style) {
  if (VerticalRotated.map[char] != null) {
    return Text(VerticalRotated.map[char]!, style: style);
  } else {
    return Text(char, style: style);
  }
}

Map<String, String> romajis = {
    'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
    'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
    'さ': 'sa', 'し': 'si', 'す': 'su', 'せ': 'se', 'そ': 'so',
    'た': 'ta', 'ち': 'ti', 'つ': 'tu', 'て': 'te', 'と': 'to',
    'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
    'は': 'ha', 'ひ': 'hi', 'ふ': 'hu', 'へ': 'he', 'ほ': 'ho',
    'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
    'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
    'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
    'わ': 'wa', 'を': 'wo', 'ん': 'nn',

    'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
    'ざ': 'za', 'じ': 'zi', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
    'だ': 'da', 'ぢ': 'di', 'づ': 'du', 'で': 'de', 'ど': 'do',
    'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
    'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',

    'ゃ': 'xya', 'ゅ': 'xyu', 'ょ': 'xyo',
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
