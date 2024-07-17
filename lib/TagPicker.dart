import 'package:flutter/material.dart';
import 'package:memorize/toast.dart';
import 'package:provider/provider.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/main.dart';
import 'package:memorize/ModeNormal.dart';

void showTagPicker(BuildContext context, Function(String tag) onResult) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      final cards = Provider.of<Cards>(context);
      final tags = extractHashTags(cards.cardScripts).toList();
      tags.add('__add_new__'); // 特別なアイテムを追加

      return Container(
        height: 300,
        child: Container(
          child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              if (tags[index] == '__add_new__') {
                return Container(
                  height: 50.0, // ListTileの高さを固定
                  child: ListTile(
                    title: Text('+ 新しいタグを追加'),
                    onTap: () {
                      editText(context, '#', (t){
                        onResult(t);
                        Navigator.pop(context);
                      });
                    },
                  ),
                );
              } else {
                return Container(
                  height: 50.0, // ListTileの高さを固定
                  child: ListTile(
                    title: Text(tags[index]),
                    onTap: () {
                      onResult(tags[index]);
                      Navigator.pop(context);
                    },
                  ),
                );
              }
            },
          ),
        ),
      );
    },
  );
}

final RegExp regExp = RegExp(r'#[^# \n]+');
final RegExp regExpx = RegExp(r'^#[^# \n]+$');

Set<String> extractHashTags(List<String> inputList) {
  // 結果を格納するSet
  final Set<String> result = {};
  final noMarkedTagReg = RegExp(r'#[^ #\n*]+');

  for (var line in inputList) {
    // 各行で正規表現にマッチするものをすべて探し出す
    final matches = noMarkedTagReg.allMatches(line);
    for (var match in matches) {
      result.add(match.group(0)!); // マッチした部分文字列をSetに追加
    }
  }

  return result;
}
