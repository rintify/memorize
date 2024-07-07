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

class BlankModeView extends HookWidget {
  final int card;

  BlankModeView(this.card);

  @override
  Widget build(BuildContext context) {
    final textsProvider = Provider.of<TextsProvider>(context);
    final current = useState<int>(0);

    final cs = useMemoized(() {
      return Chars(textsProvider.texts[card].answer);
    }, [textsProvider.texts[card].answer]);

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
          child: CharsView(cs, cview: (cs, pos) {
            final blank = findRange(cs.blanks, pos);
            if(blank == null || blank.id < current.value) return noqchar(cs, pos);
            return character('？', qstyle);
          },),
        ),
      ),
      buttons: [
        IconButton(onPressed: (){
          current.value--;
          if(current.value < 0) current.value = 0;
        },
        icon: Icon(Icons.undo)),
      ],
    );
  }
}
