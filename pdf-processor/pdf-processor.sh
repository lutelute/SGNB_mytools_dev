#!/bin/bash

# PDF Processor - フォルダ内のPDFファイルを一括処理するツール

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

# ヘルプ表示
show_help() {
    echo "PDF Processor - フォルダ内のPDFファイルを一括処理するツール"
    echo ""
    echo "使用方法:"
    echo "  $0 list [directory]     - フォルダ内のPDFファイルを一覧表示"
    echo "  $0 info [directory]     - PDFファイルの基本情報を表示"
    echo "  $0 extract [directory]  - PDFファイルのテキストを抽出"
    echo "  $0 merge [directory] [output.pdf] - PDFファイルをマージ"
    echo "  $0 merge-by-folder [directory] - サブフォルダごとにPDFをマージ"
    echo "  $0 print [directory]    - フォルダ内のPDFファイルを一括印刷"
    echo "  $0 gui                  - GUIモードで実行"
    echo "  $0 help                 - このヘルプを表示"
    echo ""
    echo "オプション:"
    echo "  directory               - 処理対象のディレクトリ（デフォルト: 現在のディレクトリ）"
    echo "  --skip-existing         - 既存ファイルをスキップ"
    echo "  --force                 - 既存ファイルを上書き"
    echo ""
    echo "例:"
    echo "  $0 list ./documents"
    echo "  $0 info"
    echo "  $0 extract ./pdfs"
    echo "  $0 merge ./pdfs merged.pdf"
    echo "  $0 merge-by-folder ./pdfs --skip-existing"
    echo "  $0 print ./pdfs"
    echo "  $0 gui                  - GUIで操作"
}

# PDFファイルの存在チェック
check_pdf_files() {
    local dir="$1"
    local recursive="${2:-false}"
    
    local pdf_count
    if [ "$recursive" = "true" ]; then
        pdf_count=$(find "$dir" -name "*.pdf" -type f | wc -l)
    else
        pdf_count=$(find "$dir" -maxdepth 1 -name "*.pdf" -type f | wc -l)
    fi
    
    if [ "$pdf_count" -eq 0 ]; then
        if [ "$recursive" = "true" ]; then
            log_warning "ディレクトリ '$dir' とサブフォルダにPDFファイルが見つかりません"
        else
            log_warning "ディレクトリ '$dir' にPDFファイルが見つかりません"
        fi
        return 1
    fi
    
    return 0
}

# PDFファイル一覧表示
list_pdfs() {
    local dir="${1:-.}"
    
    if [ ! -d "$dir" ]; then
        log_error "ディレクトリ '$dir' が存在しません"
        return 1
    fi
    
    log_info "ディレクトリ '$dir' 内のPDFファイル一覧（サブフォルダも含む）:"
    
    if ! check_pdf_files "$dir" "true"; then
        return 1
    fi
    
    local count=0
    while IFS= read -r -d '' file; do
        count=$((count + 1))
        local filename=$(basename "$file")
        local filepath=$(dirname "$file")
        local relative_path=$(realpath --relative-to="$dir" "$file")
        local filesize=$(ls -lh "$file" | awk '{print $5}')
        echo "  $count. $relative_path ($filesize)"
    done < <(find "$dir" -name "*.pdf" -type f -print0 | sort -z)
    
    log_success "合計 $count 個のPDFファイルが見つかりました"
}

# PDFファイルの基本情報表示
show_pdf_info() {
    local dir="${1:-.}"
    
    if [ ! -d "$dir" ]; then
        log_error "ディレクトリ '$dir' が存在しません"
        return 1
    fi
    
    if ! check_pdf_files "$dir" "true"; then
        return 1
    fi
    
    log_info "PDFファイルの詳細情報（サブフォルダも含む）:"
    
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")
        local relative_path=$(realpath --relative-to="$dir" "$file")
        local filesize=$(ls -lh "$file" | awk '{print $5}')
        local modified=$(ls -l "$file" | awk '{print $6, $7, $8}')
        
        echo ""
        echo "📄 $relative_path"
        echo "   サイズ: $filesize"
        echo "   更新日: $modified"
        echo "   絶対パス: $file"
        
        # Pythonを使ってページ数を取得（PyPDF2が利用可能な場合）
        if command -v python3 >/dev/null 2>&1; then
            local pages=$(python3 -c "
import sys
try:
    import PyPDF2
    with open('$file', 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        print(len(reader.pages))
except:
    print('?')
" 2>/dev/null)
            echo "   ページ数: $pages"
        fi
    done < <(find "$dir" -name "*.pdf" -type f -print0 | sort -z)
}

# PDFテキスト抽出
extract_pdf_text() {
    local dir="${1:-.}"
    local output_dir="$dir/extracted_text"
    
    if [ ! -d "$dir" ]; then
        log_error "ディレクトリ '$dir' が存在しません"
        return 1
    fi
    
    if ! check_pdf_files "$dir" "true"; then
        return 1
    fi
    
    # 出力ディレクトリを作成
    mkdir -p "$output_dir"
    
    log_info "PDFファイルからテキストを抽出中（サブフォルダも含む）..."
    
    local count=0
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file" .pdf)
        local relative_path=$(realpath --relative-to="$dir" "$file")
        local relative_dir=$(dirname "$relative_path")
        
        # サブフォルダ構造を保持
        local output_subdir="$output_dir/$relative_dir"
        mkdir -p "$output_subdir"
        
        local output_file="$output_subdir/${filename}.txt"
        
        log_info "処理中: $relative_path"
        
        # Pythonを使ってテキスト抽出
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import sys
try:
    import PyPDF2
    with open('$file', 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        text = ''
        for page_num, page in enumerate(reader.pages, 1):
            text += f'--- Page {page_num} ---\n'
            text += page.extract_text() + '\n\n'
        
        # ファイル情報をヘッダーに追加
        header = f'# テキスト抽出結果\n'
        header += f'# 元ファイル: $relative_path\n'
        header += f'# 総ページ数: {len(reader.pages)}\n'
        header += f'# 抽出日時: $(date)\n\n'
        
        with open('$output_file', 'w', encoding='utf-8') as out:
            out.write(header + text)
    print('✓ テキスト抽出完了: $output_file')
except ImportError:
    print('✗ PyPDF2ライブラリが必要です: pip install PyPDF2')
    sys.exit(1)
except Exception as e:
    print(f'✗ エラー: {e}')
    sys.exit(1)
"
        else
            log_error "Python3が必要です"
            return 1
        fi
        
        count=$((count + 1))
    done < <(find "$dir" -name "*.pdf" -type f -print0 | sort -z)
    
    log_success "$count 個のPDFファイルからテキストを抽出しました"
    log_info "抽出されたテキストファイル: $output_dir/"
}

# PDFマージ
merge_pdfs() {
    local dir="${1:-.}"
    local output_file="${2:-merged.pdf}"
    local skip_existing="${3:-false}"
    
    if [ ! -d "$dir" ]; then
        log_error "ディレクトリ '$dir' が存在しません"
        return 1
    fi
    
    if ! check_pdf_files "$dir" "true"; then
        return 1
    fi
    
    # 既存ファイルの確認
    if [ -f "$output_file" ]; then
        if [ "$skip_existing" = "true" ]; then
            log_info "既存ファイルをスキップします: $output_file"
            return 0
        elif [ "$skip_existing" != "force" ]; then
            log_warning "既存ファイルが存在します: $output_file"
            echo -n "上書きしますか？ (y/N): "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "処理をキャンセルしました"
                return 0
            fi
        fi
    fi
    
    log_info "PDFファイルをマージ中（サブフォルダも含む）..."
    
    # Pythonを使ってPDFマージ
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import sys
import os
from pathlib import Path
try:
    import PyPDF2
    
    merger = PyPDF2.PdfMerger()
    
    # サブフォルダも含めて再帰的にPDFファイルを検索
    pdf_files = []
    for root, dirs, files in os.walk('$dir'):
        for file in files:
            if file.lower().endswith('.pdf'):
                pdf_files.append(os.path.join(root, file))
    
    # ファイル名でソート
    pdf_files = sorted(pdf_files)
    
    print(f'見つかったPDFファイル: {len(pdf_files)} 個')
    print('マージ順序:')
    
    for i, pdf_file in enumerate(pdf_files, 1):
        rel_path = os.path.relpath(pdf_file, '$dir')
        print(f'  {i}. {rel_path}')
        
        try:
            merger.append(pdf_file)
        except Exception as e:
            print(f'  ⚠️ スキップ: {rel_path} - {e}')
            continue
    
    # マージ結果を保存
    with open('$output_file', 'wb') as output:
        merger.write(output)
    
    print(f'✓ マージ完了: $output_file')
    print(f'✓ {len(pdf_files)} 個のPDFファイルをマージしました')
    
    # ファイルサイズを表示
    output_size = os.path.getsize('$output_file')
    if output_size > 1024 * 1024:
        print(f'✓ 出力ファイルサイズ: {output_size / (1024 * 1024):.1f} MB')
    else:
        print(f'✓ 出力ファイルサイズ: {output_size / 1024:.1f} KB')
        
except ImportError:
    print('✗ PyPDF2ライブラリが必要です: pip install PyPDF2')
    sys.exit(1)
except Exception as e:
    print(f'✗ エラー: {e}')
    sys.exit(1)
"
    else
        log_error "Python3が必要です"
        return 1
    fi
    
    log_success "PDFマージが完了しました: $output_file"
}

# サブフォルダごとのPDFマージ
merge_pdfs_by_folder() {
    local dir="${1:-.}"
    local skip_existing="${2:-false}"
    
    if [ ! -d "$dir" ]; then
        log_error "ディレクトリ '$dir' が存在しません"
        return 1
    fi
    
    if ! check_pdf_files "$dir" "true"; then
        return 1
    fi
    
    log_info "サブフォルダごとにPDFファイルをマージ中..."
    
    # 出力ディレクトリを作成
    local output_dir="$dir/merged_by_folder"
    mkdir -p "$output_dir"
    
    # Pythonを使ってサブフォルダごとのPDFマージ
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import sys
import os
from pathlib import Path
from collections import defaultdict
try:
    import PyPDF2
    
    base_dir = Path('$dir')
    output_dir = Path('$output_dir')
    
    # サブフォルダごとにPDFファイルを分類
    folders_with_pdfs = defaultdict(list)
    
    # ルートディレクトリのPDFファイルを収集
    root_pdfs = []
    for pdf_file in base_dir.glob('*.pdf'):
        root_pdfs.append(pdf_file)
    
    if root_pdfs:
        folders_with_pdfs['root'] = sorted(root_pdfs)
    
    # サブフォルダのPDFファイルを収集
    for root, dirs, files in os.walk(base_dir):
        if root == str(base_dir):
            continue  # ルートディレクトリはスキップ
            
        folder_path = Path(root)
        pdf_files = []
        
        for file in files:
            if file.lower().endswith('.pdf'):
                pdf_files.append(folder_path / file)
        
        if pdf_files:
            # 相対パスを取得してフォルダ名として使用
            rel_path = folder_path.relative_to(base_dir)
            folder_name = str(rel_path).replace('/', '_')
            folders_with_pdfs[folder_name] = sorted(pdf_files)
    
    if not folders_with_pdfs:
        print('PDFファイルが見つかりません')
        sys.exit(1)
    
    total_folders = len(folders_with_pdfs)
    processed_folders = 0
    skipped_folders = 0
    
    print(f'処理対象フォルダ: {total_folders} 個')
    print()
    
    # 各フォルダごとにマージ処理
    for folder_name, pdf_files in folders_with_pdfs.items():
        if not pdf_files:
            continue
            
        processed_folders += 1
        
        # 出力ファイル名を決定
        if folder_name == 'root':
            output_filename = 'merged_root.pdf'
            display_name = 'ルートディレクトリ'
        else:
            output_filename = f'merged_{folder_name}.pdf'
            display_name = folder_name.replace('_', '/')
        
        output_file = output_dir / output_filename
        
        print(f'[{processed_folders}/{total_folders}] {display_name}')
        print(f'  PDFファイル数: {len(pdf_files)} 個')
        print(f'  出力ファイル: {output_file}')
        
        # 既存ファイルのチェック
        if output_file.exists():
            if '$skip_existing' == 'true':
                print(f'  ⏭️ スキップ: 既存ファイルが存在します')
                skipped_folders += 1
                print()
                continue
            elif '$skip_existing' != 'force':
                print(f'  ⚠️ 既存ファイルが存在します')
                # 非対話モードでは上書きしない
                if not sys.stdin.isatty():
                    print(f'  ⏭️ スキップ: 非対話モードのため既存ファイルをスキップします')
                    skipped_folders += 1
                    print()
                    continue
        
        # マージ処理
        merger = PyPDF2.PdfMerger()
        
        for pdf_file in pdf_files:
            try:
                rel_path = pdf_file.relative_to(base_dir)
                print(f'    追加: {rel_path}')
                merger.append(str(pdf_file))
            except Exception as e:
                print(f'    ⚠️ スキップ: {pdf_file.name} - {e}')
                continue
        
        # マージ結果を保存
        try:
            with open(output_file, 'wb') as output:
                merger.write(output)
            
            # ファイルサイズを表示
            file_size = output_file.stat().st_size
            if file_size > 1024 * 1024:
                size_str = f'{file_size / (1024 * 1024):.1f} MB'
            else:
                size_str = f'{file_size / 1024:.1f} KB'
            
            print(f'    ✓ 完了: {size_str}')
            
        except Exception as e:
            print(f'    ✗ エラー: {e}')
        
        merger.close()
        print()
    
    print(f'✓ 全処理完了: {processed_folders - skipped_folders} 個のフォルダを処理しました')
    if skipped_folders > 0:
        print(f'⏭️ スキップ: {skipped_folders} 個のフォルダ')
    print(f'✓ 出力ディレクトリ: {output_dir}')
    
except ImportError:
    print('✗ PyPDF2ライブラリが必要です: pip install PyPDF2')
    sys.exit(1)
except Exception as e:
    print(f'✗ エラー: {e}')
    sys.exit(1)
"
    else
        log_error "Python3が必要です"
        return 1
    fi
    
    log_success "サブフォルダごとのPDFマージが完了しました: $output_dir/"
}

# PDF一括印刷
print_pdfs() {
    local dir="${1:-.}"
    local printer_name=""
    
    if [ ! -d "$dir" ]; then
        log_error "ディレクトリ '$dir' が存在しません"
        return 1
    fi
    
    if ! check_pdf_files "$dir" "true"; then
        return 1
    fi
    
    # 利用可能なプリンターを表示
    log_info "利用可能なプリンター一覧:"
    
    # macOSの場合
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v lpstat >/dev/null 2>&1; then
            # macOSでのプリンター一覧取得
            lpstat -p 2>/dev/null | awk '/^printer/ {print "  - " $2}' || true
            
            # デフォルトプリンターを取得
            local default_printer=$(lpstat -d 2>/dev/null | awk '/system default destination:/ {print $4}' | sed 's/://g')
            if [ -n "$default_printer" ]; then
                log_info "デフォルトプリンター: $default_printer"
                printer_name="$default_printer"
            fi
        fi
        
        # System Preferencesからプリンター情報を取得（代替方法）
        if command -v system_profiler >/dev/null 2>&1; then
            log_info "システムプリンター情報:"
            system_profiler SPPrintersDataType 2>/dev/null | grep -A1 "Printer Name:" | grep -v "Printer Name:" | sed 's/^[[:space:]]*/  - /' || true
        fi
        
        # CUPSからプリンター情報を取得
        if [ -z "$printer_name" ] && command -v lpoptions >/dev/null 2>&1; then
            local cups_default=$(lpoptions -d 2>/dev/null | cut -d' ' -f1)
            if [ -n "$cups_default" ]; then
                log_info "CUPS デフォルトプリンター: $cups_default"
                printer_name="$cups_default"
            fi
        fi
    else
        # Linux系の場合
        if command -v lpstat >/dev/null 2>&1; then
            lpstat -p | grep -E "^printer" | awk '{print "  - " $2}'
            
            # デフォルトプリンターを取得
            local default_printer=$(lpstat -d 2>/dev/null | grep -o "system default destination: [^[:space:]]*" | cut -d' ' -f4)
            if [ -n "$default_printer" ]; then
                log_info "デフォルトプリンター: $default_printer"
                printer_name="$default_printer"
            fi
        fi
    fi
    
    # プリンターが見つからない場合の対処
    if [ -z "$printer_name" ]; then
        log_warning "デフォルトプリンターが見つかりません"
        if command -v lpoptions >/dev/null 2>&1; then
            log_info "利用可能なプリンター（lpoptions）:"
            lpoptions -l 2>/dev/null | head -5 || true
        fi
    fi
    
    echo ""
    read -p "使用するプリンター名を入力してください（空白でデフォルト）: " input_printer
    
    if [ -n "$input_printer" ]; then
        printer_name="$input_printer"
    fi
    
    if [ -z "$printer_name" ]; then
        log_error "プリンター名が指定されていません"
        log_info "利用可能なプリンター確認コマンド:"
        echo "  - lpstat -p                    # プリンター一覧"
        echo "  - lpstat -d                    # デフォルトプリンター"
        echo "  - lpoptions -p [printer_name]  # プリンター設定"
        echo "  - system_profiler SPPrintersDataType  # システム情報（macOS）"
        echo ""
        echo "プリンターが設定されていない場合は、システム設定から追加してください。"
        return 1
    fi
    
    log_info "プリンター '$printer_name' を使用してPDFファイルを印刷中（サブフォルダも含む）..."
    
    local count=0
    local failed_count=0
    
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")
        local fullpath=$(realpath "$file")
        local relative_path=$(realpath --relative-to="$dir" "$file")
        
        log_info "印刷中: $relative_path"
        log_info "ファイルパス: $fullpath"
        
        # ファイルの存在確認
        if [ ! -f "$fullpath" ]; then
            log_error "ファイルが見つかりません: $fullpath"
            failed_count=$((failed_count + 1))
            continue
        fi
        
        # ファイルの読み取り権限確認
        if [ ! -r "$fullpath" ]; then
            log_error "ファイルの読み取り権限がありません: $fullpath"
            failed_count=$((failed_count + 1))
            continue
        fi
        
        # 印刷コマンド実行
        local print_success=false
        
        if command -v lpr >/dev/null 2>&1; then
            if [ -n "$printer_name" ]; then
                if lpr -P "$printer_name" "$fullpath" 2>/dev/null; then
                    print_success=true
                fi
            else
                if lpr "$fullpath" 2>/dev/null; then
                    print_success=true
                fi
            fi
        elif command -v lp >/dev/null 2>&1; then
            if [ -n "$printer_name" ]; then
                if lp -d "$printer_name" "$fullpath" 2>/dev/null; then
                    print_success=true
                fi
            else
                if lp "$fullpath" 2>/dev/null; then
                    print_success=true
                fi
            fi
        else
            log_error "印刷コマンド（lpr/lp）が見つかりません"
            return 1
        fi
        
        if [ "$print_success" = true ]; then
            log_success "印刷送信完了: $relative_path"
            count=$((count + 1))
        else
            log_error "印刷送信失敗: $relative_path"
            failed_count=$((failed_count + 1))
        fi
        
        # 印刷間隔を設けて負荷を軽減
        sleep 2
    done < <(find "$dir" -name "*.pdf" -type f -print0 | sort -z)
    
    echo ""
    log_success "印刷処理が完了しました"
    log_info "成功: $count 個のファイル"
    if [ $failed_count -gt 0 ]; then
        log_warning "失敗: $failed_count 個のファイル"
    fi
    
    # 印刷キューの状態を表示
    if command -v lpq >/dev/null 2>&1; then
        echo ""
        log_info "印刷キューの状態:"
        lpq -P "$printer_name" 2>/dev/null || lpq 2>/dev/null || echo "印刷キューの状態を取得できませんでした"
    fi
}

# Python依存関係のチェック
check_dependencies() {
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python3が見つかりません"
        echo "Python3をインストールしてください"
        return 1
    fi
    
    python3 -c "import PyPDF2" 2>/dev/null
    if [ $? -ne 0 ]; then
        log_warning "PyPDF2ライブラリが見つかりません"
        echo "以下のコマンドでインストールしてください:"
        echo "  pip install PyPDF2"
        echo ""
        echo "または、requirements.txtを使用してください:"
        echo "  pip install -r requirements.txt"
        return 1
    fi
    
    return 0
}

# requirements.txtの生成
generate_requirements() {
    cat > requirements.txt << 'EOF'
PyPDF2==3.0.1
reportlab==4.0.4
EOF
    log_success "requirements.txtを生成しました"
}

# 印刷システムのデバッグ
debug_print_system() {
    local dir="${1:-.}"
    
    log_info "印刷システムのデバッグ情報:"
    echo ""
    
    # OS情報
    log_info "OS情報:"
    echo "  - OS: $OSTYPE"
    echo "  - 現在のディレクトリ: $(pwd)"
    echo "  - 対象ディレクトリ: $dir"
    echo ""
    
    # 印刷コマンドの確認
    log_info "印刷コマンドの確認:"
    if command -v lpr >/dev/null 2>&1; then
        echo "  - lpr: ✅ 利用可能"
        echo "    パス: $(which lpr)"
    else
        echo "  - lpr: ❌ 利用不可"
    fi
    
    if command -v lp >/dev/null 2>&1; then
        echo "  - lp: ✅ 利用可能"
        echo "    パス: $(which lp)"
    else
        echo "  - lp: ❌ 利用不可"
    fi
    
    if command -v lpstat >/dev/null 2>&1; then
        echo "  - lpstat: ✅ 利用可能"
        echo "    パス: $(which lpstat)"
    else
        echo "  - lpstat: ❌ 利用不可"
    fi
    echo ""
    
    # プリンター情報の詳細
    log_info "プリンター情報の詳細:"
    if command -v lpstat >/dev/null 2>&1; then
        echo "  lpstat -p の結果:"
        lpstat -p 2>/dev/null | sed 's/^/    /' || echo "    エラー: プリンター情報を取得できません"
        echo ""
        echo "  lpstat -d の結果:"
        lpstat -d 2>/dev/null | sed 's/^/    /' || echo "    エラー: デフォルトプリンター情報を取得できません"
        echo ""
    fi
    
    if command -v lpoptions >/dev/null 2>&1; then
        echo "  lpoptions -p の結果:"
        lpoptions -p 2>/dev/null | sed 's/^/    /' || echo "    エラー: プリンターオプションを取得できません"
        echo ""
    fi
    
    # macOS固有の情報
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v system_profiler >/dev/null 2>&1; then
            echo "  system_profiler の結果:"
            system_profiler SPPrintersDataType 2>/dev/null | head -20 | sed 's/^/    /' || echo "    エラー: システム情報を取得できません"
            echo ""
        fi
    fi
    
    # PDFファイルの確認
    if [ -d "$dir" ]; then
        log_info "PDFファイルの確認:"
        local pdf_count=$(find "$dir" -name "*.pdf" -type f | wc -l)
        echo "  - PDFファイル数: $pdf_count"
        if [ "$pdf_count" -gt 0 ]; then
            echo "  - PDFファイル一覧:"
            find "$dir" -name "*.pdf" -type f | head -5 | while read -r file; do
                echo "    - $(basename "$file") ($(ls -lh "$file" | awk '{print $5}'))"
            done
            if [ "$pdf_count" -gt 5 ]; then
                echo "    ... 他 $((pdf_count - 5)) 個のファイル"
            fi
        fi
    else
        log_error "ディレクトリが存在しません: $dir"
    fi
    
    echo ""
    log_info "トラブルシューティングのヒント:"
    echo "  1. プリンターがシステムに追加されているか確認"
    echo "  2. プリンターの電源が入っているか確認"
    echo "  3. プリンターとの接続（USB/ネットワーク）を確認"
    echo "  4. システム設定 > プリンタとスキャナ で設定を確認"
    echo "  5. 手動テスト: lpr -P [プリンター名] [ファイルパス]"
}

# GUIでフォルダ選択
gui_select_folder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e 'tell application "System Events" to return POSIX path of (choose folder with prompt "PDFファイルが含まれるフォルダを選択してください")'
    else
        log_error "GUI機能は現在macOSでのみサポートされています"
        return 1
    fi
}

# GUIでプリンター選択
gui_select_printer() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # プリンター一覧を取得
        local printers=()
        if command -v lpstat >/dev/null 2>&1; then
            while IFS= read -r printer; do
                printers+=("$printer")
            done < <(lpstat -p 2>/dev/null | awk '/^printer/ {print $2}')
        fi
        
        # システムプリンターも取得
        if command -v system_profiler >/dev/null 2>&1; then
            while IFS= read -r printer; do
                printers+=("$printer")
            done < <(system_profiler SPPrintersDataType 2>/dev/null | grep -A1 "Printer Name:" | grep -v "Printer Name:" | sed 's/^[[:space:]]*//' | head -10)
        fi
        
        # 重複を削除
        local unique_printers=($(printf '%s\n' "${printers[@]}" | sort -u))
        
        if [ ${#unique_printers[@]} -eq 0 ]; then
            log_error "プリンターが見つかりません"
            return 1
        fi
        
        # AppleScriptでプリンター選択ダイアログを表示
        local printer_list=""
        for printer in "${unique_printers[@]}"; do
            if [ -z "$printer_list" ]; then
                printer_list="\"$printer\""
            else
                printer_list="$printer_list, \"$printer\""
            fi
        done
        
        osascript -e "tell application \"System Events\" to return (choose from list {$printer_list} with prompt \"印刷に使用するプリンターを選択してください\")"
    else
        log_error "GUI機能は現在macOSでのみサポートされています"
        return 1
    fi
}

# GUIで操作選択
gui_select_operation() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local operations=("\"一覧表示\"" "\"詳細情報\"" "\"テキスト抽出\"" "\"マージ\"" "\"フォルダ別マージ\"" "\"印刷\"")
        local operation_list=$(IFS=,; echo "${operations[*]}")
        
        osascript -e "tell application \"System Events\" to return (choose from list {$operation_list} with prompt \"実行する操作を選択してください\")"
    else
        log_error "GUI機能は現在macOSでのみサポートされています"
        return 1
    fi
}

# GUIで進行状況を表示
gui_show_progress() {
    local message="$1"
    local current="$2"
    local total="$3"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$message\" with title \"PDF Processor\" subtitle \"$current/$total\""
    fi
}

# GUIで結果を表示
gui_show_result() {
    local title="$1"
    local message="$2"
    local type="${3:-info}"  # info, warning, error
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local icon="note"
        case "$type" in
            "warning") icon="caution" ;;
            "error") icon="stop" ;;
        esac
        
        osascript -e "display dialog \"$message\" with title \"$title\" with icon $icon buttons {\"OK\"} default button \"OK\""
    fi
}

# GUIモードでPDF処理
gui_mode() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "GUI機能は現在macOSでのみサポートされています"
        return 1
    fi
    
    log_info "GUIモードを開始します..."
    
    # フォルダ選択
    local selected_folder
    selected_folder=$(gui_select_folder)
    
    if [ -z "$selected_folder" ] || [ "$selected_folder" = "false" ]; then
        log_info "フォルダ選択がキャンセルされました"
        return 0
    fi
    
    log_info "選択されたフォルダ: $selected_folder"
    
    # PDFファイルの存在確認
    if ! check_pdf_files "$selected_folder" "true"; then
        gui_show_result "エラー" "選択されたフォルダとサブフォルダにPDFファイルが見つかりません。" "error"
        return 1
    fi
    
    # 操作選択
    local selected_operation
    selected_operation=$(gui_select_operation)
    
    if [ -z "$selected_operation" ] || [ "$selected_operation" = "false" ]; then
        log_info "操作選択がキャンセルされました"
        return 0
    fi
    
    log_info "選択された操作: $selected_operation"
    
    # 操作実行
    case "$selected_operation" in
        "一覧表示")
            gui_show_result "PDF一覧" "処理を開始します..." "info"
            list_pdfs "$selected_folder"
            gui_show_result "完了" "PDF一覧表示が完了しました。詳細はターミナルを確認してください。" "info"
            ;;
        "詳細情報")
            gui_show_result "PDF詳細情報" "処理を開始します..." "info"
            show_pdf_info "$selected_folder"
            gui_show_result "完了" "PDF詳細情報の表示が完了しました。詳細はターミナルを確認してください。" "info"
            ;;
        "テキスト抽出")
            if ! check_dependencies; then
                gui_show_result "エラー" "PyPDF2ライブラリが必要です。pip install PyPDF2 を実行してください。" "error"
                return 1
            fi
            gui_show_result "テキスト抽出" "処理を開始します..." "info"
            extract_pdf_text "$selected_folder"
            gui_show_result "完了" "テキスト抽出が完了しました。extracted_textフォルダを確認してください。" "info"
            ;;
        "マージ")
            if ! check_dependencies; then
                gui_show_result "エラー" "PyPDF2ライブラリが必要です。pip install PyPDF2 を実行してください。" "error"
                return 1
            fi
            
            local output_file
            output_file=$(osascript -e 'tell application "System Events" to return text returned of (display dialog "出力ファイル名を入力してください（.pdf拡張子を含む）:" default answer "merged.pdf")')
            
            if [ -z "$output_file" ] || [ "$output_file" = "false" ]; then
                log_info "ファイル名入力がキャンセルされました"
                return 0
            fi
            
            # スキップオプションの選択
            local skip_option
            skip_option=$(osascript -e 'tell application "System Events" to return (choose from list {"既存ファイルに確認", "既存ファイルをスキップ", "既存ファイルを上書き"} with prompt "既存ファイルがある場合の処理を選択してください")')
            
            if [ -z "$skip_option" ] || [ "$skip_option" = "false" ]; then
                log_info "処理がキャンセルされました"
                return 0
            fi
            
            local skip_existing="false"
            case "$skip_option" in
                "既存ファイルをスキップ") skip_existing="true" ;;
                "既存ファイルを上書き") skip_existing="force" ;;
            esac
            
            gui_show_result "PDFマージ" "処理を開始します..." "info"
            merge_pdfs "$selected_folder" "$output_file" "$skip_existing"
            gui_show_result "完了" "PDFマージが完了しました。$output_file が作成されました。" "info"
            ;;
        "フォルダ別マージ")
            if ! check_dependencies; then
                gui_show_result "エラー" "PyPDF2ライブラリが必要です。pip install PyPDF2 を実行してください。" "error"
                return 1
            fi
            
            # スキップオプションの選択
            local skip_option
            skip_option=$(osascript -e 'tell application "System Events" to return (choose from list {"既存ファイルに確認", "既存ファイルをスキップ", "既存ファイルを上書き"} with prompt "既存ファイルがある場合の処理を選択してください")')
            
            if [ -z "$skip_option" ] || [ "$skip_option" = "false" ]; then
                log_info "処理がキャンセルされました"
                return 0
            fi
            
            local skip_existing="false"
            case "$skip_option" in
                "既存ファイルをスキップ") skip_existing="true" ;;
                "既存ファイルを上書き") skip_existing="force" ;;
            esac
            
            gui_show_result "フォルダ別PDFマージ" "処理を開始します..." "info"
            merge_pdfs_by_folder "$selected_folder" "$skip_existing"
            gui_show_result "完了" "フォルダ別PDFマージが完了しました。merged_by_folder フォルダを確認してください。" "info"
            ;;
        "印刷")
            # プリンター選択
            local selected_printer
            selected_printer=$(gui_select_printer)
            
            if [ -z "$selected_printer" ] || [ "$selected_printer" = "false" ]; then
                log_info "プリンター選択がキャンセルされました"
                return 0
            fi
            
            gui_show_result "印刷開始" "プリンター「$selected_printer」で印刷を開始します..." "info"
            
            # 印刷実行（GUI版）
            gui_print_pdfs "$selected_folder" "$selected_printer"
            ;;
        *)
            gui_show_result "エラー" "不明な操作が選択されました。" "error"
            return 1
            ;;
    esac
}

# GUI版PDF印刷
gui_print_pdfs() {
    local dir="$1"
    local printer_name="$2"
    
    local count=0
    local failed_count=0
    local total_files=$(find "$dir" -name "*.pdf" -type f | wc -l)
    
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")
        local fullpath=$(realpath "$file")
        
        count=$((count + 1))
        
        # 進行状況通知
        gui_show_progress "印刷中: $filename" "$count" "$total_files"
        
        # ファイルの存在確認
        if [ ! -f "$fullpath" ]; then
            failed_count=$((failed_count + 1))
            continue
        fi
        
        # 印刷実行
        local print_success=false
        if command -v lpr >/dev/null 2>&1; then
            if lpr -P "$printer_name" "$fullpath" 2>/dev/null; then
                print_success=true
            fi
        elif command -v lp >/dev/null 2>&1; then
            if lp -d "$printer_name" "$fullpath" 2>/dev/null; then
                print_success=true
            fi
        fi
        
        if [ "$print_success" = false ]; then
            failed_count=$((failed_count + 1))
        fi
        
        # 印刷間隔
        sleep 2
    done < <(find "$dir" -name "*.pdf" -type f -print0 | sort -z)
    
    # 結果表示
    local success_count=$((count - failed_count))
    local result_message="印刷処理が完了しました。\n成功: $success_count 個\n失敗: $failed_count 個"
    
    if [ $failed_count -eq 0 ]; then
        gui_show_result "印刷完了" "$result_message" "info"
    else
        gui_show_result "印刷完了（一部失敗）" "$result_message" "warning"
    fi
}

# 引数解析
parse_args() {
    local command=""
    local directory=""
    local output_file=""
    local skip_mode="ask"  # ask, skip, force
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-existing)
                skip_mode="skip"
                shift
                ;;
            --force)
                skip_mode="force"
                shift
                ;;
            list|info|extract|merge|merge-by-folder|print|gui|debug-print|deps|requirements|help|--help|-h)
                command="$1"
                shift
                ;;
            *)
                if [ -z "$directory" ]; then
                    directory="$1"
                elif [ -z "$output_file" ]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done
    
    echo "$command|$directory|$output_file|$skip_mode"
}

# メイン処理
main() {
    local parsed=$(parse_args "$@")
    IFS='|' read -r command directory output_file skip_mode <<< "$parsed"
    
    # デフォルト値設定
    directory="${directory:-.}"
    output_file="${output_file:-merged.pdf}"
    
    # スキップモードの変換
    local skip_existing="false"
    case "$skip_mode" in
        "skip") skip_existing="true" ;;
        "force") skip_existing="force" ;;
    esac
    
    case "$command" in
        "list")
            list_pdfs "$directory"
            ;;
        "info")
            show_pdf_info "$directory"
            ;;
        "extract")
            if check_dependencies; then
                extract_pdf_text "$directory"
            fi
            ;;
        "merge")
            if check_dependencies; then
                merge_pdfs "$directory" "$output_file" "$skip_existing"
            fi
            ;;
        "merge-by-folder")
            if check_dependencies; then
                merge_pdfs_by_folder "$directory" "$skip_existing"
            fi
            ;;
        "print")
            print_pdfs "$directory"
            ;;
        "gui")
            gui_mode
            ;;
        "debug-print")
            debug_print_system "$directory"
            ;;
        "deps")
            check_dependencies
            ;;
        "requirements")
            generate_requirements
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            log_error "不明なコマンド: $command"
            show_help
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"