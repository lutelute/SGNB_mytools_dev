#!/bin/bash

# Worktree Manager インストールスクリプト
# 使用方法: ./install.sh

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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# インストール先ディレクトリ
INSTALL_DIR="$HOME/.local/bin"

# インストール処理
install_scripts() {
    log_info "Worktree Manager をインストール中..."
    
    # インストールディレクトリの作成
    mkdir -p "$INSTALL_DIR"
    
    # スクリプトのコピー
    cp "worktree-manager.sh" "$INSTALL_DIR/worktree-manager"
    cp "claude-launcher.sh" "$INSTALL_DIR/claude-launcher"
    
    # 実行権限の付与
    chmod +x "$INSTALL_DIR/worktree-manager"
    chmod +x "$INSTALL_DIR/claude-launcher"
    
    log_success "インストールが完了しました"
}

# パスの確認
check_path() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        log_warning "$INSTALL_DIR がPATHに含まれていません"
        log_info "以下のコマンドを実行してPATHに追加してください:"
        echo ""
        echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
        echo "  source ~/.bashrc"
        echo ""
        echo "または ~/.zshrc を使用している場合:"
        echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
        echo "  source ~/.zshrc"
        echo ""
    else
        log_success "$INSTALL_DIR は既にPATHに含まれています"
    fi
}

# 使用方法の表示
show_usage_info() {
    echo ""
    log_info "使用方法:"
    echo "  worktree-manager create <branch-name>  # ワークツリー作成"
    echo "  worktree-manager list                  # ワークツリー一覧"
    echo "  claude-launcher                        # 現在のディレクトリでClaude実行"
    echo "  claude-launcher -l                     # ワークツリー選択してClaude実行"
    echo ""
    echo "詳細は以下のコマンドで確認できます:"
    echo "  worktree-manager help"
    echo "  claude-launcher --help"
}

# メイン処理
main() {
    echo "Worktree Manager インストーラー"
    echo "================================"
    echo ""
    
    install_scripts
    check_path
    show_usage_info
    
    log_success "インストールが完了しました！"
}

# スクリプト実行
main "$@"