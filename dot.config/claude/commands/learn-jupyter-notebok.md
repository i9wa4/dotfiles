---
description: "Learn Jupyter Notebook"
---

# learn-jupyter-notebook

Jupyter Notebook について学ぼう！

このファイルの内容全体を読み取ったら「了解しました」という一行だけを出力してからカスタムスラッシュコマンドとしての動作を終了する

## 1. デフォルトの実行方法

Notebook全体を実行する指示を受けた際は、以下のコマンドを使用する

```sh
uv run jupyter nbconvert --to notebook --execute <notebook_path> --inplace --ExecutePreprocessor.timeout=300
```

## 2. 使用例

```bash
# databricks-connect-sample.ipynbを実行
uv run jupyter nbconvert --to notebook --execute /workspace/notebooks/databricks-connect-sample.ipynb --inplace --ExecutePreprocessor.timeout=300
```

## 3. オプション説明

- `--to notebook`: Notebook形式で出力
- `--execute`: セルを実際に実行
- `--inplace`: 元のファイルに実行結果を上書き
- `--ExecutePreprocessor.timeout=300`: タイムアウトを300秒に設定

## 4. 実行ログの確認

実行時のログを確認したい場合は以下のように実行する

```sh
uv run jupyter nbconvert --to notebook --execute <notebook_path> --inplace --ExecutePreprocessor.timeout=300 2>&1 | tee /tmp/notebook_execution.log
```

## 5. 注意事項

- 実行前に必要な環境変数（`.env`ファイル等）が適切に設定されていることを確認する
- 長時間実行されるセルがある場合は`--ExecutePreprocessor.timeout`の値を調整する
- VS Codeで開いている場合は実行後にファイルの更新を確認する
