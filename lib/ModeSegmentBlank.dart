import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/CardView.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/CardText.dart';
import 'package:memorize/ModeSegment.dart';
import 'package:memorize/card.dart';
import 'package:memorize/util.dart';
import 'package:memorize/c.dart';
import 'package:provider/provider.dart';

class SegmentBlankModeView extends HookWidget {
  SegmentBlankModeView();

  @override
  Widget build(BuildContext context) {
    final card = Provider.of<Card>(context);
    final cards = Provider.of<Cards>(context);
    final current = useState<int>(0);

    final segments = useMemoized(() {
      final bookmarkSegments = card.answer.segments
          .where((s) => s.tags.contains(cards.filter.last))
          .toList();
      current.value = 0;
      return List<Segment>.from(bookmarkSegments.isNotEmpty
          ? bookmarkSegments
          : card.answer.segments)..sort((a,b) => a.id.compareTo(b.id));
    }, [cards.filter.last]);

    return CurrentGestureController(
      setCurrent: (i) {
        current.value = clamp(i, 0, segments.length);
      },
      getCurrent: () {
        return current.value;
      },
      child: CardView(
        buttons: [
        ],
        child:  Container(
          color: Color(0),
          alignment: Alignment.center,
          child: CardTextView(
            card.answer,
            end: true,
            cview: (cs, pos) {
                final segm = cs.findSegment(pos);
                final ids = current.value < segments.length ? segments[current.value].id : 0xffffffff;
                if(segm.id >= ids && segments.contains(segm)) return character('？'.codeUnitAt(0), qstyle);
                if (segm.tags.contains(cards.tag)) {
                  return CView(cs, pos, segm, Colors.amber.withAlpha(200), () {
                    segm.tags.remove(cards.tag);
                    segm.tags.add(markTag(cards.tag));
                    card.notify();
                    cards.setCard(card.key, card, false);
                    cards.save();
                  });
                } else if (segm.tags.contains(markTag(cards.tag))) {
                  return CView(cs, pos, segm, Colors.blue.withAlpha(150), () {
                    segm.tags.remove(markTag(cards.tag));
                    card.notify();
                    cards.setCard(card.key, card, false);
                    cards.save();
                  });
                } else {
                  return CView(cs, pos, segm, null, () {
                    segm.tags.remove(markTag(cards.tag));
                    segm.tags.add(cards.tag);
                    card.notify();
                    cards.setCard(card.key, card, false);
                    cards.save();
                  });
                }
              
            },
          ),
        ),
      ),
    );
  }
}


    Widget CView(CardText cs, int pos, Segment segm, Color? color,
        void Function() onLongPress) {
      return GestureDetector(
          onLongPress: onLongPress,
          onTap: color == null ? null : onLongPress,
          child: color == null ? noqchar(cs, pos) : Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: color,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              noqchar(cs, pos),
            ],
          ));
    }
