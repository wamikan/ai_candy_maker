#!/bin/bash

echo "Flutterのインストールを開始します..."
# Flutterの安定版（stable）をVercelのサーバー上に一時的にダウンロード
git clone https://github.com/flutter/flutter.git -b stable

# コマンドを使えるようにパスを通す
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutterのビルドを開始します..."
# 先ほど設定したAPIキーを含めてWebビルドを実行
flutter build web --dart-define=GEMINI_API_KEY=$AIzaSyCtssUsgKVrrDAcrByzos6wMfD8B0x0Mt8