  import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

int findClosestCard(int card, List<int> deck) {
    if(deck.isEmpty) return -1;
    int closestPage = deck.first;
    int minDifference = (deck.first - card).abs();

    for (int deckCard in deck.reversed) {
      int difference = (deckCard - card).abs();
      if (difference < minDifference) {
        closestPage = deckCard;
        minDifference = difference;
      }
    }
    return closestPage;
  }

class Use extends HookWidget {
  final Widget Function(BuildContext context) buildFunction;

  const Use(this.buildFunction, {super.key});

  @override
  Widget build(BuildContext context) {
    return buildFunction(context);
  }
}

int clamp(int v, int min, int max){
  if(v > max) v = max;
  if(v < min) v = min;
  return v;
}

E atClamp<E>(Iterable<E> a, int i){
  if(i < 0) i = 0;
  if(i >= a.length) i = a.length - 1;
  return a.elementAt(i);
}