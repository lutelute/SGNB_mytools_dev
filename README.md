# SGNB マイツール開発リポジトリ

このリポジトリは、個人開発用のツールを管理・開発するためのワークスペースです。

## 概要

- **目的**: 開発したツールの一元管理とGitHubへのアップロード
- **構成**: 各ツールは独立したディレクトリで管理
- **対象**: 個人開発・業務効率化・学習用ツール

## リポジトリ構成

```
SGNB_mytools_dev/
├── README.md              # このファイル
├── WORKLOG.md            # 作業ログ
├── TOOLS.md              # ツール一覧
├── DEVELOPMENT_GUIDE.md  # 開発指示書
└── [tool_name]/          # 各ツールのディレクトリ
    ├── src/
    ├── README.md
    └── (設定ファイル等)
```

## 主要ファイル

- **WORKLOG.md**: 開発履歴とトーク切れ対応のための作業ログ
- **TOOLS.md**: 開発済みツールの一覧と概要
- **DEVELOPMENT_GUIDE.md**: 新規ツール開発時の指示書

## 開発済みツール

### [Worktree Manager](./worktree-manager/)
Git worktreeを使用した開発フローとClaude実行を自動化するツールセット
- **機能**: ブランチごとのワークツリー作成・管理、Claude自動実行
- **実行**: `worktree-manager [command]`, `claude-launcher [options]`
- **依存関係**: Git, Claude CLI, Bash

### [Tool Manager](./tool-manager/)
ツール単位でのGit管理と独立リポジトリの作成・管理を行うツールセット
- **機能**: 独立リポジトリ作成、ツール単体クローン、変更同期
- **実行**: `tool-manager [command]`, `quick-clone [tool-name]`
- **依存関係**: Git, GitHub CLI, Bash

### [PDF Processor](./pdf-processor/)
フォルダ内のPDFファイルを一括処理する多機能ツール
- **機能**: 一覧表示、詳細情報、テキスト抽出、マージ、サブフォルダ別マージ、一括印刷
- **実行**: `pdf-processor [command] [options]` または GUIモード
- **依存関係**: Python 3.7+, PyPDF2, macOS (GUI機能)

## 使用方法

1. 新しいツールを開発する際は `DEVELOPMENT_GUIDE.md` を参照
2. 開発進捗は `WORKLOG.md` に記録
3. 完成したツールは `TOOLS.md` に追加
4. 各ツールは独立したディレクトリで管理

## 注意事項

- 各ツールは独立性を保つ
- ワークログは必須（トーク切れ対応）
- GitHubアップロード前の最終確認を忘れずに