# PDF Processor

フォルダ内のPDFファイルを一括処理するツール

## 機能

- **フォルダ内のPDFファイルを一覧表示**（サブフォルダも含む）
- **PDFファイルの基本情報表示**（ページ数、サイズ等）
- **PDFファイルのテキスト抽出**（サブフォルダ構造を保持）
- **PDFファイルのマージ**（サブフォルダのPDFも全て含む）
- **サブフォルダごとのPDFマージ**（各フォルダ単位で個別にマージ）
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

# サブフォルダごとにPDFをマージ
./pdf-processor.sh merge-by-folder [directory]

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
2. **操作選択** - 実行する操作を選択（一覧表示、詳細情報、テキスト抽出、マージ、**フォルダ別マージ**、印刷）
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

## 使用例

### サブフォルダごとのマージ

```
documents/
├── 2023/
│   ├── report1.pdf
│   └── report2.pdf
├── 2024/
│   ├── summary.pdf
│   └── analysis.pdf
└── misc.pdf
```

上記のような構造で `merge-by-folder` を実行すると：

```
documents/merged_by_folder/
├── merged_root.pdf         # misc.pdf
├── merged_2023.pdf         # report1.pdf + report2.pdf
└── merged_2024.pdf         # summary.pdf + analysis.pdf
```

各フォルダ単位でPDFファイルがマージされます。

### スキップオプション

既存ファイルがある場合の処理を指定できます：

```bash
# 既存ファイルをスキップ（上書きしない）
./pdf-processor.sh merge-by-folder ./documents --skip-existing

# 既存ファイルを強制上書き
./pdf-processor.sh merge-by-folder ./documents --force

# 既存ファイルがある場合は確認（デフォルト）
./pdf-processor.sh merge-by-folder ./documents
```

**GUIモード**では、処理開始時にスキップオプションを選択できます。