import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/util.dart';

class SegmentModeView extends HookWidget {
  final String text;
  final ObjectRef<void Function()> onReset;

  SegmentModeView(this.text, this.onReset);

  @override
  Widget build(BuildContext context) {
    final segment = useState<int>(0);

    onReset.value = () {
      segment.value = 0;
    };

    final cs = useMemoized(() {
      return translateText(text);
    }, [text]);

    return GestureDetector(
      onTap: () {
        segment.value++;
      },
      onLongPress: (){
        segment.value = 0;
      },
      child: Container(
        color: Color(0),
        alignment: Alignment.center,
        child: CharsView(
          cs,
          (c) => 
             c.segment >= segment.value
              ? Text(' ', style: qstyle)
              : noqchar(c),
        ),
      ),
    );
  }
}
