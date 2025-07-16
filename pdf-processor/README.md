# PDF Processor

フォルダ内のPDFファイルを一括処理するツール

## 機能

- **フォルダ内のPDFファイルを一覧表示**（サブフォルダも含む）
- **PDFファイルの基本情報表示**（ページ数、サイズ等）
- **PDFファイルのテキスト抽出**（サブフォルダ構造を保持）
- **PDFファイルのマージ**（サブフォルダのPDFも全て含む）
- **PDFファイルの一括印刷**（サブフォルダも含む）

## 使用方法

```bash
# フォルダ内のPDFファイルを一覧表示
./pdf-processor.sh list [directory]

# PDFファイルの基本情報を表示
./pdf-processor.sh info [directory]

# PDFファイルのテキストを抽出
./pdf-processor.sh extract [directory]

# PDFファイルをマージ
./pdf-processor.sh merge [directory] [output.pdf]

# PDFファイルを一括印刷
./pdf-processor.sh print [directory]

# GUIモードで実行
./pdf-processor.sh gui

# ヘルプを表示
./pdf-processor.sh help
```

## GUI機能

**macOSでのみサポート**

GUIモードでは以下の機能をダイアログで選択できます：

1. **フォルダ選択** - Finderでフォルダを選択
2. **操作選択** - 実行する操作を選択
3. **プリンター選択** - 印刷時にプリンターを選択  
4. **進行状況通知** - 処理の進行状況を通知
5. **結果表示** - 処理結果をダイアログで表示

```bash
./pdf-processor.sh gui
```

## 要件

- Python 3.7以上
- PyPDF2ライブラリ
- reportlabライブラリ（オプション）
- macOS（GUI機能使用時）