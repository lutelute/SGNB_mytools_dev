# Tool Manager

ツール単位でのGit管理と独立リポジトリの作成・管理を行うツールセット。

## 概要

このツールセットにより、メインリポジトリ（SGNB_mytools_dev）内の個別ツールを独立したリポジトリとして管理できます。

## 主な機能

1. **ツール用独立リポジトリの作成** - 各ツールを個別のGitHubリポジトリとして分離
2. **ツール単体のクローン** - 特定のツールだけをクローン
3. **変更の同期** - 独立リポジトリとメインリポジトリ間の変更同期
4. **簡単クローン** - ワンコマンドでツールをクローン

## 使用方法

### 1. Tool Manager（高度な管理）

```bash
# ツール用独立リポジトリを作成
./tool-manager.sh create-repo worktree-manager

# ツールをメインリポジトリから分離
./tool-manager.sh split worktree-manager

# ツール単体をクローン
./tool-manager.sh clone-tool worktree-manager

# 変更をメインリポジトリに同期
./tool-manager.sh sync-tool worktree-manager

# 管理対象ツール一覧を表示
./tool-manager.sh list-tools
```

### 2. Quick Clone（簡単クローン）

```bash
# ツール単体を簡単にクローン
./quick-clone.sh worktree-manager

# 指定ディレクトリにクローン
./quick-clone.sh worktree-manager ./my-worktree-manager

# 利用可能なツール一覧を表示
./quick-clone.sh help
```

## 管理される各ツール

### worktree-manager
- **独立リポジトリ**: `SGNB_worktree-manager`
- **機能**: Git worktree管理とClaude実行自動化
- **クローン**: `./quick-clone.sh worktree-manager`

### tool-manager
- **独立リポジトリ**: `SGNB_tool-manager`
- **機能**: ツール単位でのGit管理
- **クローン**: `./quick-clone.sh tool-manager`

## 開発フロー

### 1. 新しいツールを独立リポジトリとして公開

```bash
# 1. ツール用GitHubリポジトリを作成
./tool-manager.sh create-repo my-new-tool

# 2. ツールをメインリポジトリから分離
./tool-manager.sh split my-new-tool

# 3. 独立リポジトリとして公開完了
```

### 2. 他の人がツールを使用

```bash
# 1. 利用可能なツール一覧を確認
./quick-clone.sh help

# 2. 必要なツールのみクローン
./quick-clone.sh worktree-manager

# 3. ツールをインストール・使用
cd worktree-manager
./src/install.sh
```

### 3. ツールの更新と同期

```bash
# 1. 独立リポジトリで開発
cd my-tool-repo
# 開発作業...
git commit -m "機能追加"
git push

# 2. メインリポジトリに変更を反映
cd ../SGNB_mytools_dev
./tool-manager/src/tool-manager.sh sync-tool my-tool
```

## 利点

### ユーザー視点
- **軽量**: 必要なツールだけクローン可能
- **独立性**: 他のツールに依存しない
- **簡単**: ワンコマンドでツール取得

### 開発者視点
- **管理性**: ツールごとに独立した開発・リリース
- **配布**: 個別ツールとして配布可能
- **保守性**: ツール間の影響を最小化

## ファイル構成

```
tool-manager/
├── README.md
└── src/
    ├── tool-manager.sh    # 高度なツール管理
    └── quick-clone.sh     # 簡単クローン
```

## 作成されるリポジトリ構成

各ツールは以下の命名規則で独立リポジトリが作成されます：

- メインリポジトリ: `SGNB_mytools_dev`
- ツール個別リポジトリ: `SGNB_[tool-name]`
  - 例: `SGNB_worktree-manager`
  - 例: `SGNB_tool-manager`

## 要件

- Git
- GitHub CLI（`gh`コマンド）推奨
- Bash（macOS/Linux環境）

## トラブルシューティング

### よくある問題

1. **リポジトリ作成エラー**
   - GitHub CLIがインストールされているか確認
   - GitHubにログインしているか確認

2. **クローンエラー**
   - リポジトリが存在するか確認
   - `create-repo`と`split`を実行済みか確認

3. **同期エラー**
   - 独立リポジトリに変更権限があるか確認
   - ネットワーク接続を確認

### デバッグ方法

エラーが発生した場合：

```bash
# 詳細ログを確認
./tool-manager.sh list-tools

# 手動でリポジトリ存在確認
git ls-remote https://github.com/USERNAME/SGNB_tool-name.git
```

## 使用例

### 他の開発者がworktree-managerを使いたい場合

```bash
# 1. 簡単にクローン
curl -sSL https://raw.githubusercontent.com/lutelute/SGNB_mytools_dev/main/tool-manager/src/quick-clone.sh | bash -s worktree-manager

# 2. インストール
cd worktree-manager
./src/install.sh

# 3. 使用開始
worktree-manager help
```

### 開発者がツールを更新する場合

```bash
# 1. 独立リポジトリを直接クローン
git clone https://github.com/lutelute/SGNB_worktree-manager.git
cd SGNB_worktree-manager

# 2. 開発・テスト
# 機能追加...

# 3. コミット・プッシュ
git add .
git commit -m "新機能追加"
git push

# 4. メインリポジトリに反映（必要に応じて）
cd ../SGNB_mytools_dev
./tool-manager/src/tool-manager.sh sync-tool worktree-manager
```