---
name: draw-io
description: draw.io 図の作成・編集・レビューを行う。.drawio ファイルの XML 編集、PNG 変換、レイアウト調整、AWS アイコン使用時に使用する。
---

# draw.io 図作成スキル

## 1. 基本ルール

- `.drawio` ファイルのみを編集する
- `.drawio.png` ファイルを直接編集しない
- pre-commit hook により自動生成される `.drawio.png` をスライド等で利用する

## 2. フォント設定

Quarto スライドで使用する図は、mxGraphModel タグに `defaultFontFamily` を指定する

```xml
<mxGraphModel defaultFontFamily="Noto Sans JP" ...>
```

各テキスト要素の style 属性にも明示的に `fontFamily` を指定する

```xml
style="text;html=1;fontSize=27;fontFamily=Noto Sans JP;"
```

## 3. 変換コマンド

変換スクリプトは [scripts/convert-drawio-to-png.sh](scripts/convert-drawio-to-png.sh) を参照。

```sh
# 全ての .drawio ファイルを変換
mise exec -- pre-commit run --all-files

# 特定の .drawio ファイルのみ変換
mise exec -- pre-commit run convert-drawio-to-png --files assets/my-diagram.drawio

# スクリプトを直接実行 (スキルのスクリプトを使用)
bash ~/.claude/skills/draw-io/scripts/convert-drawio-to-png.sh assets/diagram1.drawio
```

内部で使用されるコマンド

```sh
drawio -x -f png -s 2 -t -o output.drawio.png input.drawio
```

| オプション | 説明 |
|-----------|------|
| `-x` | エクスポートモード |
| `-f png` | PNG フォーマットで出力 |
| `-s 2` | 2倍スケール (高解像度) |
| `-t` | 透明背景 |
| `-o` | 出力ファイルパス |

## 4. レイアウト調整

### 4.1. 座標調整の手順

1. `.drawio` ファイルをテキストエディタで開く (プレーンな XML 形式)
2. 調整したい要素の `mxCell` を探す (`value` 属性でテキストを検索)
3. `mxGeometry` タグの座標を調整
    - `x`: 左からの位置
    - `y`: 上からの位置
    - `width`: 幅
    - `height`: 高さ
4. 変換を実行して確認

### 4.2. 座標計算

- 要素の中心座標 = `y + (height / 2)`
- 複数要素を揃える場合は中心座標を計算して合わせる

## 5. デザイン原則

### 5.1. 基本原則

- 明確さ: シンプルで視覚的にクリーンな図を作成
- 一貫性: 色、フォント、アイコンサイズ、線の太さを統一
- 正確さ: 簡略化のために正確性を犠牲にしない

### 5.2. 構成要素のルール

- すべての要素にラベルを付ける
- 方向を示す矢印を使用 (双方向より2本の単方向矢印を推奨)
- 公式アイコンの最新版を使用
- 凡例を追加してカスタム記号を説明

### 5.3. アクセシビリティ

- 十分な色のコントラストを確保
- 色だけでなくパターンも併用

### 5.4. プログレッシブディスクロージャー

複雑なシステムは段階的に図を分ける

| 図の種類 | 目的 |
|----------|------|
| コンテキスト図 | システムを外部から見た全体像 |
| システム図 | 主要コンポーネントとその関係 |
| コンポーネント図 | 技術詳細と統合ポイント |
| デプロイ図 | インフラストラクチャ構成 |
| データフロー図 | データの流れと変換 |
| シーケンス図 | 時系列の相互作用 |

### 5.5. メタデータ

図にはタイトル、説明、最終更新日、作成者、バージョンを記載する。

## 6. ベストプラクティス

### 6.1. 背景色

- `background="#ffffff"` は削除すること
- 透明背景にすることで、様々なテーマに対応できる

### 6.2. フォントサイズ

- PDF 表示で読みやすくするため、標準フォントサイズの 1.5 倍 (18px 程度) を使用

### 6.3. 日本語テキスト幅

- 1 文字あたり 30〜40px を確保
- 不足すると意図しない改行が発生する

```xml
<!-- 10文字のテキストなら 300〜400px を確保 -->
<mxGeometry x="140" y="60" width="400" height="40" />
```

### 6.4. 矢印配置

- 矢印は必ず最背面に配置 (XML で Title の直後に配置)
- 矢印がラベルと被らないように配置
- 矢印の起点・終点はラベルの下辺から最低 20px 以上離す

```xml
<!-- Title -->
<mxCell id="title" value="..." .../>

<!-- Arrows (最背面) -->
<mxCell id="arrow1" style="edgeStyle=..." .../>

<!-- Other elements (前面に表示される) -->
<mxCell id="box1" .../>
```

### 6.5. テキストラベルへの矢印接続

テキスト要素への接続は `exitX/exitY` が効かないため、明示的な座標を使用する

```xml
<!-- 良い例: sourcePoint/targetPoint で明示的に座標を指定 -->
<mxCell id="arrow" style="..." edge="1" parent="1">
  <mxGeometry relative="1" as="geometry">
    <mxPoint x="1279" y="500" as="sourcePoint"/>
    <mxPoint x="119" y="500" as="targetPoint"/>
    <Array as="points">
      <mxPoint x="1279" y="560"/>
      <mxPoint x="119" y="560"/>
    </Array>
  </mxGeometry>
</mxCell>
```

### 6.6. edgeLabel の offset 調整

矢印ラベルを矢印から離すには、offset 属性を調整する

```xml
<!-- 矢印の上側に配置 (マイナス値で離す) -->
<mxPoint x="0" y="-40" as="offset"/>

<!-- 矢印の下側に配置 (プラス値で離す) -->
<mxPoint x="0" y="40" as="offset"/>
```

### 6.7. 不要な要素の削除

- 文脈に不要な装飾アイコンは削除
- 例: ECR があれば、別途 Docker アイコンは不要

### 6.8. ラベルと見出し

- サービス名のみ: 1 行
- サービス名 + 補足情報: 改行して 2 行
- 冗長な表記 (例: ECR Container Registry): 短縮して 1 行
- 改行には `&lt;br&gt;` タグを使用

## 7. リファレンス

- [レイアウトガイドライン](references/layout-guidelines.md)
- [AWS アイコン](references/aws-icons.md)
- [AWS アイコン検索スクリプト](scripts/find_aws_icon.py)

AWS アイコン検索例

```sh
python ~/.claude/skills/draw-io/scripts/find_aws_icon.py ec2
python ~/.claude/skills/draw-io/scripts/find_aws_icon.py lambda
```

## 8. チェックリスト

- [ ] 背景色が設定されていないか (page="0" であること)
- [ ] フォントサイズは適切か (大きめ推奨)
- [ ] 矢印が最背面に配置されているか
- [ ] 矢印がラベルと被っていないか (PNG で確認)
- [ ] 矢印の起点・終点がラベルから十分離れているか (最低 20px 以上)
- [ ] 矢印が他のボックスやアイコンを貫通していないか (PNG で確認)
- [ ] AWS サービス名が正式名称・正しい略称になっているか
- [ ] AWS アイコンが最新版 (mxgraph.aws4.*) か
- [ ] 不要な要素が残っていないか
- [ ] PNG に変換して視覚的に確認したか

## 9. reveal.js スライドでの画像表示

YAML ヘッダーに `auto-stretch: false` を追加する

```yaml
---
title: "Your Presentation"
format:
  revealjs:
    auto-stretch: false
---
```

これにより、スマホでも画像が正しく表示される
