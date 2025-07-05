# Worktree Manager

Git worktreeを使用した開発フローとClaude実行を自動化するツールセット。

## 概要

このツールセットは以下の機能を提供します：

1. **Git Worktreeの管理** - ブランチごとのワークツリーを簡単に作成・管理
2. **Claude自動実行** - プロジェクトディレクトリでClaude CLIを自動実行
3. **開発フロー最適化** - 複数ブランチでの並行開発を効率化

## 主な特徴

- Git worktreeの作成・削除・一覧表示
- ワークツリー選択からのClaude実行
- プロジェクト情報の自動表示
- 環境設定の自動チェック
- 色分けされた見やすいログ出力

## インストール

```bash
cd src
./install.sh
```

インストール後、PATHに `~/.local/bin` を追加してください：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 使用方法

### 1. Git Worktree Manager

#### 基本的な使用方法

```bash
# ヘルプを表示
worktree-manager help

# 新しいワークツリーを作成
worktree-manager create feature/new-feature

# 指定ディレクトリにワークツリーを作成
worktree-manager create hotfix/bug-fix ./hotfix-branch

# ワークツリー一覧を表示
worktree-manager list

# ワークツリーを削除
worktree-manager remove ../worktree-feature-new-feature

# 不要なワークツリーをクリーンアップ
worktree-manager cleanup
```

#### リポジトリのクローン

```bash
# bareリポジトリとしてクローンしてワークツリー用に設定
worktree-manager clone https://github.com/user/repo my-project
```

### 2. Claude Launcher

#### 基本的な使用方法

```bash
# 現在のディレクトリでClaude実行
claude-launcher

# 指定ディレクトリでClaude実行
claude-launcher -d ../feature-branch

# ワークツリー一覧から選択してClaude実行
claude-launcher -l

# ヘルプを表示
claude-launcher --help
```

## 開発フロー例

### 1. 新機能開発の開始

```bash
# 1. 新しいブランチでワークツリーを作成
worktree-manager create feature/user-authentication

# 2. 作成されたディレクトリに移動
cd ../worktree-feature-user-authentication

# 3. Claude CLIを起動
claude-launcher
```

### 2. 複数ブランチでの並行開発

```bash
# メインブランチでのワークツリー選択実行
claude-launcher -l

# 選択肢:
# 1) /path/to/main
# 2) /path/to/worktree-feature-user-authentication  
# 3) /path/to/worktree-hotfix-bug-fix
# 選択してください (1-3): 2
```

### 3. 開発完了後のクリーンアップ

```bash
# 不要なワークツリーを削除
worktree-manager remove ../worktree-feature-user-authentication

# 自動クリーンアップ
worktree-manager cleanup
```

## 機能詳細

### Git Worktree Manager

| コマンド | 機能 |
|----------|------|
| `create` | 新しいワークツリーを作成 |
| `list` | ワークツリー一覧を表示 |
| `remove` | ワークツリーを削除 |
| `cleanup` | 不要なワークツリーをクリーンアップ |
| `clone` | リポジトリをクローンしてワークツリー用に準備 |

### Claude Launcher

| オプション | 機能 |
|------------|------|
| `-d, --directory` | 指定ディレクトリでClaude実行 |
| `-l, --list` | ワークツリー一覧から選択 |
| `-c, --current` | 現在のディレクトリでClaude実行 |
| `-h, --help` | ヘルプを表示 |

## 要件

- Git（worktree機能が必要）
- Claude CLI（`claude`コマンドが利用可能）
- Bash（macOS/Linux環境）

## ファイル構成

```
worktree-manager/
├── README.md
└── src/
    ├── worktree-manager.sh    # Git worktree管理スクリプト
    ├── claude-launcher.sh     # Claude実行スクリプト
    └── install.sh             # インストールスクリプト
```

## トラブルシューティング

### よくある問題

1. **Claude CLIが見つからない**
   - Claude CLIがインストールされているか確認
   - PATHが正しく設定されているか確認

2. **ワークツリーが作成できない**
   - 現在のディレクトリがgitリポジトリか確認
   - ブランチ名が有効か確認

3. **権限エラー**
   - スクリプトに実行権限があるか確認
   - `chmod +x`でスクリプトに実行権限を付与

### ログとデバッグ

スクリプトは色分けされたログを出力します：
- 🔵 **INFO**: 情報メッセージ
- 🟢 **SUCCESS**: 成功メッセージ
- 🟡 **WARNING**: 警告メッセージ
- 🔴 **ERROR**: エラーメッセージ

## 開発者向け情報

### スクリプトの拡張

各スクリプトは関数ベースで構成されており、簡単に拡張できます：

```bash
# 新しい機能の追加例
add_custom_feature() {
    local param="$1"
    log_info "カスタム機能を実行中..."
    # 機能の実装
    log_success "カスタム機能が完了しました"
}
```

### 設定のカスタマイズ

スクリプト内の以下の変数を変更することで動作をカスタマイズできます：

```bash
# claude-launcher.sh
INSTALL_DIR="$HOME/.local/bin"  # インストール先ディレクトリ

# worktree-manager.sh  
# 色定義やログ形式など
```