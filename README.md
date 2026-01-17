# memorize

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Webアプリとしてのビルド手順

このプロジェクトをWebアプリとしてビルドし、公開用ファイル（HTML/JS/CSSなど）を生成する手順は以下の通りです。

### 1. ビルドコマンドの実行
ターミナルで以下のコマンドを実行してください。

```bash
flutter build web --release
```

※ `--release` フラグを付けることで最適化されたファイルが出力されます。

#### サブディレクトリ（例: `/memorize/`）に公開する場合
GitHub Pagesなどで `/memorize/` 以下に公開する場合は、以下のコマンドでビルドしてください。

```bash
flutter build web --release --base-href "/memorize/"
```

または、ビルド後に生成された `index.html` 内の `<base href="/">` を `<base href="/memorize/">` に手動で書き換えてください。


### 2. 出力先の確認
ビルドが成功すると、以下のディレクトリにすべての静的ファイルが生成されます。

`build/web/`

このフォルダの中身をそのまま Webサーバー（GitHub Pages, Firebase Hosting, Vercel など）にアップロードすれば公開可能です。

### 3. ローカルでの動作確認
ビルド後の動作をローカルで確認したい場合は、簡易サーバーを使用します。

```bash
cd build/web
# Python 3系の場合
python3 -m http.server 8000
```

その後、ブラウザで [http://localhost:8000](http://localhost:8000) にアクセスしてください。
