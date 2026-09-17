# Vim practice / command quick reference

この設定で日常的に使う操作の早見表です。`<Esc>`でノーマルモードに戻ってから入力します。より詳しい説明は各節末尾の公式 Vim help を参照してください。

## この設定固有のコマンド

| 操作 | 内容 |
| --- | --- |
| `:MarkdownOpen` | 保存済みの Markdown をOS既定ブラウザ/ハンドラで開く。未保存なら `:w` 後に実行。 |
| `:Open %` | Vim 9.2以上の標準コマンド。現在のファイルをOS既定ハンドラで開く。Markdown以外にも使える。 |
| `:ClipboardCopy` | 現在行をOSクリップボードへコピー。`:'<,'>ClipboardCopy`なら選択行。 |
| `:ClipboardPaste` | OSクリップボードを現在行の下へ貼り付け。 |
| `sw` | 保存（`:w`）。 |
| `sj` `sk` `sh` `sl` | 下・上・左・右のウィンドウへ移動。 |
| `-` | 次のウィンドウへ移動。 |
| `ss` / `sv` | 横分割 / 縦分割。 |
| `sQ` | 現在のバッファを閉じる。 |
| `sb` / `sB` | バッファ一覧を出し、番号を入力して移動。 |
| `sT` | タブ一覧を出し、番号を入力して移動。 |

## 移動・編集

| 操作 | 内容 |
| --- | --- |
| `h` `j` `k` `l` | 左・下・上・右へ移動。 |
| `w` / `b` | 次 / 前の単語の先頭へ移動。 |
| `0` / `$` | 行頭 / 行末へ移動。 |
| `gg` / `G` | 先頭行 / 最終行へ移動。`42G`なら42行目。 |
| `i` `a` `o` `O` | 挿入開始（カーソル前 / 後 / 次行 / 前行）。 |
| `x` / `dd` | 1文字削除 / 行削除。 |
| `yy` / `p` | 行ヤンク / カーソル後へ貼り付け。ヤンクはOSクリップボードにも同期。 |
| `u` / `Ctrl-r` / `.` | 元に戻す / やり直す / 直前の変更を繰り返す。 |
| `v` / `V` / `Ctrl-v` | 文字 / 行 / 矩形の選択。選択後に `y`、`d`、`c`、`>`、`<`、`=`。 |

公式: [Vim quick reference](https://vimhelp.org/quickref.txt.html)、[移動](https://vimhelp.org/usr_03.txt.html)、[編集](https://vimhelp.org/usr_04.txt.html)、[Visual mode](https://vimhelp.org/visual.txt.html)

## 検索・置換

| 操作 | 内容 |
| --- | --- |
| `/語句` / `?語句` | 前方 / 後方へ検索。`Enter`で確定。 |
| `n` / `N` | 同じ方向 / 逆方向の次の一致へ。 |
| `:%s/古い/新しい/gc` | ファイル全体を置換し、各候補で確認。`g`は行内すべて、`c`は確認。 |
| `:nohlsearch` | 検索の強調表示を消す。 |

公式: [検索](https://vimhelp.org/usr_03.txt.html#03.9)、[置換](https://vimhelp.org/usr_04.txt.html#04.4)

## ファイル・バッファ・ウィンドウ

| 操作 | 内容 |
| --- | --- |
| `:e path` | ファイルを開く。`Tab`でパス補完。 |
| `:w` / `:wq` / `:q` / `:q!` | 保存 / 保存して終了 / 終了 / 変更を破棄して終了。 |
| `:ls` / `:buffer 番号` | バッファ一覧 / 指定バッファへ移動。 |
| `:bnext` / `:bprevious` / `:bdelete` | 次 / 前のバッファ / 現在バッファを閉じる。 |
| `Ctrl-w s` / `Ctrl-w v` / `Ctrl-w q` / `Ctrl-w o` | 横分割 / 縦分割 / ウィンドウを閉じる / 他のウィンドウを閉じる。 |
| `:tabnew` / `gt` / `gT` | 新規タブ / 次 / 前のタブ。 |

公式: [ファイル編集](https://vimhelp.org/usr_07.txt.html)、[複数ウィンドウ](https://vimhelp.org/usr_08.txt.html)、[タブ](https://vimhelp.org/usr_08.txt.html#08.7)

## コマンドラインとヘルプ

| 操作 | 内容 |
| --- | --- |
| `:` | Exコマンドを入力。`Tab`で補完、`q:`で履歴ウィンドウ。 |
| `:help キーワード` | 組み込みヘルプを開く。例: `:help :substitute`、`:help CTRL-W`。 |
| `Ctrl-]` / `Ctrl-o` | ヘルプのタグ先へ移動 / 前の位置へ戻る。 |
| `:!コマンド` | 外部コマンドを実行。ファイル名を渡す場合は必ず適切にエスケープする。 |

公式: [ヘルプ](https://vimhelp.org/help.txt.html)、[Exコマンド](https://vimhelp.org/cmdline.txt.html)、[外部コマンド](https://vimhelp.org/usr_21.txt.html)

Vim 9.2以上の標準 `:Open` / `:Launch` の説明は [公式 `:Open` help](https://vimhelp.org/eval.txt.html#%3AOpen) を参照してください。

## 練習の入口

ターミナルから `vimtutor` を実行すると、Vimに同梱された対話形式のチュートリアルを始められます。公式案内は [Vim tutor](https://vimhelp.org/usr_01.txt.html#tutor) です。
