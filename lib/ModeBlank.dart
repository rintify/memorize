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

class BlankModeView extends HookWidget {
  BlankModeView();

  @override
  Widget build(BuildContext context) {
    final card = Provider.of<Card>(context);
    final current = useState<int>(0);

    final fontSize = MediaQuery.of(context).size.width < 600 ? 15.0 : 17.0;

    return CurrentGestureController(
      setCurrent: (i) {
        current.value = clamp(i, 0, card.answer.blanks.length);
      },
      getCurrent: () {
        return current.value;
      },
      child: CardView(
        buttons: [
          IconButton(
              onPressed: () {
                current.value--;
                if (current.value < 0) current.value = 0;
              },
              icon: Icon(Icons.undo)),
        ],
        child: Container(
          color: Color(0),
          alignment: Alignment.center,
          child: CardTextView(
            card.answer,
            fontSize: fontSize,
            cview: (cs, pos, fontSize) {
              final blank = findRange(cs.blanks, pos);
              if (blank == null || blank.id < current.value)
                return noqchar(cs, pos, fontSize);
              return character('？'.codeUnitAt(0), makeQStyle(fontSize));
            },
          ),
        ),
      ),
    );
  }
}
