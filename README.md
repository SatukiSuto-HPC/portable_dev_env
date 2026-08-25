
# Portable Dev Env Installer

Windows環境において、システムへのインストール（管理者権限）を一切必要とせず、ダブルクリック1つで**完全隔離されたモダンなAI・ソフトウェア開発環境**を自動構築するセットアップスクリプトです。

---

## 1. 本ツールの本質と最大の特徴

本ツールの本質は、**「PC本体の環境を一切汚染せず、どんな制限された環境下でも即座に最新の開発環境を展開できる」**ことにあります。企業や大学のPC、あるいは個人のUSBメモリなど、場所を選ばず同じ環境を再現できます。

### 💡 3つのコア機能

1. **プロキシ環境の自動突破（Auto-Proxy Config）**
   企業や学校などの厳しいネットワーク環境下でも、Windowsのシステムプロキシ設定（レジストリ）を自動検出し、**VS Code、npm、Gitなどの各ツールの設定ファイルへ透過的に自動適用**します。面倒な設定ファイルの手書きは不要です。

2. **完全なポータブル化（システム非汚染）**
   PCの環境変数（PATH）やレジストリを一切書き換えません。VS Codeの拡張機能から、npmのグローバルパッケージ、SSHの秘密鍵（`id_rsa`）に至るまで、すべてのデータはツールが展開されたフォルダ（仮想HOME）内に隔離されて保存されます。

3. **オールインワンのAI×開発環境**
   超高速Pythonパッケージマネージャー（`uv`）、JavaScript環境（`Node.js`）、バージョン管理（`Git`）、そしてGoogleの最新AIツール（`Antigravity CLI`）をシームレスに統合。ターミナルを開いた瞬間から、全ツールのコマンドが競合することなく使用可能な状態にセットアップされます。

---

## 2. 含まれるツール群

スクリプトを実行すると、以下のツールが指定フォルダにダウンロード・展開されます：

- **VS Code** - コードエディタ（完全ポータブルモードで動作）
- **uv** - 超高速なPythonパッケージマネージャー（Python本体がなくても仮想環境を構築可能）
- **Git** - バージョン管理システム（Portable版）
- **Node.js** - JavaScript実行環境（v22.12.0 Full版）
- **Antigravity CLI** - 旧Gemini CLIの後継となるGoogle公式AIツール（コマンド名: `agy`）
- **7-Zip** - アーカイブ解凍用エンジン（内部使用）

---

## 3. 使い方

### 基本的な手順

1. **バッチファイルの実行**

```

portable_dev_env.bat

```
- 右クリック → 「管理者として実行」は**不要**です。
- 初回実行時は全ツールのダウンロード・展開が行われます（ネットワーク環境により数分かかります）。

2. **インストール完了後**
- 同じフォルダに `Start-DevEnv.bat` と専用GUIランチャー `Menu.ps1` が生成されます。
- 次回からは `Start-DevEnv.bat` をダブルクリックして起動します。

3. **GUIメニューの操作**
- `Terminal (agy)` ボタン：すべてのパスが通った開発用コマンドプロンプトを開きます。
- `VS Code` ボタン：カレントディレクトリでVS Codeを起動します。

---

## 4. 認証方法（Antigravity CLI のセットアップ）

Antigravity CLI (`agy`) を使用してGoogleのAIモデルにアクセスするためには、以下の**いずれか**の方法で認証を行う必要があります。

### 方法A: Googleアカウントで直接ログインする（推奨）
APIキーをファイルとして管理する必要がないため、最も簡単で安全な方法です。

1. GUIメニューから `Terminal (agy)` を起動します。
2. ターミナルで以下のコマンドを実行します。
```cmd
agy auth login

```

3. ブラウザが自動的に開き、Googleアカウントのログイン画面が表示されます。
4. ログインしてアクセスを許可すると、認証が完了します。

### 方法B: APIキーを手動で設定する

特定のプロジェクトに紐づいたAPIキーを使用したい場合向けの方法です。

1. GUIメニューの **API Key** 欄に、[Google AI Studio](https://aistudio.google.com/app/apikey) で取得したAPIキーを入力します（`[Get API Key]` ボタンで取得ページが開きます）。
2. `Terminal` または `VS Code` を起動すると、入力したキーが環境変数として自動展開され、`agy` コマンドが機能するようになります。

---

## 5. 各ツールの使用方法

本環境（`Start-DevEnv.bat`）から起動したすべてのターミナルには自動的に各ツールのパスが通っています。**GUIの「Terminal」ボタンで開いた独立ターミナル**はもちろん、「VS Code」内で開いた統合ターミナル（`Ctrl + ``）の両方で、以下のコマンドがPCシステムを汚染することなくそのまま利用可能です。

### Antigravity CLI (`agy`)

* **ヘルプの表示:** `agy --help`
* **単発のプロンプト送信:** `-p` オプションを使用します。
```cmd
agy -p "こんにちは、API通信のテストです。"

```


* **対話モードの起動:** `-i` オプションを使用すると、連続して対話ができます。
```cmd
agy -i

```



### uv (Pythonパッケージマネージャー)

Pythonの仮想環境構築やパッケージ管理を超高速で行えます。

* **仮想環境（.venv）の作成:** `uv venv`
* **パッケージのインストール:** `uv pip install numpy`
* **スクリプトの実行（環境を自動解決）:** `uv run script.py`

### Node.js & npm (JavaScript開発環境)

* **スクリプトの実行:** `node script.js`
* **パッケージのインストール:** `npm install <package-name>`

> **💡 npmに関する重要事項:**
> 本環境の `npm` はポータブル環境専用の設定ファイル（`.npmrc`）を自動作成して読み込みます。`npm install -g` でグローバルインストールを行ってもPC本体は汚染されず、ポータブルフォルダ内（`AntigravityCLI\npm-global`）に安全に隔離されます。

### Git (バージョン管理)

* **リポジトリのクローン:** `git clone <url>`

> **💡 SSH接続について:**
> 初回起動時に、仮想ホームディレクトリ（`home\.ssh`）に専用のSSH鍵（`id_rsa`）が自動生成されます。この公開鍵をGitHub等に登録することで、PC本体の認証情報を書き換えることなくセキュアな通信が完結します。

---

## 6. フォルダ構成

```
portable_dev_env.bat      （初期セットアップスクリプト）
│
├── Start-DevEnv.bat      （2回目以降の起動用バッチ）
├── Menu.ps1              （GUIランチャー本体）
├── gemini_key.txt        （APIキーの一時保存先）
│
├── VSCode\               （VS Codeポータブル版 / data\ に全設定を隔離）
├── Git\                  （Git for Windows Portable）
├── uv\                   （uvバイナリ）
├── NodeJS\               （Node.js実行環境）
├── AntigravityCLI\       （Antigravity CLI + npmパッケージ群）
│   ├── .npmrc            （ポータブル専用npm・プロキシ設定）
│   ├── npm-global\       （グローバルパッケージの隔離先）
│   └── node_modules\     （CLI本体）
├── home\                 （仮想HOMEディレクトリ）
│   ├── desktop\          （生成されるデスクトップフォルダ）
│   └── .ssh\             （ポータブル専用SSH鍵の隔離先）
└── temp\                 （一時解凍用フォルダ）

```

---

## 7. トラブルシューティング

#### Q1. 初期セットアップのダウンロードが失敗する

* **A1**：特殊な認証が必要なプロキシ環境の場合、スクリプトの実行前に手動で環境変数を設定してください。
```powershell
$env:HTTP_PROXY = "[http://user:pass@proxy.example.com:8080](http://user:pass@proxy.example.com:8080)"
$env:HTTPS_PROXY = "[http://user:pass@proxy.example.com:8080](http://user:pass@proxy.example.com:8080)"

```



#### Q2. VS Codeで拡張機能がダウンロードできない（プロキシエラー）

* **A2**：自動検出がうまく機能しなかった場合は、`VSCode\data\user-data\User\settings.json` を手動で編集し、直接プロキシURLを指定してください。
```json
{
  "http.proxy": "[http://proxy.example.com:8080](http://proxy.example.com:8080)"
}

```



### セキュリティ注意事項

* **APIキーの取り扱い:** APIキーを入力した場合、`gemini_key.txt` に平文で保存されます。環境を他者と共有する場合はファイルの削除、または「方法A（Googleログイン）」をご利用ください。
* **実行ポリシー:** 本スクリプトはPowerShellの `-ExecutionPolicy Bypass` を使用して動作します。

---

## ライセンス

このスクリプト自体のソースコードはMITライセンスです。同梱されてダウンロードされる各ソフトウェアは、それぞれの公式ライセンスに従います。

## 関連リンク

* [Google AI Studio (API Key)](https://aistudio.google.com/app/apikey)
* [Antigravity CLI 公式ドキュメント](https://antigravity.google/product/antigravity-cli)
* [uv Documentation](https://docs.astral.sh/uv/)
* [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable)
