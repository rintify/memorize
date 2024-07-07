import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/c.dart';
import 'package:memorize/data.dart';
import 'package:memorize/editText.dart';
import 'package:provider/provider.dart';


class CardView extends HookWidget {
  final int card;
  final Widget child;
  final List<IconButton> buttons;

  CardView(this.card,this.child,{this.buttons = const[]});

  @override
  Widget build(BuildContext context) {
    final textsProvider = Provider.of<TextsProvider>(context);
    final isBookmarked = useState<bool>(textsProvider.texts[card].tags.contains('bookmark'));

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: 
                  child
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10,10,10,0),
                child: Container(
                  alignment: Alignment.topCenter,
                  child: CharsView(Chars(textsProvider.texts[card].question)),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...buttons,
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
                isBookmarked.value ? Icons.label : Icons.label_outline,
                color: isBookmarked.value ? Colors.amber : null,
              ),
              onPressed: () {
                isBookmarked.value = !isBookmarked.value;
                if (isBookmarked.value) {
                  textsProvider.addTag(card,'bookmark');
                } else {
                  textsProvider.removTag(card,'bookmark');
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
