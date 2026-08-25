# Portable Dev Env Installer

ポータブル開発環境の自動セットアップバッチファイルです。Windows環境で、システムインストール不要の開発環境（VS Code、Git、Python環境、Node.js、Antigravity CLI）を一括で構築できます。

---

## 1. 簡単な説明

このバッチファイルは、以下のツールを自動的にダウンロード・展開し、統合されたポータブル開発環境を構築します：

- **VS Code** - コードエディタ（ポータブル版）
- **uv** - 高速なPythonパッケージマネージャー
- **Git** - バージョン管理システム（ポータブル版）
- **Node.js** - JavaScript実行環境
- **Antigravity CLI** - `antigravity-cli`パッケージ（旧Gemini CLIの後継ツール。コマンド名は `agy`）
- **7-Zip** - アーカイブ解凍ツール（内部使用）

すべてのツールは実行フォルダ内に展開され、システムには影響を与えません。USBメモリやネットワークドライブでも動作します。

---

## 2. 使い方

### 基本的な手順

1. **バッチファイルの実行**

```

portable_dev_env.bat

```
- 右クリック → 「管理者として実行」は**不要**です
- 初回実行時は全ツールのダウンロード・展開が行われます（数分かかります）

2. **インストール完了後**
- 同じフォルダに `Start-DevEnv.bat` と `Menu.ps1` が生成されます
- `Start-DevEnv.bat` をダブルクリックして起動します

3. **GUIメニューの操作**
- **API Key** 欄に、Google AI StudioのAPIキーを入力
- `[Get API Key]` ボタンで取得ページを開けます
- `VS Code` ボタン：VS Codeを起動
- `Terminal (agy)` ボタン：コマンドプロンプトを開く

4. **Antigravity CLI (`agy`) の使用**
- ターミナルで以下のコマンドが使用可能：
```cmd
agy --help

```

* **単発のプロンプト送信:** `-p` または `--print` オプションを使用します。

```cmd
agy -p "こんにちは、API通信のテストです。"

```

* **対話モードの起動:** `-i` オプションを使用します。

```cmd
agy -i

```

### フォルダ構成

```
portable_dev_env.bat      （このファイル）
│
├── Start-DevEnv.bat      （起動用バッチ：GUIメニューを開く）
├── Menu.ps1              （GUIメニュー本体）
├── gemini_key.txt        （APIキー保存先）
│
├── VSCode\               （VS Codeポータブル版）
├── Git\                  （Git for Windows Portable）
├── uv\                   （uvバイナリ）
├── NodeJS\               （Node.js実行環境）
├── AntigravityCLI\       （Antigravity CLI + npm packages）
│   ├── agy.cmd           （ラッパースクリプト）
│   └── node_modules\     （antigravity-cli本体）
├── home\                 （仮想HOMEディレクトリ）
│   ├── desktop\          （生成されるデスクトップフォルダ）
│   └── .ssh\             （SSH鍵の保存先）
└── temp\                 （一時ファイル）

```

---

## 3. 詳細な解説

### スクリプトの動作フロー

#### 3.1. 初期化処理

* **ハイブリッド形式**：1つのファイルで「バッチ」と「PowerShell」を両立
* 先頭のバッチ部分がPowerShellコードを呼び出します
* TLS 1.2を有効化し、セキュアなHTTPS通信を保証



#### 3.2. ツールのダウンロード＆展開

| ツール | ダウンロード元 | 展開先 | 備考 |
| --- | --- | --- | --- |
| **7-Zip** | [公式サイト](https://www.7-zip.org/) | `temp\7z_full\` | `.7z`形式の解凍用 |
| **VS Code** | [Microsoft公式](https://code.visualstudio.com/) | `VSCode\` | Zip版をダウンロード |
| **uv** | [GitHub Releases](https://github.com/astral-sh/uv/releases) | `uv\` | 最新版を自動取得 |
| **Git** | [GitHub Releases](https://github.com/git-for-windows/git/releases) | `Git\` | PortableGit版 |
| **Node.js** | [公式サイト](https://nodejs.org/) | `NodeJS\` | v22.12.0（Full版） |
| **Antigravity CLI** | npm経由 | `AntigravityCLI\` | `npm install antigravity-cli` |

#### 3.3. 各ツールの詳細

##### 1. VS Code（ポータブルモード）

* `data\` フォルダを作成して拡張機能・設定を保存
* プロキシ設定を自動検出し `settings.json` に反映
* SSH拡張機能用のパスを自動設定

##### 2. uv（Python環境）

* Pythonプロジェクトの依存関係管理に使用
* `uv venv` でvirtualenvを高速作成可能

##### 3. Git（バージョン管理）

* SSH鍵を自動生成（`home\.ssh\id_rsa`）
* `curl.exe` がダウンロードに使用される場合あり

##### 4. Node.js + npm

* `AntigravityCLI\` 内に独立した環境を構築
* `.npmrc` でキャッシュ・プレフィックスを設定
* プロキシ環境にも対応

##### 5. Antigravity CLI

* **重要**：`antigravity-cli` パッケージを使用
* 旧Gemini CLI（`@google/gemini-cli`）の後継ツール
* npm経由でインストール


* `agy.cmd` ラッパーで `node_modules\.bin\agy.cmd` を呼び出し
* 旧仕様との互換性を確保するため、環境変数 `GEMINI_API_KEY`, `GOOGLE_API_KEY`, `ANTIGRAVITY_API_KEY` の3つにAPIキーを同時に自動設定します。

#### 3.4. GUIランチャーの生成

##### Menu.ps1（PowerShell GUI）

* **API Key管理**
* `gemini_key.txt` に保存
* 起動時に3種類の環境変数に自動設定して認証エラーを防止


* **プロキシ自動検出**
* Windowsのシステム設定から読み取り
* VS CodeとGitに自動反映


* **ボタン機能**
* `VS Code`：カレントディレクトリでVS Codeを起動
* `Terminal`：開発環境用コマンドプロンプトを開く



##### Start-DevEnv.bat

* 環境変数 `PATH` に全ツールを追加
* `HOME` と `USERPROFILE` を仮想化
* `Menu.ps1` を呼び出し

### トラブルシューティング

#### Q1. ダウンロードが失敗する

* **A1**：プロキシ環境の場合、初回はプロキシ設定前なので失敗する可能性があります
* 手動でプロキシを設定し、その後バッチファイルを再実行してください。
```powershell
$env:HTTP_PROXY = "[http://proxy.example.com:8080](http://proxy.example.com:8080)"
$env:HTTPS_PROXY = "[http://proxy.example.com:8080](http://proxy.example.com:8080)"

```





#### Q2. agyコマンドで「unexpected argument」エラーが出る

* **A2**：文字列を直接渡すことはできません。必ず `-p` オプションを付けて実行してください。
```cmd
agy -p "プロンプト文字列"

```



#### Q3. VS Codeでプロキシエラーが出る

* **A3**：`VSCode\data\user-data\User\settings.json` を手動編集
```json
{
  "http.proxy": "[http://proxy.example.com:8080](http://proxy.example.com:8080)"
}

```



#### Q4. SSHが使えない

* **A4**：鍵が生成されていない場合
```cmd
Git\usr\bin\ssh-keygen.exe -t rsa -b 2048 -f home\.ssh\id_rsa

```



### セキュリティ注意事項

1. **APIキーの取り扱い**
* `gemini_key.txt` は平文保存されます
* 環境を共有する場合は削除してください


2. **実行ポリシー**
* `-ExecutionPolicy Bypass` を使用
* 企業環境では管理者に確認してください



---

## ライセンス

このスクリプトはMITライセンスです。各ツールは個別のライセンスに従います。

## 関連リンク

* [Google AI Studio](https://aistudio.google.com/app/apikey)
* [Antigravity CLI 公式ドキュメント](https://antigravity.google/product/antigravity-cli)
* [uv Documentation](https://docs.astral.sh/uv/)
* [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable)

```

```
