import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeSegment.dart';
import 'package:memorize/c.dart';
import 'package:memorize/CardView.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/CardText.dart';
import 'package:memorize/card.dart';
import 'package:memorize/util.dart';
import 'package:provider/provider.dart';

class NormalModeView extends HookWidget {
  NormalModeView();

  @override
  Widget build(BuildContext context) {
    print('normal');
    final card = Provider.of<Card>(context);
    final cards = Provider.of<Cards>(context);

    final fontSize = MediaQuery.of(context).size.width < 600 ? 15.0 : 17.0;

    return CardView(
      child: Container(
        alignment: Alignment.center,
        child: CardTextView(
          card.answer,
          fontSize: fontSize,
          cview: (cs, pos, fontSize) {
            final segm = cs.findSegment(pos);
            if (segm.tags.contains(cards.tag)) {
              return CView(cs, pos, segm, Colors.amber.withAlpha(200), fontSize,
                  () {
                segm.tags.remove(cards.tag);
                segm.tags.add(markTag(cards.tag));
                card.notify();
                cards.setCard(card.key, card, false);
                cards.save();
              });
            } else if (segm.tags.contains(markTag(cards.tag))) {
              return CView(cs, pos, segm, Colors.blue.withAlpha(150), fontSize,
                  () {
                segm.tags.remove(markTag(cards.tag));
                card.notify();
                cards.setCard(card.key, card, false);
                cards.save();
              });
            } else {
              return CView(cs, pos, segm, null, fontSize, () {
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
    );
  }
}
