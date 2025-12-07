# Portable Dev Env Installer

ポータブル開発環境の自動セットアップバッチファイルです。Windows環境で、システムインストール不要の開発環境（VS Code、Git、Python環境、Node.js、Google Gemini公式CLI）を一括で構築できます。

---

## 1. 簡単な説明

このバッチファイルは、以下のツールを自動的にダウンロード・展開し、統合されたポータブル開発環境を構築します：

- **VS Code** - コードエディタ（ポータブル版）
- **uv** - 高速なPythonパッケージマネージャー
- **Git** - バージョン管理システム（ポータブル版）
- **Node.js** - JavaScript実行環境
- **Google Gemini CLI（公式版）** - `@google/gemini-cli`パッケージ
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
   - **Gemini API Key** 欄に、Google AI StudioのAPIキーを入力
   - `[Get API Key]` ボタンで取得ページを開けます
   - `VS Code` ボタン：VS Codeを起動
   - `Terminal (gemini)` ボタン：コマンドプロンプトを開く

4. **Gemini CLIの使用**
   - ターミナルで以下のコマンドが使用可能：
   ```cmd
   gemini --help
   gemini "Tell me a joke"
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
├── GeminiCLI\            （Gemini CLI + npm packages）
│   ├── gemini.cmd        （ラッパースクリプト）
│   └── node_modules\     （@google/gemini-cli本体）
├── home\                 （仮想HOMEディレクトリ）
│   ├── desktop\          （生成されるデスクトップフォルダ）
│   └── .ssh\             （SSH鍵の保存先）
└── temp\                 （一時ファイル）
```

---

## 3. 詳細な解説

### スクリプトの動作フロー

#### 3.1. 初期化処理
- **ハイブリッド形式**：1つのファイルで「バッチ」と「PowerShell」を両立
  - 先頭のバッチ部分がPowerShellコードを呼び出します
  - TLS 1.2を有効化し、セキュアなHTTPS通信を保証

#### 3.2. ツールのダウンロード＆展開

| ツール | ダウンロード元 | 展開先 | 備考 |
|--------|---------------|--------|------|
| **7-Zip** | [公式サイト](https://www.7-zip.org/) | `temp\7z_full\` | `.7z`形式の解凍用 |
| **VS Code** | [Microsoft公式](https://code.visualstudio.com/) | `VSCode\` | Zip版をダウンロード |
| **uv** | [GitHub Releases](https://github.com/astral-sh/uv/releases) | `uv\` | 最新版を自動取得 |
| **Git** | [GitHub Releases](https://github.com/git-for-windows/git/releases) | `Git\` | PortableGit版 |
| **Node.js** | [公式サイト](https://nodejs.org/) | `NodeJS\` | v22.12.0（Full版） |
| **Gemini CLI** | npm経由 | `GeminiCLI\` | `npm install @google/gemini-cli` |

#### 3.3. 各ツールの詳細

##### 1. VS Code（ポータブルモード）
- `data\` フォルダを作成して拡張機能・設定を保存
- プロキシ設定を自動検出し `settings.json` に反映
- SSH拡張機能用のパスを自動設定

##### 2. uv（Python環境）
- Pythonプロジェクトの依存関係管理に使用
- `uv venv` でvirtualenvを高速作成可能

##### 3. Git（バージョン管理）
- SSH鍵を自動生成（`home\.ssh\id_rsa`）
- `curl.exe` がダウンロードに使用される場合あり

##### 4. Node.js + npm
- `GeminiCLI\` 内に独立した環境を構築
- `.npmrc` でキャッシュ・プレフィックスを設定
- プロキシ環境にも対応

##### 5. Google Gemini CLI（公式版）
- **重要**：`@google/gemini-cli` パッケージを使用
  - Google公式のCLIツール
  - npm経由でインストール
- `gemini.cmd` ラッパーで `node_modules\.bin\gemini.cmd` を呼び出し
- 環境変数 `GEMINI_API_KEY` を自動設定

#### 3.4. GUIランチャーの生成

##### Menu.ps1（PowerShell GUI）
- **API Key管理**
  - `gemini_key.txt` に保存
  - 起動時に環境変数 `GEMINI_API_KEY` に自動設定
- **プロキシ自動検出**
  - Windowsのシステム設定から読み取り
  - VS CodeとGitに自動反映
- **ボタン機能**
  - `VS Code`：カレントディレクトリでVS Codeを起動
  - `Terminal`：開発環境用コマンドプロンプトを開く

##### Start-DevEnv.bat
- 環境変数 `PATH` に全ツールを追加
- `HOME` と `USERPROFILE` を仮想化
- `Menu.ps1` を呼び出し

### 主要な機能

#### プロキシ対応
- レジストリから自動検出（`HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings`）
- npm、VS Code、Git、curlに設定を適用

#### エラーハンドリング
- `$ErrorActionPreference = "Stop"` で致命的エラーを即座に停止
- curl/Invoke-WebRequestの両方に対応

#### ダウンロード最適化
- GitHub API経由で最新リリースを取得
- 既存ファイルがある場合はスキップ
- curl（Gitに含まれる）を優先使用

### トラブルシューティング

#### Q1. ダウンロードが失敗する
- **A1**：プロキシ環境の場合、初回はプロキシ設定前なので失敗する可能性があります
  - 手動でプロキシを設定：
    ```powershell
    $env:HTTP_PROXY = "http://proxy.example.com:8080"
    $env:HTTPS_PROXY = "http://proxy.example.com:8080"
    ```
  - その後バッチファイルを再実行

#### Q2. Geminiコマンドが動かない
- **A2**：APIキーが未設定の可能性
  ```cmd
  echo %GEMINI_API_KEY%
  ```
  - 空の場合は `Menu.ps1` で設定

#### Q3. VS Codeでプロキシエラーが出る
- **A3**：`VSCode\data\user-data\User\settings.json` を手動編集
  ```json
  {
    "http.proxy": "http://proxy.example.com:8080"
  }
  ```

#### Q4. SSHが使えない
- **A4**：鍵が生成されていない場合
  ```cmd
  Git\usr\bin\ssh-keygen.exe -t rsa -b 2048 -f home\.ssh\id_rsa
  ```

### セキュリティ注意事項

1. **APIキーの取り扱い**
   - `gemini_key.txt` は平文保存されます
   - 環境を共有する場合は削除してください

2. **プロキシ認証**
   - 認証付きプロキシは手動設定が必要です
   - `.npmrc` に以下を追加：
     ```
     proxy=http://user:pass@proxy:8080
     https-proxy=http://user:pass@proxy:8080
     ```

3. **実行ポリシー**
   - `-ExecutionPolicy Bypass` を使用
   - 企業環境では管理者に確認してください

### カスタマイズ方法

#### Node.jsのバージョン変更
```powershell
$nodeUrl = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.zip"
```

#### 追加のnpmパッケージ
```cmd
cd GeminiCLI
..\NodeJS\npm install <package-name>
```

#### VS Code拡張機能の自動インストール
`Menu.ps1` の起動前に追加：
```powershell
& "$VSCodeDir\bin\code.cmd" --install-extension ms-python.python
```

---

## ライセンス

このスクリプトはMITライセンスです。各ツールは個別のライセンスに従います。

## 関連リンク

- [Google Gemini API](https://ai.google.dev/)
- [@google/gemini-cli npm package](https://www.npmjs.com/package/@google/gemini-cli)
- [uv Documentation](https://docs.astral.sh/uv/)
- [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable)
