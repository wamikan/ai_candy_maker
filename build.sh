#!/bin/bash

echo "Flutterのインストールを開始します..."
# Flutterの安定版（stable）をVercelのサーバー上に一時的にダウンロード
git clone https://github.com/flutter/flutter.git -b stable

# コマンドを使えるようにパスを通す
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutterのビルドを開始します..."
# APIキーはVercelの裏側（Node.js）で安全に読み込まれるため、
# Flutter側はシンプルなビルドコマンドだけでOKです！
flutter build web