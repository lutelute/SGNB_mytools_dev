#!/bin/bash

# Tool Manager - ツール単位でのGit管理ツール
# 使用方法: ./tool-manager.sh [コマンド] [オプション]

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
    echo "Tool Manager - ツール単位でのGit管理ツール"
    echo ""
    echo "使用方法:"
    echo "  $0 create-repo <tool-name>           # ツール用独立リポジトリを作成"
    echo "  $0 split <tool-name>                 # メインリポジトリからツールを分離"
    echo "  $0 clone-tool <tool-name> [directory] # ツール単体をクローン"
    echo "  $0 sync-tool <tool-name>             # ツールの変更をメインリポジトリに同期"
    echo "  $0 list-tools                        # 管理対象ツール一覧を表示"
    echo "  $0 help                              # この使用方法を表示"
    echo ""
    echo "例:"
    echo "  $0 create-repo worktree-manager      # worktree-manager用リポジトリを作成"
    echo "  $0 split worktree-manager            # worktree-managerをメインから分離"
    echo "  $0 clone-tool worktree-manager       # worktree-managerのみをクローン"
    echo "  $0 sync-tool worktree-manager        # 変更をメインリポジトリに反映"
}

# GitHubユーザー名を取得
get_github_username() {
    if command -v gh &> /dev/null; then
        gh api user --jq .login 2>/dev/null || echo "SGNB"
    else
        echo "SGNB"
    fi
}

# ツール一覧を取得
get_tools_list() {
    local tools=()
    for dir in */; do
        if [[ -d "$dir" && "$dir" != ".git/" && "$dir" != "tool-manager/" ]]; then
            tools+=("${dir%/}")
        fi
    done
    echo "${tools[@]}"
}

# ツール用独立リポジトリを作成
create_tool_repo() {
    local tool_name="$1"
    local username=$(get_github_username)
    
    if [[ -z "$tool_name" ]]; then
        log_error "ツール名が指定されていません"
        show_usage
        exit 1
    fi
    
    if [[ ! -d "$tool_name" ]]; then
        log_error "ツールディレクトリが存在しません: $tool_name"
        exit 1
    fi
    
    log_info "ツール用リポジトリを作成中: $tool_name"
    
    # GitHubリポジトリを作成
    local repo_name="SGNB_${tool_name}"
    
    if command -v gh &> /dev/null; then
        log_info "GitHubにリポジトリを作成中: $repo_name"
        gh repo create "$repo_name" --public --description "Individual tool: $tool_name from SGNB_mytools_dev"
        log_success "GitHubリポジトリが作成されました: https://github.com/$username/$repo_name"
    else
        log_warning "GitHub CLIが見つかりません。手動でリポジトリを作成してください"
        echo "リポジトリ名: $repo_name"
        echo "URL: https://github.com/$username/$repo_name"
    fi
}

# ツールをメインリポジトリから分離
split_tool() {
    local tool_name="$1"
    local username=$(get_github_username)
    
    if [[ -z "$tool_name" ]]; then
        log_error "ツール名が指定されていません"
        show_usage
        exit 1
    fi
    
    if [[ ! -d "$tool_name" ]]; then
        log_error "ツールディレクトリが存在しません: $tool_name"
        exit 1
    fi
    
    log_info "ツールを分離中: $tool_name"
    
    # 一時ディレクトリ作成
    local temp_dir="/tmp/tool-split-$tool_name-$$"
    mkdir -p "$temp_dir"
    
    # サブツリーとして分離
    local repo_name="SGNB_${tool_name}"
    local remote_url="https://github.com/$username/$repo_name.git"
    
    # 分離されたリポジトリを作成
    log_info "分離されたリポジトリを作成中..."
    
    # 現在のディレクトリからツールのファイルのみをコピー
    cp -r "$tool_name" "$temp_dir/"
    
    # 分離されたリポジトリを初期化
    cd "$temp_dir"
    git init
    git add .
    git commit -m "Initial commit: Split $tool_name from SGNB_mytools_dev

This tool has been separated from the main SGNB_mytools_dev repository
for independent development and distribution.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    # リモートリポジトリが存在する場合、プッシュ
    if git ls-remote "$remote_url" &>/dev/null; then
        git remote add origin "$remote_url"
        git push -u origin main
        log_success "ツールが分離されました: $remote_url"
    else
        log_warning "リモートリポジトリが見つかりません: $remote_url"
        log_info "まず 'create-repo $tool_name' を実行してください"
    fi
    
    # 元のディレクトリに戻る
    cd - > /dev/null
    
    # 一時ディレクトリを削除
    rm -rf "$temp_dir"
}

# ツール単体をクローン
clone_tool() {
    local tool_name="$1"
    local directory="$2"
    local username=$(get_github_username)
    
    if [[ -z "$tool_name" ]]; then
        log_error "ツール名が指定されていません"
        show_usage
        exit 1
    fi
    
    # デフォルトディレクトリ名
    if [[ -z "$directory" ]]; then
        directory="$tool_name"
    fi
    
    local repo_name="SGNB_${tool_name}"
    local remote_url="https://github.com/$username/$repo_name.git"
    
    log_info "ツールをクローン中: $tool_name -> $directory"
    
    # クローン実行
    if git clone "$remote_url" "$directory"; then
        log_success "ツールがクローンされました: $directory"
        log_info "使用方法については $directory/README.md を参照してください"
    else
        log_error "クローンに失敗しました: $remote_url"
        log_info "リポジトリが存在しない場合は 'create-repo $tool_name' を実行してください"
        exit 1
    fi
}

# ツールの変更をメインリポジトリに同期
sync_tool() {
    local tool_name="$1"
    local username=$(get_github_username)
    
    if [[ -z "$tool_name" ]]; then
        log_error "ツール名が指定されていません"
        show_usage
        exit 1
    fi
    
    if [[ ! -d "$tool_name" ]]; then
        log_error "ツールディレクトリが存在しません: $tool_name"
        exit 1
    fi
    
    log_info "ツールの変更を同期中: $tool_name"
    
    local repo_name="SGNB_${tool_name}"
    local remote_url="https://github.com/$username/$repo_name.git"
    
    # 一時ディレクトリでツールリポジトリをクローン
    local temp_dir="/tmp/tool-sync-$tool_name-$$"
    
    if git clone "$remote_url" "$temp_dir"; then
        # 現在のツールディレクトリの内容を同期
        rsync -av --delete "$tool_name/" "$temp_dir/" --exclude='.git'
        
        cd "$temp_dir"
        
        # 変更があるかチェック
        if git diff --quiet && git diff --cached --quiet; then
            log_info "変更がありません: $tool_name"
        else
            # 変更をコミット
            git add .
            git commit -m "Sync changes from SGNB_mytools_dev

Updated $tool_name with latest changes from main repository.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
            
            git push origin main
            log_success "変更が同期されました: $tool_name"
        fi
        
        cd - > /dev/null
        rm -rf "$temp_dir"
    else
        log_error "ツールリポジトリのクローンに失敗しました: $remote_url"
        exit 1
    fi
}

# 管理対象ツール一覧を表示
list_tools() {
    log_info "管理対象ツール一覧:"
    
    local tools=($(get_tools_list))
    
    if [[ ${#tools[@]} -eq 0 ]]; then
        log_warning "管理対象ツールが見つかりません"
        return
    fi
    
    for tool in "${tools[@]}"; do
        local username=$(get_github_username)
        local repo_name="SGNB_${tool}"
        local remote_url="https://github.com/$username/$repo_name.git"
        
        echo "  📦 $tool"
        echo "      ディレクトリ: ./$tool/"
        echo "      想定リポジトリ: $remote_url"
        
        # リポジトリの存在確認
        if git ls-remote "$remote_url" &>/dev/null; then
            echo "      状態: ✅ 独立リポジトリ存在"
        else
            echo "      状態: ❌ 独立リポジトリ未作成"
        fi
        echo ""
    done
}

# メイン処理
main() {
    # gitリポジトリかどうかチェック
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "現在のディレクトリはgitリポジトリではありません"
        exit 1
    fi
    
    case "${1:-help}" in
        "create-repo")
            create_tool_repo "$2"
            ;;
        "split")
            split_tool "$2"
            ;;
        "clone-tool")
            clone_tool "$2" "$3"
            ;;
        "sync-tool")
            sync_tool "$2"
            ;;
        "list-tools")
            list_tools
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# スクリプト実行
main "$@"