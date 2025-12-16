---
name: jupyter-notebook
description: Jupyter Notebook エキスパートスキル - ノートブックの実行方法、Databricks カーネル連携に関するガイドを提供
---

# Jupyter Notebook Expert Skill

このスキルは Jupyter Notebook の実行に関するガイドを提供する。

## 1. Databricks 向け Jupyter Kernel

<https://github.com/i9wa4/jupyter-databricks-kernel>

```bash
# With uv
uv pip install jupyter-databricks-kernel
uv run python -m jupyter_databricks_kernel.install

# With pip
pip install jupyter-databricks-kernel
python -m jupyter_databricks_kernel.install
```

## 2. デフォルトの実行方法

Notebook 全体を実行する指示を受けた際は、以下のコマンドを使用する

```sh
uv run jupyter execute <notebook_path> --inplace --timeout=300
```

## 3. Databricks カーネルで実行

Databricks クラスタでノートブックを実行する場合

```sh
uv run jupyter execute <notebook_path> --inplace --kernel_name=databricks --timeout=300
```

必要な環境変数

- `DATABRICKS_HOST`: Databricks ワークスペースの URL
- `DATABRICKS_TOKEN`: Personal Access Token
- `DATABRICKS_CLUSTER_ID`: クラスタ ID

## 4. 使用例

```bash
# ローカルの Python カーネルで実行
uv run jupyter execute /workspace/notebooks/sample.ipynb --inplace --timeout=300

# Databricks カーネルで実行
uv run jupyter execute /workspace/notebooks/databricks-sample.ipynb --inplace --kernel_name=databricks --timeout=300
```

## 5. オプション説明

- `--inplace`: 元のファイルに実行結果を上書き
- `--kernel_name=<name>`: 使用するカーネルを指定 (databricks, python3 等)
- `--timeout=<seconds>`: タイムアウトを秒数で設定 (-1 で無制限)
- `--startup_timeout=<seconds>`: カーネル起動のタイムアウト (デフォルト 60 秒)
- `--allow-errors`: エラーがあっても最後まで実行を継続

## 6. 注意事項

- 実行前に必要な環境変数が適切に設定されていることを確認する
- 長時間実行されるセルがある場合は `--timeout` の値を調整する
- VS Code で開いている場合は実行後にファイルの更新を確認する
- Databricks カーネルの場合、クラスタが停止していると起動に 5-6 分かかる

## 7. 参考リンク

- jupyter-databricks-kernel: https://github.com/i9wa4/jupyter-databricks-kernel
- Jupyter nbclient: https://nbclient.readthedocs.io/
