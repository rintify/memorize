import 'package:flutter/material.dart';

class UsageGuideView extends StatelessWidget {
  final String text;

  const UsageGuideView({Key? key, required this.text}) : super(key: key);

  static const String DEFAULT_HELP_TEXT = """
# アプリの使い方

## 基本操作
このアプリは、問題と答えが書かれたカードをスワイプして暗記する学習ツールです。

- **下にスワイプ** → 次のカードへ進む
- **上にスワイプ** → 前のカードに戻る

---

## 👆 ジェスチャーとタグ操作

テキスト（節）には「#タグ」をつけて学習状況を管理できます。右下に表示されているのが**現在選択中のタグ**です。

### テキストへの操作
- **長押し** (どの文字でも)
  - 選択中のタグを**追加**します。
- **タップ** (色付きの文字)
  - タグの状態を切り替えます（トグル動作）。
  1. 🟡 **黄色 (学習中)**：タグが有効な状態
  2. 🔵 **青色 (一時無効)**：タグはあるが、一時的に除外している状態
  3. ⚪️ **（削除）**：タグを削除

### タグの管理（右下のボタン）
右下のタグ表示エリア（例: `#ALL`）を操作します。

- **タップ**
  - 使用するタグ（フィルター）を切り替えます。
- **長押し / 横スワイプ**
  - **タグ編集メニュー**を開きます。
    - **名称変更**：タグの名前を変更
    - **複製**：タグをコピーして新しいタグを作成
    - **一括付与**：表示中のカード全体にこのタグを追加
    - **削除**：このタグをすべて削除

---

## モード別の詳細

### 🔍 閲覧モード (Browsing)
- 問題と答えをそのまま閲覧します。
- **長押し**等の操作でタグ付けを行い、学習の準備をするのに適しています。

### 📝 穴埋めモード (Fill-in-Blank)
- 文章の一部（`<>`で囲った部分）が空欄になります。
- **タップ** → 答えを表示
- **右スワイプ** → 1つ戻る
- **左スワイプ** → 1つ先へ

### ✍️ 節（セグメント）モード
- 文章が節（`/`で区切った部分）ごとに分かれます。
- **タップ (無色部分)** → 次の節へ移動
- **タップ (色付き部分)** → タグの切り替え
- **左右スワイプ** → 節の移動

---

## アイコンの説明

### 📖 本のアイコン
カードのリストを表示します。

### ☁️ 雲のアイコン（データ管理）
- **ダウンロード**：クラウドからデータを取得（上書き注意）
- **アップロード**：現在のデータをクラウドへ保存
- **データ編集**：テキストデータとして直接編集

### 🔍 検索バー
- **スペース区切り** → AND検索
- **`+` 区切り** → OR検索
- **`-` (先頭)** → NOT検索
- **`S0`, `S1`...** → シャッフル表示（数字はシード値）

---

## 文法ルール（カードの書き方）

- **`###`** : カードの区切り
- **`##`** : 問題・答え・タグの区切り
- **`/`** : 節（セグメント）の区切り
- **`{ }`** : よみがな（例：漢字{かんじ}）
- **`< >`** : 穴埋め箇所（例：これは <重要> です）
""";

  @override
  Widget build(BuildContext context) {
    final sections = _parseHelpText(text.isEmpty ? DEFAULT_HELP_TEXT : text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('使い方ガイド',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[50],
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          return _buildSection(sections[index]);
        },
      ),
    );
  }

  Widget _buildSection(HelpSection section) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ...section.content.map((item) {
              if (item is SubSection) {
                return _buildSubSection(item);
              } else if (item is BulletPoint) {
                return _buildBulletPoint(item);
              } else if (item is PlainText) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _parseRichText(item.text, fontSize: 16),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(SubSection sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(2)),
                margin: const EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: Text(
                  sub.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...sub.content.map((item) {
            if (item is BulletPoint) {
              return _buildBulletPoint(item);
            } else if (item is PlainText) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 12),
                child: _parseRichText(item.text),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BulletPoint item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 6, color: Colors.blueGrey),
          ),
          Expanded(child: _parseRichText(item.text)),
        ],
      ),
    );
  }

  Widget _parseRichText(String text, {double fontSize = 15}) {
    List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in exp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style:
            TextStyle(fontSize: fontSize, color: Colors.black54, height: 1.5),
        children: spans,
      ),
    );
  }

  List<HelpSection> _parseHelpText(String text) {
    List<HelpSection> sections = [];
    List<String> lines = text.split('\n');
    HelpSection? currentSection;
    SubSection? currentSubSection;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty || line == '---') continue;

      if (line.startsWith('## ')) {
        // Start new section
        currentSection = HelpSection(line.substring(3).trim());
        sections.add(currentSection);
        currentSubSection = null; // Reset subsection
      } else if (line.startsWith('### ')) {
        // Start new subsection
        if (currentSection == null) {
          currentSection = HelpSection(""); // Fallback if no main section yet
          sections.add(currentSection);
        }
        currentSubSection = SubSection(line.substring(4).trim());
        currentSection.content.add(currentSubSection);
      } else if (line.startsWith('- ')) {
        // Bullet point
        final content = BulletPoint(line.substring(2).trim());
        if (currentSubSection != null) {
          currentSubSection.content.add(content);
        } else if (currentSection != null) {
          currentSection.content.add(content);
        } else {
          // If completely loose, ignore or add to a default section?
          // Ignoring for now or could create default
        }
      } else {
        // Plain text
        if (!line.startsWith('#')) {
          final content = PlainText(line);
          if (currentSubSection != null) {
            currentSubSection.content.add(content);
          } else if (currentSection != null) {
            currentSection.content.add(content);
          }
        }
      }
    }
    return sections;
  }
}

// Data structures for parsing
class HelpSection {
  String title;
  List<dynamic> content = [];
  HelpSection(this.title);
}

class SubSection {
  String title;
  List<dynamic> content = [];
  SubSection(this.title);
}

class BulletPoint {
  String text;
  BulletPoint(this.text);
}

class PlainText {
  String text;
  PlainText(this.text);
}
