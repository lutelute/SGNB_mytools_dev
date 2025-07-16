# SGNB MyTools

個人開発用ツールの集合リポジトリです。

## 主要ツール

### [PDF Processor](./pdf-processor/) 🚀
フォルダ内のPDFファイルを一括処理する多機能ツール

**主要機能:**
- 📋 PDFファイルの一覧表示（サブフォルダ対応）
- 📊 PDFファイルの詳細情報表示（ページ数、サイズ等）
- 📝 PDFファイルのテキスト抽出（サブフォルダ構造保持）
- 🔗 PDFファイルのマージ（全体統合）
- 📁 サブフォルダごとのPDFマージ（フォルダ単位）
- 🖨️ PDFファイルの一括印刷
- 🖥️ GUIモード（macOSネイティブダイアログ）
- ⏭️ 既存ファイルスキップ機能

**実行方法:**
- コマンドライン: `./pdf-processor/pdf-processor.sh [command] [options]`
- GUIモード: `./pdf-processor/pdf-processor.sh gui`
- スキップオプション: `--skip-existing`, `--force`

**依存関係:** Python 3.7+, PyPDF2, macOS (GUI機能)

## 開発支援ツール

### [Development Tools](./worktree-manager/)
Git worktreeを使用した開発フローとClaude実行を自動化
- **機能**: ブランチごとのワークツリー作成・管理、Claude自動実行
- **実行**: `worktree-manager [command]`, `claude-launcher [options]`

### [Tool Manager](./tool-manager/)
ツール単位でのGit管理と独立リポジトリの作成・管理
- **機能**: 独立リポジトリ作成、ツール単体クローン、変更同期
- **実行**: `tool-manager [command]`, `quick-clone [tool-name]`

## クイックスタート

```bash
# PDF処理ツールをGUIで実行
./pdf-processor/pdf-processor.sh gui

# PDFファイルを一覧表示
./pdf-processor/pdf-processor.sh list ./documents

# サブフォルダごとにPDFをマージ
./pdf-processor/pdf-processor.sh merge-by-folder ./documents --skip-existing
```

## ドキュメント

- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)**: 新規ツール開発ガイド
- **[WORKLOG.md](./WORKLOG.md)**: 開発履歴

## 開発方針

- 各ツールは独立性を保つ
- 実用性を重視した機能設計
- 詳細なドキュメント整備