

import 'package:flutter/material.dart';
import 'package:memorize/data.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/main.dart';
import 'package:memorize/ModeNormal.dart';

void editText(BuildContext context, String text, Function(String text) onResult) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EditTextDialog(
        initialText: text,
        onResult: onResult,
      );
    },
  );
}

class EditTextDialog extends StatefulWidget {
  final String initialText;
  final Function(String text) onResult;

  EditTextDialog({required this.initialText, required this.onResult});

  @override
  _EditTextDialogState createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<EditTextDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertKakko(String start, String end) {
    setState(() {
      final cursorPos = _controller.selection.baseOffset;
      if(cursorPos < 0) return;
      final startPos = findClosestGreaterThan(start, _controller.text, cursorPos);
      final endPos = findClosestGreaterThan(end, _controller.text, cursorPos);
      _controller.text = _controller.text.substring(0, cursorPos) + (startPos <= endPos ? start : end) + _controller.text.substring(cursorPos);
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPos + 1),
      );
      _focusNode.requestFocus(); // テキストフィールドにフォーカスを戻す
    });
  }

  int findClosestGreaterThan(String c ,String text, int cursorPosition) {
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (c == text[i]) {
        return i;
      }
    }
    return -1;
  }

  final style = TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0), // 余白を指定
    minimumSize: Size(0, 0), // 最小サイズを指定（必要に応じて調整）
    tapTargetSize: MaterialTapTargetSize.padded, // タップ領域を小さくする
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('テキストを編集'),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        decoration: InputDecoration(hintText: 'テキストを入力してください'),
      ),
      actions: [
        TextButton(
          style: style,
          child: Text('/'),
          onPressed: () {
            _insertKakko('/','/');
          },
        ),
        TextButton(
          style: style,
          child: Text('{}'),
          onPressed: () {
            _insertKakko('{','}');
          },
        ),
        TextButton(
          style: style,
          child: Text('<>'),
          onPressed: () {
            _insertKakko('<','>');
          },
        ),
        TextButton(
          style: style,
          onPressed: () {
            widget.onResult(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text('完了'),
        ),
      ],
    );
  }
}
