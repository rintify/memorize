
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/util.dart';

class TypeModeView extends HookWidget {
  final String text;
  final ObjectRef<void Function()> onReset;

  TypeModeView(this.text, this.onReset);

  @override
  Widget build(BuildContext context) {
    print('a');
    final focusNode = useFocusNode();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(focusNode);
      });
      return null; // Disposeは不要
    }, []); // 空の依存配列で初回レンダリング時にのみ実行

    final current = useState<int>(-1);
    final input = useState<String>('');

    final (list, css) = useMemoized(() {
      List<(int, int, String romaji)> list = [];
      final css = translateText(text);
      bool afterI = false;

      for (var i = 0; i < css.length; i++) {
        for (var j = 0; j < css[i].length; j++) {
          final c = css[i][j];

          if (c.hurigana.isNotEmpty) {
            list.add((i, j, c.hurigana.map((c) => romajis[c] ?? '').join().replaceAll('ix', '')));
            afterI = false;
          } else {
            var romaji = romajis[c.c] ?? '';
            if (afterI && romaji.startsWith('x')) {
              romaji = (list.removeLast().$3 + romaji).replaceAll('ix', '');
            }
            list.add((i, j, romaji));
            afterI = romaji.endsWith('i');
          }
        }
      }
      current.value = -1;
      input.value = '';
      while (current.value < list.length - 1 && list[current.value + 1].$3.isEmpty) current.value++;
      return (list, css);
    }, [text]);

    onReset.value = () {
      current.value = -1;
      input.value = '';
      while (current.value < list.length - 1 && list[current.value + 1].$3.isEmpty) current.value++;
    };

    Iterable<Iterable<C>> viewCss = [input.value.characters.map((c) => C(c, null))];

    try {
      viewCss = [
        ...css.sublist(0, list[current.value].$1),
        [
          ...css[list[current.value].$1].sublist(0, list[current.value].$2 + 1),
          ...viewCss.first
        ]
      ];
    } catch (e) {}

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (value) {
        try {
          if (current.value >= list.length - 1) return;
          if (list[current.value + 1].$3[input.value.length] == value.character) {
            input.value += value.character!;
          }
          if (value.character == ' ' || input.value == list[current.value + 1].$3) {
            input.value = '';
            if (current.value < list.length - 1) current.value++;
            while (current.value < list.length - 1 && list[current.value + 1].$3.isEmpty) current.value++;
          }
        } catch (e) {}
      },
      child: GestureDetector(
        onTapDown: (a){
          input.value = '';
          if(current.value == list.length - 1) {
            current.value = - 1;
            while (current.value < list.length - 1 && list[current.value + 1].$3.isEmpty) current.value++;
          } else current.value = list.length - 1;
        },
        child: Container(
          color: Color(0),
          alignment: Alignment.center,
          child: CharsView(
            viewCss,
            (c) => noqchar(c),
          ),
        ),
      ),
    );
  }
}
