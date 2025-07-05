#!/bin/bash

# Claude Launcher - プロジェクトディレクトリでClaude実行ツール
# 使用方法: ./claude-launcher.sh [オプション]

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
    echo "Claude Launcher - プロジェクトディレクトリでClaude実行ツール"
    echo ""
    echo "使用方法:"
    echo "  $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -d, --directory DIR    指定したディレクトリでClaude実行"
    echo "  -l, --list             ワークツリー一覧表示後に選択"
    echo "  -c, --current          現在のディレクトリでClaude実行"
    echo "  -h, --help             この使用方法を表示"
    echo ""
    echo "例:"
    echo "  $0                     # 現在のディレクトリでClaude実行"
    echo "  $0 -d ../feature-branch  # 指定ディレクトリでClaude実行"
    echo "  $0 -l                  # ワークツリー一覧から選択"
}

# Claudeがインストールされているかチェック
check_claude() {
    if ! command -v claude &> /dev/null; then
        log_error "Claude CLIがインストールされていません"
        log_info "インストール方法: https://github.com/anthropics/claude-cli"
        exit 1
    fi
}

# ワークツリー一覧から選択
select_worktree() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "現在のディレクトリはgitリポジトリではありません"
        exit 1
    fi
    
    log_info "利用可能なワークツリー:"
    
    # ワークツリー一覧を取得
    local worktrees=($(git worktree list --porcelain | grep "worktree " | cut -d' ' -f2))
    
    if [[ ${#worktrees[@]} -eq 0 ]]; then
        log_warning "ワークツリーが見つかりません"
        return 1
    fi
    
    # 選択肢を表示
    echo ""
    for i in "${!worktrees[@]}"; do
        echo "  $((i+1))) ${worktrees[$i]}"
    done
    echo ""
    
    # ユーザーの選択を取得
    read -p "選択してください (1-${#worktrees[@]}): " selection
    
    # 入力検証
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#worktrees[@]} ]]; then
        log_error "無効な選択です"
        return 1
    fi
    
    local selected_dir="${worktrees[$((selection-1))]}"
    echo "$selected_dir"
}

# プロジェクト情報を表示
show_project_info() {
    local directory="$1"
    
    log_info "プロジェクト情報:"
    echo "  ディレクトリ: $directory"
    
    # gitリポジトリの場合
    if [[ -d "$directory/.git" ]] || git -C "$directory" rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git -C "$directory" branch --show-current 2>/dev/null || echo "不明")
        local remote=$(git -C "$directory" config --get remote.origin.url 2>/dev/null || echo "なし")
        echo "  ブランチ: $branch"
        echo "  リモート: $remote"
    fi
    
    # package.jsonがある場合
    if [[ -f "$directory/package.json" ]]; then
        local name=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$directory/package.json" | cut -d'"' -f4 2>/dev/null || echo "不明")
        echo "  プロジェクト名: $name"
    fi
    
    # README.mdがある場合
    if [[ -f "$directory/README.md" ]]; then
        echo "  README.md: 存在"
    fi
    
    echo ""
}

# 環境変数設定
setup_environment() {
    local directory="$1"
    
    # プロジェクト固有の設定ファイルをチェック
    if [[ -f "$directory/.env" ]]; then
        log_info ".envファイルが見つかりました"
        log_warning "環境変数は自動で読み込まれません。必要に応じて手動で設定してください"
    fi
    
    # CLAUDE.mdファイルの存在チェック
    if [[ -f "$directory/CLAUDE.md" ]]; then
        log_info "CLAUDE.mdファイルが見つかりました"
    else
        log_info "CLAUDE.mdファイルがありません。必要に応じて作成してください"
    fi
}

# Claudeを実行
launch_claude() {
    local directory="$1"
    
    if [[ ! -d "$directory" ]]; then
        log_error "ディレクトリが存在しません: $directory"
        exit 1
    fi
    
    # 絶対パスに変換
    directory=$(realpath "$directory")
    
    log_info "Claude CLIを起動中..."
    show_project_info "$directory"
    setup_environment "$directory"
    
    log_success "Claude CLIを$directory で実行します"
    
    # ディレクトリを移動してClaude実行
    cd "$directory"
    exec claude
}

# メイン処理
main() {
    check_claude
    
    local directory=""
    local use_selection=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                directory="$2"
                shift 2
                ;;
            -l|--list)
                use_selection=true
                shift
                ;;
            -c|--current)
                directory="."
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "不明なオプション: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # ワークツリー選択モード
    if [[ "$use_selection" == true ]]; then
        directory=$(select_worktree)
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    fi
    
    # デフォルトは現在のディレクトリ
    if [[ -z "$directory" ]]; then
        directory="."
    fi
    
    launch_claude "$directory"
}

# スクリプト実行
main "$@"