
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeNormal.dart';
import 'package:memorize/util.dart';


Widget BlankModeView(String text, ObjectRef<void Function()> onReset){
  return Use((context){
    print('a');
    final questions = useState<List<int>>([]);
    onReset.value = (){
      questions.value = [];
    };

    final cs = useMemoized((){
      return translateText(text);
    },[text]);
    
    return GestureDetector(
      onTap: (){
        final max = questions.value.isEmpty ? 0 : questions.value.reduce((curr, next) => curr > next ? curr : next);
        questions.value.add(max+1);
        questions.value = [...questions.value];
      },
      child: Container(
        color: Color(0),
        alignment: Alignment.center,
        child: CharsView(
          cs,
          (c) => c.q != null
              ? GestureDetector(
                  onTap: () {
                    if (!questions.value.contains(c.q)) {
                      questions.value.add(c.q!);
                      questions.value = [...questions.value];
                    } else {
                      questions.value.remove(c.q!);
                      questions.value = [...questions.value];
                      
                    }
                  },
                  child: questions.value.contains(c.q)
                      ? noqchar(c)
                      : Text('？', style: qstyle),
                )
              : noqchar(c)),
      ),
    );
  });
}
