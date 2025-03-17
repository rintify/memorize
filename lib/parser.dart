
import 'package:memorize/util.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/petitparser.dart';
  import 'dart:math';

// 基本のSortStrategyクラス
abstract class SortStrategy {
  int getOrder(String script);
  void reset();
}

// シンプルなカウンタに基づく戦略
class CounterSortStrategy extends SortStrategy {
  int _counter = 0;

  @override
  int getOrder(String script) {
    return _counter++;
  }

  @override
  void reset() {
    _counter = 0;
  }
}

// ランダムシードに基づく戦略
class RandomSortStrategy extends SortStrategy {
  final int _seed;
  late Random _random;

  RandomSortStrategy(this._seed) {
    _random = Random(_seed);
  }

  @override
  int getOrder(String script) {
    return _random.nextInt(1000);
  }

  @override
  void reset() {
    _random = Random(_seed);
  }
}


class FilterQuery {
  late bool Function(String script) _filter;
  late SortStrategy _sort;
  late String _last;

  String get last => _last;

  FilterQuery(String script) {
    /*final a = CardEvaluator();
    try{
      final F = a.build().parse('ab').value;
    }
    catch(e){
      print(e);
    }*/


    final def = EvaluatorDefinition()..execute('(((A $script');
    _filter = def.filter;
    print(_filter('あいうえお'));
    _sort = def.sort;
    _last = def.last;
  }

  List<int> execute(String Function(int i) get, int count) {
    List<MapEntry<int, int>> res = [];
    _sort.reset();
    for (var i = 0; i < count; i++) {
      final str = get(i);
      if (!_filter(str)) continue;
      res.add(MapEntry(i, _sort.getOrder(str)));
    }

    res.sort((a, b) => a.value.compareTo(b.value));

    return res.map((a) => a.key).toList();
  }
}

class ExpressionDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(add).optional().end();
  Parser add() => ref0(mul) & (pattern(r'+\-').trim() & ref0(mul)).star();
  Parser mul() => ref0(varr).plus();
  Parser varr() => ref0(parens) | ref0(any) | ref0(shuffle) | ref0(str);
  Parser shuffle() => string('S').seq(ref0(() => digit().plus().flatten()));
  Parser parens() => char('(').trim() & ref0(add).optional() & char(')').trim().optional();
  Parser any() => string('A').trim();
  Parser str() => pattern(r'^ \n()+\-').plus().flatten().trim();
}

class EvaluatorDefinition extends ExpressionDefinition {

  Parser start() => super.start().map((values) => values ?? (arg) => false);

  Parser add() => super.add().map((values){
    var f = (arg) => values[0](arg);
    for(var i = 0; i < values[1].length; i ++){
      final F = f, G = values[1][i][1];
      f = values[1][i][0] == '-' ? 
        (arg) => F(arg) && !G(arg) :
        (arg) => F(arg) || G(arg);
    }
    return f;
  });

  Parser mul() => super.mul().map((values){
    var f = (arg) => values[0](arg);
    for(var i = 1; i < values.length; i ++){
      final F = f, G = values[i];
      f = (arg) => F(arg) && G(arg);
    }
    return f;
  });
  Parser parens() => super.parens().castList().pick(1).map((value) => value ?? (arg) => false);
  Parser any() => super.any().map((values) => (arg) => true);
  Parser str() => super.str().map((value){
    last = value;
    return (arg) => arg.contains(value);
  });
  Parser shuffle() => super.shuffle().map((value){
    int seed = parseInt(value[1]);
    sort = RandomSortStrategy(seed);
    return (arg) => true;
  });

  String last = '';
  bool Function(String) filter = (arg) => false;
  SortStrategy sort = CounterSortStrategy();

  execute(String input){
    try{
      final F = build().parse(input).value;
      filter = (arg) => F(arg) as bool;
    }
    catch(e){
      print(e);
    }
  }
}