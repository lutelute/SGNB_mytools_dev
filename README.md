# SGNB MyTools

個人開発用ツールの集合リポジトリです。

## 主要ツール

### [PDF Processor](./pdf-processor/) 🚀
フォルダ内のPDFファイルを一括処理する多機能ツール
- **機能**: 一覧表示、詳細情報、テキスト抽出、マージ、サブフォルダ別マージ、一括印刷
- **特徴**: GUIモード、サブフォルダ対応、既存ファイルスキップ
- **実行**: `./pdf-processor/pdf-processor.sh [command]` または `gui`
- **依存関係**: Python 3.7+, PyPDF2, macOS (GUI機能)

### [Development Tools](./worktree-manager/)
Git worktreeを使用した開発フローとClaude実行を自動化
- **機能**: ブランチごとのワークツリー作成・管理、Claude自動実行
- **実行**: `worktree-manager [command]`, `claude-launcher [options]`
- **依存関係**: Git, Claude CLI, Bash

### [Tool Manager](./tool-manager/)
ツール単位でのGit管理と独立リポジトリの作成・管理
- **機能**: 独立リポジトリ作成、ツール単体クローン、変更同期
- **実行**: `tool-manager [command]`, `quick-clone [tool-name]`
- **依存関係**: Git, GitHub CLI, Bash

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

- **[TOOLS.md](./TOOLS.md)**: 全ツールの詳細情報
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)**: 新規ツール開発ガイド
- **[WORKLOG.md](./WORKLOG.md)**: 開発履歴

## 開発方針

- 各ツールは独立性を保つ
- 実用性を重視した機能設計
- 詳細なドキュメント整備