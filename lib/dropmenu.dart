import 'package:flutter/material.dart';

class DropButton extends StatefulWidget {
  final List<DropItem> items;
  final ValueChanged<int?> onSelected;

  DropButton({required this.items, required this.onSelected});

  @override
  _DropButtonState createState() => _DropButtonState();
}

class _DropButtonState extends State<DropButton> {
  int? _selectedItem;

  @override
  void initState() {
    super.initState();
    // 初期選択を設定（必要に応じて変更）
    _selectedItem = widget.items.isNotEmpty ? widget.items.first.value : null;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _showPopupMenu(context);
      },
      child: Text(_selectedItem != null 
          ? widget.items.firstWhere((item) => item.value == _selectedItem).text 
          : 'Select an item'),
    );
  }

  void _showPopupMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      items: widget.items.map((item) {
        return PopupMenuItem<int>(
          value: item.value,
          child: Text(item.text),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedItem = value;
        });
        widget.onSelected(value);
      }
    });
  }
}

class DropItem {
  final int value;
  final String text;

  DropItem({required this.value, required this.text});
}
