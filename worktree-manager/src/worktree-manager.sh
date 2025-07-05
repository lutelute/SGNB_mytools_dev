#!/bin/bash

# Git Worktree Manager - ワークツリー作成・管理ツール
# 使用方法: ./worktree-manager.sh [コマンド] [オプション]

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 使用方法を表示
show_usage() {
    echo "Git Worktree Manager"
    echo ""
    echo "使用方法:"
    echo "  $0 create <branch-name> [directory]    # 新しいワークツリーを作成"
    echo "  $0 list                                # ワークツリー一覧を表示"
    echo "  $0 remove <directory>                  # ワークツリーを削除"
    echo "  $0 cleanup                             # 不要なワークツリーをクリーンアップ"
    echo "  $0 clone <repository-url> <directory>  # リポジトリをクローンしてワークツリー用に準備"
    echo "  $0 help                                # この使用方法を表示"
    echo ""
    echo "例:"
    echo "  $0 create feature/new-feature          # feature/new-featureブランチのワークツリーを作成"
    echo "  $0 create hotfix/bug-fix ./hotfix      # hotfix/bug-fixブランチを./hotfixディレクトリに作成"
    echo "  $0 clone https://github.com/user/repo my-project  # リポジトリをクローン"
}

# gitリポジトリかどうかチェック
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "現在のディレクトリはgitリポジトリではありません"
        exit 1
    fi
}

# ワークツリー作成
create_worktree() {
    local branch_name="$1"
    local directory="$2"
    
    if [[ -z "$branch_name" ]]; then
        log_error "ブランチ名が指定されていません"
        show_usage
        exit 1
    fi
    
    # ディレクトリが指定されていない場合、ブランチ名から生成
    if [[ -z "$directory" ]]; then
        directory="../worktree-${branch_name//\//-}"
    fi
    
    log_info "ワークツリーを作成中: $branch_name -> $directory"
    
    # ブランチが存在するかチェック
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        log_info "既存のブランチ '$branch_name' を使用します"
        git worktree add "$directory" "$branch_name"
    else
        log_info "新しいブランチ '$branch_name' を作成します"
        git worktree add -b "$branch_name" "$directory"
    fi
    
    log_success "ワークツリーが作成されました: $directory"
    log_info "ディレクトリに移動するには: cd $directory"
}

# ワークツリー一覧表示
list_worktrees() {
    log_info "ワークツリー一覧:"
    git worktree list
}

# ワークツリー削除
remove_worktree() {
    local directory="$1"
    
    if [[ -z "$directory" ]]; then
        log_error "削除するディレクトリが指定されていません"
        show_usage
        exit 1
    fi
    
    log_warning "ワークツリーを削除中: $directory"
    
    # 確認
    read -p "本当に削除しますか? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_info "削除をキャンセルしました"
        exit 0
    fi
    
    git worktree remove "$directory"
    log_success "ワークツリーが削除されました: $directory"
}

# ワークツリークリーンアップ
cleanup_worktrees() {
    log_info "不要なワークツリーをクリーンアップ中..."
    git worktree prune
    log_success "クリーンアップが完了しました"
}

# リポジトリクローン
clone_repository() {
    local repo_url="$1"
    local directory="$2"
    
    if [[ -z "$repo_url" || -z "$directory" ]]; then
        log_error "リポジトリURLまたはディレクトリが指定されていません"
        show_usage
        exit 1
    fi
    
    log_info "リポジトリをクローン中: $repo_url -> $directory"
    
    # bare リポジトリとしてクローン
    git clone --bare "$repo_url" "$directory/.git"
    
    # ワークツリー用の設定
    cd "$directory"
    git config core.bare false
    git config core.worktree ..
    
    # mainブランチのワークツリーを作成
    git worktree add main
    
    log_success "リポジトリのクローンが完了しました: $directory"
    log_info "メインワークツリー: $directory/main"
}

# メイン処理
main() {
    case "${1:-help}" in
        "create")
            check_git_repo
            create_worktree "$2" "$3"
            ;;
        "list")
            check_git_repo
            list_worktrees
            ;;
        "remove")
            check_git_repo
            remove_worktree "$2"
            ;;
        "cleanup")
            check_git_repo
            cleanup_worktrees
            ;;
        "clone")
            clone_repository "$2" "$3"
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# スクリプト実行
main "$@"