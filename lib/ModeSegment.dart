import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/CardView.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/CardText.dart';
import 'package:memorize/card.dart';
import 'package:memorize/util.dart';
import 'package:memorize/c.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

class CurrentGestureController extends HookWidget{
  final Widget child;
  final void Function(int) setCurrent;
  final int Function() getCurrent;

  const CurrentGestureController({super.key, required this.child, required this.getCurrent, required this.setCurrent});

  @override
  Widget build(BuildContext context){

    final startPosition = useRef<(Offset,int)?>(null);
    final size = MediaQuery.of(context).size;
    final unit = size.width*0.2;

    return GestureDetector(
      onTap: () {
        setCurrent(getCurrent() + 1);
      },
      onHorizontalDragStart: (details) {
        startPosition.value = (details.globalPosition,getCurrent());
      },
      onHorizontalDragUpdate: (details) {
        if(startPosition.value == null) return;
        
        final d = Vector2(details.globalPosition.dx - startPosition.value!.$1.dx,
          details.globalPosition.dy - startPosition.value!.$1.dy);
        final len = d.length;
        final fangs = len <= unit ? len : pow((len - unit), 1.2) + unit;
        final di = d.x > 0 ? -(fangs/unit).ceil() : (fangs/unit).floor();
        if(details.globalPosition.dx > size.width*0.93){
          setCurrent(0);
          return;
        }
        if(details.globalPosition.dx < size.width*0.07){
          setCurrent(-1 >>> 1);
          return;
        }
        setCurrent(startPosition.value!.$2 + di);
      },
      child: child,
    );
  }
}

class SegmentModeView extends HookWidget {
  SegmentModeView();

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
      return List<Segment>.from(bookmarkSegments.isNotEmpty && !card.tags.contains(cards.filter.last)
          ? bookmarkSegments
          : card.answer.segments)..sort((a,b) => a.id.compareTo(b.id));
    }, [cards.filter.last]);

    final currentSegment = atClamp(segments, current.value);

    print('${segments.length} ${segments.map((s)=>'${s.id},${s.start}').join(' ')}');

    return CurrentGestureController(
      setCurrent: (i) {
        current.value = clamp(i, 0, segments.length);
      },
      getCurrent: () {
        return current.value;
      },
      child: CardView(
        child: Container(
          color: Color(0),
          alignment: Alignment.center,
          child: CardTextView(
            card.answer,
            end: false,
            cview: (cs, pos) {
              final segm = cs.findSegment(pos);
              final ids = current.value < segments.length ? segments[current.value].id : 0xffffffff;
              if (segm.id < ids) {
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
              }
              return character(' '.codeUnitAt(0), style);
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
