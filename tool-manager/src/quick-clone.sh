#!/bin/bash

# Quick Clone - ツール単体の簡単クローンスクリプト
# 使用方法: ./quick-clone.sh <tool-name> [directory]

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 利用可能なツール一覧
AVAILABLE_TOOLS=(
    "worktree-manager"
    "tool-manager"
)

# 使用方法を表示
show_usage() {
    echo "Quick Clone - ツール単体の簡単クローンスクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 <tool-name> [directory]"
    echo ""
    echo "利用可能なツール:"
    for tool in "${AVAILABLE_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "例:"
    echo "  $0 worktree-manager                    # worktree-managerをクローン"
    echo "  $0 worktree-manager ./my-worktree-mgr  # 指定ディレクトリにクローン"
    echo ""
    echo "各ツールの詳細:"
    echo "  worktree-manager: Git worktree管理とClaude実行自動化"
    echo "  tool-manager: ツール単位でのGit管理"
}

# GitHubユーザー名を取得
get_github_username() {
    if command -v gh &> /dev/null; then
        gh api user --jq .login 2>/dev/null || echo "lutelute"
    else
        echo "lutelute"
    fi
}

# ツールが利用可能かチェック
is_tool_available() {
    local tool_name="$1"
    for available_tool in "${AVAILABLE_TOOLS[@]}"; do
        if [[ "$tool_name" == "$available_tool" ]]; then
            return 0
        fi
    done
    return 1
}

# ツール情報を表示
show_tool_info() {
    local tool_name="$1"
    
    case "$tool_name" in
        "worktree-manager")
            echo "📦 Worktree Manager"
            echo "   Git worktreeを使用した開発フローとClaude実行を自動化"
            echo "   - Git worktreeの作成・削除・一覧表示"
            echo "   - ワークツリー選択からのClaude CLI実行"
            echo "   - プロジェクト情報の自動表示"
            ;;
        "tool-manager")
            echo "📦 Tool Manager"
            echo "   ツール単位でのGit管理とリポジトリ分離"
            echo "   - ツール用独立リポジトリの作成"
            echo "   - ツール単体のクローン"
            echo "   - 変更の同期"
            ;;
    esac
}

# メイン処理
main() {
    local tool_name="$1"
    local directory="$2"
    
    if [[ -z "$tool_name" ]]; then
        show_usage
        exit 1
    fi
    
    if [[ "$tool_name" == "help" || "$tool_name" == "--help" || "$tool_name" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    # ツールが利用可能かチェック
    if ! is_tool_available "$tool_name"; then
        log_error "利用できないツールです: $tool_name"
        echo ""
        show_usage
        exit 1
    fi
    
    # ツール情報を表示
    show_tool_info "$tool_name"
    echo ""
    
    # デフォルトディレクトリ名
    if [[ -z "$directory" ]]; then
        directory="$tool_name"
    fi
    
    # 既存ディレクトリの確認
    if [[ -d "$directory" ]]; then
        log_error "ディレクトリが既に存在します: $directory"
        exit 1
    fi
    
    local username=$(get_github_username)
    local repo_name="SGNB_${tool_name}"
    local remote_url="https://github.com/$username/$repo_name.git"
    
    log_info "ツールをクローン中: $tool_name -> $directory"
    log_info "リポジトリ: $remote_url"
    
    # クローン実行
    if git clone "$remote_url" "$directory"; then
        log_success "ツールがクローンされました: $directory"
        echo ""
        log_info "次のステップ:"
        echo "  cd $directory"
        echo "  ./src/install.sh  # インストール（必要に応じて）"
        echo "  cat README.md     # 使用方法を確認"
        echo ""
        
        # READMEファイルの存在確認
        if [[ -f "$directory/README.md" ]]; then
            log_info "詳細な使用方法は $directory/README.md を参照してください"
        fi
    else
        log_error "クローンに失敗しました: $remote_url"
        log_info "リポジトリが存在しない可能性があります"
        exit 1
    fi
}

# スクリプト実行
main "$@"