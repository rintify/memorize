import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/card.dart';
import 'package:memorize/data.dart';
import 'package:memorize/util.dart';
import 'package:memorize/c.dart';
import 'package:provider/provider.dart';

class SegmentModeView extends HookWidget {
  final int card;
  final bool filter;

  SegmentModeView(this.card, this.filter);

  @override
  Widget build(BuildContext context) {
    final textsProvider = Provider.of<TextsProvider>(context);

    final (cs) = useMemoized(() {
      return Chars(textsProvider.texts[card].answer);
    }, [textsProvider.texts[card].answer]);

    final bookmarkSegments = cs.segments.where((s)=>s.tags.contains('bookmark')).toList();
    var segments = filter && bookmarkSegments.isNotEmpty ? bookmarkSegments : cs.segments;
    final current = useState<int>(0);

    final currentSegment = atClamp(segments, current.value - 1);
    final notify = useState<bool>(false);

    return CardView(
      card,
      GestureDetector(
        onTap: () {
            current.value++;
        },
        onLongPress: () {
          current.value = 0;
        },
        child: Container(
          color: Color(0),
          alignment: Alignment.center,
          child: CharsView(
            cs,
            cview: (cs, pos) {
              final seg = current.value >= segments.length
                  ? 0xffffffffff
                  : segments[current.value].start;
              if (pos < seg) return noqchar(cs, pos);
              return character(' ', style);
            },
          ),
        ),
      ),
      buttons: [
        IconButton(
            onPressed: () {
              current.value--;
              if (current.value < 0) current.value = 0;
            },
            icon: Icon(Icons.undo)),
        IconButton(
            onPressed: () {
              if(!currentSegment.tags.contains('bookmark')){
                currentSegment.tags.add('bookmark');
                textsProvider.texts[card].tags.add('bookmark');
              }
              else{
                currentSegment.tags.remove('bookmark');
              }
              notify.value = !notify.value;
              textsProvider.texts[card].answer = cs.toScript();
              textsProvider.saveToFile();
            },
            icon: Icon(currentSegment.tags.contains('bookmark') ? Icons.bookmark : Icons.bookmark_add_outlined)),
      ],
    );
  }
}
