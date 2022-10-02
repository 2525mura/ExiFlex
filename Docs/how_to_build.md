# How to build Exiflex
ExiFlex開発環境の構築方法を記載します。
ムウラの覚書も兼ねているため、読み飛ばしても大丈夫です。

## 開発環境
- Mac OS 12.5
- Xcode 14.0
- iOS 14
- Cocoa Pod

## ドキュメント表示方法
### Mark Down 形式ファイル (.md)
- VSCodeでのプレビュー
  - 右クリック→プレビュー

### Plant UML 形式ファイル (.puml)
- VSCodeでのプレビュー
  - PlantUMLプラグインをインストール
  - Alt+D

## 依存関係インストール
本アプリでは、依存関係の管理にCocoaPodsを使用しております。

### 導入方法
- Cocoa Podsのインストール
  - brew install cocoapods
- podインストール
  - Exiflexのルートフォルダへ移動
    - e.g. `$ cd ./Documents/Xcode/Exiflex`
  - 依存ライブラリインストール(新規)
    - $ pod install
  - 依存ライブラリインストール(更新)
    - $ pod update
### pod installに失敗する場合
以下のようにRubyのパーミッションエラーが出る場合は、cocoapodsがSystemのプリインストールRubyを使おうとしており、権限不足が発生している。以下を参考に開発用のRuby環境を構成する。
```
% pod install

shell-init: error retrieving current directory: getcwd: cannot access parent directories: Operation not permitted
chdir: error retrieving current directory: getcwd: cannot access parent directories: Operation not permitted
/Applications/CocoaPods.app/Contents/Resources/bundle/lib/ruby/gems/2.2.0/gems/cocoapods-1.5.2/lib/cocoapods/executable.rb:93:in `expand_path': Operation not permitted - getcwd (Errno::EPERM)
	from /Applications/CocoaPods.app/Contents/Resources/bundle/lib/ruby/gems/2.2.0/gems/cocoapods-1.5.2/lib/cocoapods/executable.rb:93:in `block in which'
```

- rbenv, ruby-buildインストール
  - $ brew install rbenv ruby-build
- rubyインストール状態確認
  - $ rbenv versions<br>* system
- Rubyバージョンを確認して最新版をインストール
  - $ rbenv install -l<br>2.6.10<br>...<br>3.1.2
  - $ rbenv install 3.1.2
- デフォルトRubyを切り替え
  - $ rbenv versions<br>* system<br>3.1.2
  - $ rbenv global 3.1.2
  - $ rbenv versions<br>system<br>* 3.1.2
- rbenvにパスを通すためのスクリプトを.zshrcに追加
```.zshrc
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"
```

- pod installを再実行する

以下のように、CocoaPodsがシステムのRubyを参照している場合は、cocoapodsを再インストールする
```
### Stack
   CocoaPods : 1.5.2
        Ruby : ruby 2.2.6p396 (2016-11-15 revision 56800) [x86_64-darwin15]
    RubyGems : 2.6.8
        Host : macOS 12.5 (21G72)
       Xcode :  ()
         Git : git version 2.6.2
Ruby lib dir : /Applications/CocoaPods.app/Contents/Resources/bundle/lib
Repositories : 
```

- Cocoa Podsの再インストール
  - brew uninstall cocoapods
  - brew install cocoapods


