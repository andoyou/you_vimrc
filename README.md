# Portable Vim configuration

Linux・WSL・macOS向けのVim設定。Vim 8.2以上、Git、Python 3.8以上が必要です。
Neovimは対象外。Pythonは標準ライブラリのみを使い、Vim起動時には不要です。
このリポジトリと `plugins.lock.json` で設定とプラグインの版を再現します。

## インストール

リポジトリを任意の永続ディレクトリへコピーまたはcloneして実行します。
Git remoteは未設定です。別PCへの転送はGit bundleでも可能です。

```sh
python3 /path/to/vim-config/install.py
```

- GitHub HTTPSからdein・NERDTree・1989テーマの固定コミットを取得します。
- 既存の同じコミットがあれば再利用します。既存プラグインは削除しません。
- 通常のVim起動でネットワークアクセスや自動更新は行いません。
- 既存設定を `~/.vim/config-backups/<run-id>/` に保存してから配置します。
- 既定はsymlink方式。元リポジトリを移動・削除しないでください。
- `--mode copy` では設定をコピーするため、リポジトリを移動できます。
  変更反映にはインストーラーを再実行してください。
- 何度実行しても同一ファイルは置換せず、実行ごとのmanifestだけを残します。
- Vimを開き直して反映してください。開いているVimの状態は変更しません。

```sh
# コピー方式、任意ホーム、バックアップ先
python3 install.py --home /path/to/home --mode copy --backup-dir /path/to/backups

# オフライン導入。キャッシュ配下は owner/repository のGitリポジトリ構成
python3 install.py --offline --plugin-cache /path/to/dein/repos/github.com

# 配置だけを復元（実行時に表示されたmanifestを指定）
python3 install.py --restore /path/to/backups/RUN/manifest.json
```

復元は変更対象を事前検査し、導入後に編集されたファイルを上書きしません。
バックアップ・プラグイン取得物・空ディレクトリは復元後も保持します。
中断時もmanifestが残ります。再実行またはmanifestからの復元が可能です。
clone中断で不完全な `.installing` ディレクトリが残った場合は、表示された場所を
確認して退避してから再実行してください。自動削除はしません。
既存checkoutが固定版と違う場合や追跡ファイルに変更がある場合も停止します。
外部コマンド導入・OSパッケージ更新はこのスクリプトでは行いません。

## ファイル構成

- `vimrc`: 読み込み入口
- `vim/options.vim`: 表示・編集設定
- `vim/plugins.vim`: deinによるプラグイン読み込みとテーマのフォールバック
- `vim/filetypes.vim`: ファイル種別・インデント（再読込しても重複しない）
- `vim/mappings.vim`: キー割り当て
- `vim/clipboard.vim`: Vim用のクリップボード連携
- `vim/markdown.vim`: 保存済みMarkdownを既定ブラウザで開くコマンド
- `PRACTICE.md`: 日常的なVim操作とこの設定固有コマンドの早見表
- `dein.toml`: プラグイン定義
- `plugins.lock.json`: dein本体を含む取得先と固定コミット
- `install.py`, `lib/`: 導入・依存検査・バックアップ・復元
- `tests/`: 隔離ホームでの検証

配置先は `~/.vimrc`、`~/.vim/config/`、`~/.vim/dein.toml`。
プラグインは `~/.vim/dein/` に置き、XDG環境変数によって保存先を変えません。
環境固有の調整はGit管理外の `~/.vim/local.vim` に記述します。
プラグインキャッシュ・履歴・バックアップ・認証情報はGit管理しません。

## 既存設定からの変更

- 現在導入済みのNERDTree・1989テーマを維持し、使用コミットを固定しました。
- 未導入のlightline/syntastic/choosewin/Unite等の設定は除去しました。
  必要ならプラグイン定義と設定をセットで追加してください。
- `sw`: 保存を維持。ウィンドウ移動との重複を解消しました。
- `-`: ウィンドウを順番に移動。未導入choosewinへの参照を置換しました。
- `sT`: タブ一覧と番号入力、`sb`: バッファ一覧と番号入力、`sB`: 全バッファ一覧と番号入力。
  Unite固有の絞り込み・タブ内限定一覧ではありません。
- Ctrl-Cの未定義関数呼出しを除去し、Vim本来の動作へ戻しました。
  大小文字変換には標準の `~` / `g~` を使えます。
- `.js` のインデントは既存javascript設定と同じ2桁に統一しました。
- Neovim用g:clipboardは使わず、VimのTextYankPostでヤンク後にOSクリップボードへ同期します。
- `nobackup` / `noswapfile` / `noundofile` は既存方針を維持しています。
- truecolorはGUI、COLORTERM=truecolor/24bit、TERMのdirect指定時に有効です。
  端末が対応するのに検出できない場合はlocal.vimに `set termguicolors` を追加できます。

## クリップボード

通常・行単位・名前付きレジスタへのヤンクは、Vimネイティブのクリップボード機能または検出した外部ツールを通じてOSクリップボードへ同期されます。Vimネイティブのクリップボード機能が利用できる環境ではunnamedplusも有効にします。
明示的な補助手段として次のコマンドも用意しています。

- `:[range]ClipboardCopy`: 指定行（省略時は現在行）をコピー。選択行にも使用可能。
- `:ClipboardPaste`: 現在行の下に貼り付け。CRLFをLFへ正規化。

`:ClipboardCopy` は行単位の操作です。通常の文字単位 `p` / `P` を差し替えません。
利用可能な外部ツールはwin32yank(.exe)、macOSのpbcopy/pbpaste、
Waylandのwl-copy/wl-paste、X11のxclipです。WSLでwin32yankがなければ
端末側のコピー・貼り付けを使うか、別途その導入を行ってください。
SSH越しのクリップボードやGUIの接続成否は端末・接続先に依存します。
外部ツールもVimネイティブのクリップボード機能もない環境では編集自体は可能ですが、最初のヤンク時に一度だけ警告を出します。

## Markdownを既定ブラウザで開く

保存済みのMarkdownバッファで `:MarkdownOpen` を実行すると、既定ブラウザ（またはOS既定ハンドラ）でファイルを開きます。未保存の内容は開かないため、先に `:w` してください。Linuxは`xdg-open`、macOSは`open`、WSLは`wslview`またはPowerShell、WindowsはPowerShellを使用します。ブラウザがMarkdownをHTMLとして描画するか、生テキストとして表示するかはブラウザ・OSの関連付けに依存します。

## Markdownのリアルタイムプレビュー

`previm/previm`を導入済みです。Markdownバッファで `:PrevimOpen` を実行すると、ローカルHTMLへ変換したプレビューを既定ブラウザで開きます。保存すると `:PrevimRefresh` 相当の更新が行われ、編集しながら確認できます。ブラウザ起動は `tyru/open-browser.vim` が担当します。

同梱アセットを使うため、通常の起動・プレビューでネットワークアクセスは発生しません。`:PrevimUpdateAssets` は外部CDNからアセットを取得する任意コマンドなので、この設定では実行しないでください。

日常操作とコマンド一覧は [PRACTICE.md](PRACTICE.md) を参照してください。

## 更新・再現

設定変更はこのリポジトリで行ってコミットします。
導入先のsymlink方式では次のVim起動から反映、copy方式では再導入が必要です。
プラグイン更新は意図的に行い、lockのコミットとdein.tomlのrevを同時に更新します。
新しい固定版のプラグインは別ディレクトリに入るため旧版は保持されます。
dein本体の既存版が異なる場合は停止するため、変更を確認して退避・再導入します。
`:call dein#update()` による独立した更新は再現性を崩すので使用しません。

```sh
# 任意の場所にGit履歴ごと転送（remote公開不要）
git bundle create /path/to/vim-config.bundle --all
# 別PCで
git clone /path/to/vim-config.bundle /path/to/vim-config
python3 /path/to/vim-config/install.py
```

## 検証

```sh
python3 tests/run.py --work-dir /path/to/new-test-dir \
  --plugin-cache /path/to/dein/repos/github.com
```

指定先に隔離ホームとログを残します。検証先は新規ディレクトリを指定してください。
symlink/copy導入、再実行、Vim起動、再読込、キー設定、NERDTree、ファイル種別、
復元と変更保護、依存未導入時起動、偽クリップボードでのコピー/改行補正を検証します。
実施環境はLinux/WSLのVim 8.2。macOS実機と実際のOSクリップボードは未検証です。
