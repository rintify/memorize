import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeBlank.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/ModeSegment.dart';
import 'package:memorize/ModeType.dart';
import 'package:memorize/data.dart';
import 'package:memorize/editText.dart';
import 'package:provider/provider.dart';


class CardView extends HookWidget {
  final int card;
  final int mode;

  CardView(this.card,this.mode);

  @override
  Widget build(BuildContext context) {
    final textsProvider = Provider.of<TextsProvider>(context);
    final isBookmarked = useState<bool>(textsProvider.texts[card].tags.contains('bookmark'));
    final onReset = useRef<void Function()>(() {});

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: 
                  mode == 0 ? NormalModeView(
                    textsProvider.texts[card].answer,
                    onReset,
                  ) : mode == 1 ? BlankModeView(
                    textsProvider.texts[card].answer,
                    onReset,
                  ) : mode == 2 ? TypeModeView(
                    textsProvider.texts[card].answer,
                    onReset,
                  ) : SegmentModeView(textsProvider.texts[card].answer,
                    onReset,),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10,10,10,0),
                child: Container(
                  alignment: Alignment.topCenter,
                  child: CharsView(translateText(textsProvider.texts[card].question), (c) => noqchar(c)),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onReset.value,
              icon: const Icon(Icons.replay),
            ),
            IconButton(
              onPressed: () {
                editText(context, textsProvider.toScript(card), (text) {
                  textsProvider.fromScript(card, text);
                });
              },
              icon: Icon(Icons.create),
            ),
            IconButton(
              icon: Icon(
                isBookmarked.value ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: isBookmarked.value ? Colors.amber : null,
              ),
              onPressed: () {
                isBookmarked.value = !isBookmarked.value;
                if (isBookmarked.value) {
                  textsProvider.addBookmark(card);
                } else {
                  textsProvider.removeBookmark(card);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
