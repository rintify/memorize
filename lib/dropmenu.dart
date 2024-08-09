import 'package:flutter/material.dart';

class DropButton extends StatefulWidget {
  final List<DropItem> items;
  final ValueChanged<int?> onSelected;
  final int selectedItem;

  DropButton({required this.items, required this.onSelected, required this.selectedItem});

  @override
  _DropButtonState createState() => _DropButtonState();
}

class _DropButtonState extends State<DropButton> {

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _showPopupMenu(context);
      },
      child: Text(
          widget.items.firstWhere((item) => item.value == widget.selectedItem).text ),
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
