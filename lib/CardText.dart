import 'package:memorize/c.dart';

class CardText {
  final RunesBuffer runes = [];
  final List<Segment> segments = [Segment(0, 0)];
  final List<int> lines = [0];
  final List<Hurigana> huriganas = [];
  final List<Blank> blanks = [];

  CardText(String script) {
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
        segments.last.tags.add('#');
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

    for(final segment in segments){
      final t = Set<String>.from(segment.tags);
      segment.tags.clear();
      segment.tags.addAll(t);
    }
  }

  String toScript() {
    final Map<int, List<String>> insert = {};
    for (final segment in segments) {
      (insert[segment.start] ??= []).add(
          '${segment.start == 0 ? '' : '/'}${segment.tags.map((e) => '$e ').join('')}');
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

    return decodeNumber(_insertAtPositions(runes, insert));
  }

  RunesBuffer _insertAtPositions(RunesBuffer input, Map<int, List<String>> insert) {
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

  Segment findSegment(int pos){
    for(var seg in segments.reversed){
      if(pos >= seg.start) return seg;
    }
    return segments.first;
  }
}
