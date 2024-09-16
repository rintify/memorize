import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/TagPicker.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/util.dart';
import 'package:provider/provider.dart';

class SearchTextField extends StatefulWidget {
  final Function(String) onSearch;

  SearchTextField({required this.onSearch});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  Timer? _debounce;
  FocusNode _focusNode = FocusNode();
  PersistentBottomSheetController? c;
  final Duration debounceDuration = const Duration(milliseconds: 800); // 500ミリ秒のデバウンス時間
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && c == null) {
        // フォーカスされたときにポップを表示
        c = showPicker(context);
      }
      if (!_focusNode.hasFocus && c != null) {
        // フォーカスが外れたらポップを閉じる
        c!.close();
        c = null;
      }
    });
  }

  void onChanged(value) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(debounceDuration, () {
        widget.onSearch(value); // コールバック関数を呼び出します。
      });
    }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '検索',
            prefixIcon: GestureDetector(
              onLongPress: () {
                widget.onSearch(_controller.text); 
              },
              onHorizontalDragEnd: (details) {
                if(details.globalPosition.dx > MediaQuery.of(context).size.width - 30){
                  _controller.text = '';
                  return;
                }
                int lastSpaceIndex = _controller.text.lastIndexOf(whiteSpace);
                _controller.text = lastSpaceIndex < 0 ? '' : _controller.text.substring(0, lastSpaceIndex);
                widget.onSearch(_controller.text); 
              },
              child: IconButton(onPressed: (){
                if(c != null){
                  c!.close();
                  c = null;
                  onChanged(_controller.text);
                }
                else c = showPicker(context);
              },
              icon: const Icon(Icons.search)),
            ),
            border: InputBorder.none,
          ),
          onChanged: onChanged
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  PersistentBottomSheetController showPicker(BuildContext context) {
    return showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final cards = Provider.of<Cards>(context);

        return SizedBox(
          height: 400,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity, // 画面いっぱいの横幅に設定
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        style: ExKeyButtonStyle,
                        child: const Icon(Icons.shuffle),
                        onPressed: () {
                          _controller.text = _controller.text.replaceFirstMapped(RegExp(r'S(\d+)$'), (m) => 'S${int.parse(m[1]!) + 1}') + 
                            (RegExp(r'S(\d+)$').hasMatch(_controller.text) ? '' : ' S0');
                          onChanged(_controller.text);
                        },
                      ),
                      TextButton(
                        style: ExKeyButtonStyle,
                        child: const Icon(Icons.backspace_outlined),
                        onPressed: () {
                          int lastSpaceIndex = _controller.text.lastIndexOf(whiteSpace);
                          _controller.text = lastSpaceIndex < 0 ? '' : _controller.text.substring(0, lastSpaceIndex);
                          onChanged(_controller.text);
                        },
                      ),
                      TextButton(
                        style: ExKeyButtonStyle,
                        child: Text('('),
                        onPressed: () {
                          _controller.text += ' (';
                          onChanged(_controller.text);
                        },
                      ),
                      TextButton(
                        style: ExKeyButtonStyle,
                        child: Text(')'),
                        onPressed: () {
                          _controller.text += ' )';
                          onChanged(_controller.text);
                        },
                      ),
                      TextButton(
                        style: ExKeyButtonStyle,
                        child: Text('+'),
                        onPressed: () {
                          _controller.text += ' +';
                          onChanged(_controller.text);
                        },
                      ),
                      TextButton(
                        style: ExKeyButtonStyle,
                        child: Text('-'),
                        onPressed: () {
                          _controller.text += ' -';
                          onChanged(_controller.text);
                        },
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...cards.filterHistory.reversed.map((f) => TextButton(
                          style: ExKeyButtonStyle,
                          child: Text(f),
                          onPressed: () {
                            _controller.text = f;
                            onChanged(_controller.text);
                          },
                        ),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TagWidget(onResult: (t){
                      _controller.text += ' $t';
                      onChanged(_controller.text);
                    }),
                  )
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}

