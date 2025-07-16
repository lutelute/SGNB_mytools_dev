# ツール一覧

## 開発済みツール

### Worktree Manager
- **作成日**: 2025-07-05
- **言語**: Bash
- **概要**: Git worktreeを使用した開発フローとClaude実行を自動化するツールセット
- **機能**: 
  - Git worktreeの作成・削除・一覧表示
  - ワークツリー選択からのClaude CLI実行
  - プロジェクト情報の自動表示
  - 環境設定の自動チェック
  - リポジトリのクローンとワークツリー用設定
- **ディレクトリ**: `./worktree-manager/`
- **実行方法**: 
  - インストール: `cd worktree-manager/src && ./install.sh`
  - 使用: `worktree-manager [コマンド]`, `claude-launcher [オプション]`
  - 単体クローン: `./tool-manager/src/quick-clone.sh worktree-manager`
- **依存関係**: Git, Claude CLI, Bash
- **状態**: 完成

### Tool Manager
- **作成日**: 2025-07-05
- **言語**: Bash
- **概要**: ツール単位でのGit管理と独立リポジトリの作成・管理を行うツールセット
- **機能**: 
  - ツール用独立リポジトリの作成
  - ツール単体のクローン
  - 変更の同期
  - 簡単クローン機能
- **ディレクトリ**: `./tool-manager/`
- **実行方法**: 
  - 高度な管理: `./tool-manager/src/tool-manager.sh [コマンド]`
  - 簡単クローン: `./tool-manager/src/quick-clone.sh [ツール名]`
- **依存関係**: Git, GitHub CLI, Bash
- **状態**: 完成

### PDF Processor
- **作成日**: 2025-07-16
- **言語**: Bash, Python
- **概要**: フォルダ内のPDFファイルを一括処理する多機能ツール
- **機能**: 
  - PDFファイルの一覧表示（サブフォルダ対応）
  - PDFファイルの詳細情報表示（ページ数、サイズ等）
  - PDFファイルのテキスト抽出（サブフォルダ構造保持）
  - PDFファイルのマージ（全体統合）
  - サブフォルダごとのPDFマージ（フォルダ単位）
  - PDFファイルの一括印刷
  - GUIモード（macOSネイティブダイアログ）
  - 既存ファイルスキップ機能
- **ディレクトリ**: `./pdf-processor/`
- **実行方法**: 
  - コマンドライン: `./pdf-processor/pdf-processor.sh [command] [options]`
  - GUIモード: `./pdf-processor/pdf-processor.sh gui`
  - スキップオプション: `--skip-existing`, `--force`
- **依存関係**: Python 3.7+, PyPDF2, macOS (GUI機能)
- **状態**: 完成

---

## ツール追加テンプレート

新しいツールを追加する際は、以下のテンプレートを使用してください：

### [ツール名]
- **作成日**: YYYY-MM-DD
- **言語**: [使用言語]
- **概要**: [ツールの概要説明]
- **機能**: 
  - [機能1]
  - [機能2]
  - [機能3]
- **ディレクトリ**: `./[tool_directory]/`
- **実行方法**: [実行コマンドや手順]
- **依存関係**: [必要なライブラリやツール]
- **状態**: [開発中/完成/保留]

---

## カテゴリ別分類

### Web開発ツール
- （未追加）

### データ処理ツール
- PDF Processor

### 自動化ツール
- Worktree Manager
- Tool Manager

### ユーティリティ
- PDF Processor

### 学習・実験用
- （未追加）

---

## 更新履歴

- 2025-07-05: ツール一覧ファイル作成
- 2025-07-05: Worktree Manager 追加（Git worktree + Claude実行自動化）
- 2025-07-05: Tool Manager 追加（ツール単位でのGit管理と独立リポジトリ作成）
- 2025-07-16: PDF Processor 追加（PDF一括処理ツール、GUI対応、サブフォルダ処理）
- （今後のツール追加履歴がここに記録されます）