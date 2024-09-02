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
      tags.sort();
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
                      editText(context, '#', (t) {
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
                    onLongPress: () {
                      showTagEditorMenu(context, tags[index]);
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

void showTagEditorMenu(BuildContext context, String tag) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final cards = Provider.of<Cards>(context);
      bool _isSwitched = false; // 初期状態をfalseに設定

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(tag),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('一時無効解除'),
                  onTap: () {
                    cards.editDeckScript(applyAll: _isSwitched, (script){
                      return script.replaceAll(markTag(tag), tag);
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('名称変更'),
                  onTap: () {
                    editText(context, tag, (text){
                      if(!isTag(text)){
                        Navigator.of(context).pop();
                        return;
                      }
                      cards.editDeckScript(applyAll: _isSwitched, (script){
                        final tagname = tag.substring(1), newTagname = text.substring(1);
                        return script.replaceAllMapped(RegExp('#\\*?$tagname'), (match) {
                          return match[0]!.startsWith('#*') ? '#*$newTagname' : '#$newTagname';
                        });
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                ListTile(
                  title: Text('複製'),
                  onTap: () {
                    cards.editDeckScript(applyAll: _isSwitched, (script){
                      final tagname = tag.substring(1), copyTagname = 'コピー$tagname';
                      script = script.replaceAllMapped(RegExp('#\\*?$tagname'), (match) {
                        return match[0]!.startsWith('#*') ? '#*$copyTagname' : '#$copyTagname';
                      });
                      return script.replaceAll(tag, '$copyTagname $tag');
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('削除'),
                  onTap: () {
                    confirmDialog(context, '本当に $tag を削除しますか？', () {
                      cards.editDeckScript(applyAll: _isSwitched, (script){
                        final tagname = tag.substring(1);
                        return script.replaceAll(RegExp('#\\*?$tagname ?'), '');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Row(
  children: [
    Transform.scale(
      scale: 0.8, // スイッチのサイズを縮小します。適切な値に調整してください。
      child: Switch(
        value: _isSwitched,
        onChanged: (value) {
          setState(() {
            _isSwitched = value; // 状態を更新
          });
        },
      ),
    ),
    SizedBox(width: 8), // SwitchとTextの間にスペースを追加（必要に応じて調整）
    Text(
      'すべてに適用',
    ),
  ],
)

              ],
            ),
          );
        },
      );
    },
  ).then((value) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選択されたオプション: $value')),
      );
    }
  });
}

