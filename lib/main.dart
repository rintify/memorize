import 'package:flutter/material.dart' hide Card;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memorize/ModeBlank.dart';
import 'package:memorize/ModeSegment.dart';
import 'package:memorize/ModeSegmentBlank.dart';
import 'package:memorize/ModeTest.dart';
import 'package:memorize/Search.dart';
import 'package:memorize/card.dart';
import 'package:memorize/dropmenu.dart';
import 'package:memorize/pagePicker.dart';
import 'package:memorize/toast.dart';
import 'package:memorize/util.dart';
import 'package:provider/provider.dart';
import 'package:memorize/Cards.dart';
import 'package:memorize/editText.dart';
import 'package:memorize/ModeNormal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cards = Cards();
  await cards.load();

  runApp(
    ChangeNotifierProvider(
      create: (context) => cards,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: MainView())),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
    );
  }
}

class MainView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    print('main');
    final cards = Provider.of<Cards>(context);
    final pageController = usePageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isInteger(pageController.page)) return;
      if (cards.deck.indexOf(cards.current) == pageController.page) return;
      int pageIndex = cards.deck.indexOf(findClosestCard(cards.current, cards.deck));
      if (pageIndex != -1) {
        pageController.jumpToPage(pageIndex);
      }
    });

    final mode = useState(0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // AppBarの高さを設定
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          color: Colors.white,
          child: Row(
            children: [
              SearchTextField(onSearch: (a){
                cards.setFilter(a);
              }),
              DropButton(
                items: [
                  DropItem(
                    value: 0,
                    text: '閲覧',
                  ),
                  DropItem(
                    value: 1,
                    text: '穴埋め',
                  ),
                  DropItem(
                    value: 2,
                    text: '暗唱',
                  ),
                  DropItem(
                    value: 3,
                    text: '模試',
                  ),
                  DropItem(
                    value: 4,
                    text: '節埋め',
                  ),
                ],
                onSelected: (newValue) {
                  mode.value = newValue ?? 0;
                },
              ),
              PopupMenuButton<int>(
                icon: const Icon(Icons.cloud_queue),
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      confirmDialog(context, 'ダウンロードしますか？\nいままでのデータは上書きされます', () {
                        cards.download().then((res) {
                          showToast(context, res ? '成功' : '失敗');
                        });
                      });
                      break;
                    case 2:
                      cards.upload().then((res) {
                        showToast(context, res ? '成功' : '失敗');
                      });
                      break;
                    case 3:
                      editText(context, cards.getScripts(), (script) {
                        cards.setScripts(script);
                        cards.save();
                      });
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text("ダウンロード"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("アップロード"),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: Text("データ編集"),
                  )
                ],
              ),
              IconButton(
                icon: const Icon(Icons.menu_book),
                onPressed: () => showPagePicker(context, cards.current, (index) {
                  cards.setCurrent(cards.deck[index]);
                }),
              ),
            ],
          ),
        ),
      ),
      body: PageView.builder(
          controller: pageController,
          scrollDirection: Axis.vertical,
          reverse: false,
          onPageChanged: (index) {
            if (index >= cards.deck.length || index < 0) return;
            cards.setCurrent(cards.deck[index], false);
          },
          itemBuilder: (BuildContext context, int index) {
            if(index >= cards.deck.length){
              return Center(child: TextButton(child: const Text('はじめに戻る'),onPressed: (){
                cards.updateDeck();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageController.jumpToPage(0);
                });
              },));
            }
            if (index < 0) return Container();
            final card = cards.getCard(cards.deck[index]);
            if (card == null) return Container();

            return ChangeNotifierProvider.value(
              value: cards.getCard(cards.deck[index])!,
              child: mode.value == 0 ? NormalModeView()
                  : mode.value == 1 ? BlankModeView()
                  : mode.value == 2 ? SegmentModeView()
                  : mode.value == 3 ? TestModeView() 
                  : mode.value == 4 ? SegmentBlankModeView()
                  : NormalModeView(),
                    
            );
          }),
    );
  }
}
