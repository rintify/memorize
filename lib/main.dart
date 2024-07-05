import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeBlank.dart';
import 'package:memorize/ModeType.dart';
import 'package:memorize/card.dart';
import 'package:memorize/pagePicker.dart';
import 'package:memorize/toast.dart';
import 'package:memorize/util.dart';
import 'package:provider/provider.dart';
import 'package:memorize/data.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/main.dart';

import 'package:memorize/ModeNormal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final textsProvider = TextsProvider();
  await textsProvider.loadFromFile();

  runApp(
    ChangeNotifierProvider(
      create: (context) => textsProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainView(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
    );
  }
}

class MainView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final textsProvider = Provider.of<TextsProvider>(context, listen: false);
    final _pageController = usePageController();
    final _currentCard = useState<int>(0);
    final _bookmarkFilter = useState<bool>(false);
    final _deck = useState<List<int>>(
        List.generate(textsProvider.texts.length, (index) => index));

    updateDeck() {
      _deck.value = _bookmarkFilter.value
          ? textsProvider.filter()
          : List.generate(textsProvider.texts.length, (index) => index);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        int nextCard = findClosestCard(_currentCard.value, _deck.value);

        int pageIndex = _deck.value.indexOf(nextCard);
        if (pageIndex != -1) {
          _pageController.jumpToPage(pageIndex);
        }
      });
    }

    useEffect(updateDeck, [
      _bookmarkFilter.value,
    ]);

    useEffect(() {
      textsProvider.addListener(updateDeck);
      return () => textsProvider.removeListener(updateDeck);
    }, []);

    final mode = useState(0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0x00ffffff),
        surfaceTintColor: Color(0),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.sync),
            onSelected: (value) {
              switch (value) {
                case 1:
                  confirmDialog(context, 'ダウンロードしますか？\nいままでのデータは上書きされます', () {
                    textsProvider.fetch().then((res) {
                      showToast(context, res ? '成功' : '失敗');
                    });
                  });

                  break;
                case 2:
                  textsProvider.send().then((res) {
                    showToast(context, res ? '成功' : '失敗');
                  });
                  break;
                case 3:
                  editText(context, textsProvider.toScripts(), (script) {
                    textsProvider.fromScripts(script);
                    textsProvider.saveToFile();
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("ダウンロード"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("アップロード"),
              ),
              PopupMenuItem(
                value: 3,
                child: Text("データ編集"),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              mode.value = (mode.value + 1) % 4;
            },
            icon: Icon([
              Icons.circle_outlined,
              Icons.question_mark,
              Icons.keyboard,
              Icons.segment
            ][mode.value]),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            color: _bookmarkFilter.value ? Colors.amber : null,
            onPressed: () {
              _bookmarkFilter.value = !_bookmarkFilter.value;
            },
          ),
          IconButton(
            icon: Icon(Icons.menu_book),
            onPressed: () =>
                showPagePicker(context, _currentCard.value, (nextCard) {
              if (!_deck.value.contains(nextCard)) {
                nextCard = findClosestCard(nextCard, _deck.value);
              }

              int pageIndex = _deck.value.indexOf(nextCard);
              if (pageIndex != -1) {
                _pageController.jumpToPage(pageIndex);
              }
            }),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        reverse: false,
        onPageChanged: (value) {
          if (value >= _deck.value.length || value < 0) {
            _pageController.jumpToPage(_deck.value.length);
            return;
          }
          _currentCard.value = _deck.value[value];
        },
        itemBuilder: (BuildContext context, int index) =>
            index >= _deck.value.length || index < 0
                ? Container()
                : CardView(_deck.value[index], mode.value),
      ),
    );
  }
}
