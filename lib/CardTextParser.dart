import 'dart:ui';

import 'package:memorize/util.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';
import 'package:petitparser/petitparser.dart';

const kanji = r'\u2E80-\u2FDF\u3005\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\u{20000}-\u{3FFFF}';

class CardGrammar extends GrammarDefinition {
  @override
  Parser start() => (ref0(()=>pattern('a+').flatten()) & (char('/').plus() & ref0(()=>pattern('b+').flatten())).star()).end();

  Parser segment() => ref0(tags) & ref0(fragment).plus();

  Parser tags() => (ref0(tag) & char(' ')).star();
  Parser tag() => pattern(r'#[^ #]+').flatten();

  Parser fragment() => kanjis() | pattern(r'[^#/{}]+');

  Parser kanjis() => pattern('[$kanji]+').flatten() & (char('{') & pattern(r'[^}]+') & char('}')).optional();
}


class CardEvaluator extends CardGrammar {
  Parser start() => super.start().map((c){print(c); return '';});
}

