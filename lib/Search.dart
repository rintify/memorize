import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memorize/TagPicker.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/util.dart';

class SearchTextField extends StatefulWidget {
  final Function(String) onSearch;

  SearchTextField({required this.onSearch});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  Timer? _debounce;
  final Duration debounceDuration = const Duration(milliseconds: 800); // 500ミリ秒のデバウンス時間
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: TextField(
          controller: _controller,
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
                showTagPicker(context, (t){
                  _controller.text += ' $t';
                  _debounce?.cancel();
                  widget.onSearch(_controller.text); 
                });
              },
              icon: const Icon(Icons.search)),
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(debounceDuration, () {
              widget.onSearch(value); // コールバック関数を呼び出します。
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
