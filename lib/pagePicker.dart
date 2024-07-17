import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/main.dart';
import 'package:memorize/ModeNormal.dart';

void showPagePicker(BuildContext context, int current, Function(int index) onResult) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      final cards = Provider.of<Cards>(context);
      final ScrollController scrollController = ScrollController(
        initialScrollOffset: current * 50.0, // ListTileの高さが固定50.0の場合
      );

      return Container(
        height: 300,
        child: ListView.builder(
          controller: scrollController,
          itemCount: cards.deck.length, // テキストの数に合わせて
          itemBuilder: (context, index) {
            final q = cards.cardScripts[cards.deck[index]];
            return Container(
              height: 50.0, // ListTileの高さを固定
              child: ListTile(
                title: Text('${index + 1} - ${q.substring(0,q.length > 10 ? 10 : q.length)}'),
                onTap: () {
                  onResult(index);
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      );
    },
  );
}
