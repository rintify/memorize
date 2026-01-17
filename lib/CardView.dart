import 'package:memorize/Cards.dart';
import 'package:memorize/TagPicker.dart';
import 'package:memorize/card.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/c.dart';
import 'package:memorize/CardText.dart';
import 'package:memorize/editText.dart';
import 'package:provider/provider.dart';

class CardView extends HookWidget {
  final Widget child;
  final List<IconButton> buttons;

  CardView({required this.child, this.buttons = const []});

  @override
  Widget build(BuildContext context) {
    print('card');
    final card = Provider.of<Card>(context);
    final cards = Provider.of<Cards>(context);

    final fontSize = MediaQuery.of(context).size.width < 600 ? 15.0 : 17.0;

    return Container(
      color: const Color(0x00000000),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: child),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                        child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: CardTextView(card.question,
                                          fontSize: fontSize),
                                    ));
                                  });
                            },
                            child: CardTextView(card.question,
                                maxLines: 2, fontSize: fontSize)),
                      ),
                      Container(
                        width: 30.6,
                        alignment: Alignment.center,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              if (card.tags.contains(cards.tag)) {
                                card.removeTag(cards.tag);
                                card.addTag(markTag(cards.tag));
                                cards.setCard(card.key, card, false);
                                cards.save();
                              } else if (card.tags
                                  .contains(markTag(cards.tag))) {
                                card.removeTag(markTag(cards.tag));
                                cards.setCard(card.key, card, false);
                                cards.save();
                              } else {
                                card.removeTag(markTag(cards.tag));
                                card.addTag(cards.tag);
                                cards.setCard(card.key, card, false);
                                cards.save();
                              }
                            },
                            icon: Icon(
                              card.tags.contains(markTag(cards.tag)) ||
                                      card.tags.contains(cards.tag)
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color: card.tags.contains(markTag(cards.tag))
                                  ? Colors.blue
                                  : card.tags.contains(cards.tag)
                                      ? Colors.amber
                                      : null,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  showTagPicker(context, (tag) {
                    cards.setTag(tag);
                  });
                },
                onLongPress: () {
                  showTagEditorMenu(context, cards.tag);
                },
                onHorizontalDragEnd: (details) {
                  showTagEditorMenu(context, cards.tag);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  color: const Color(0x00000000),
                  child: Text(
                    cards.tag,
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(180, 0, 0, 0),
                    ),
                  ),
                ),
              ),
              ...buttons,
              IconButton(
                onPressed: () {
                  editText(context, card.getScript(), (text) {
                    card.setScript(text);
                    cards.setCard(card.key, card, false);
                    cards.save();
                  });
                },
                icon: Icon(Icons.create),
              ),
              Container(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
