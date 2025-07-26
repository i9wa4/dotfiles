#!/usr/bin/env bash
set -o errexit

# JupyterLab起動スクリプト
# Databricks Connect環境での快適な開発用

echo "🔥 Databricks JupyterLab 環境を起動中..."

# ポート設定（環境変数または自動割り当て）
# JUPYTER_PORT=8888 # NOTE: この行をコメントアウトすると自動ポート検索が有効になります
JUPYTER_PORT=${JUPYTER_PORT:-0}

if [ "$JUPYTER_PORT" = "0" ]; then
  echo "📡 利用可能なポートを自動検索中..."
else
  echo "📡 指定ポート ${JUPYTER_PORT} で起動します"
fi

# Python環境の確認
if [ -f "uv.lock" ]; then
  echo "📦 uv環境を使用してJupyterLabを起動します"
  uv sync --frozen
  nohup uv run jupyter lab --ip=0.0.0.0 --port=${JUPYTER_PORT} --no-browser --allow-root \
    --NotebookApp.token='' --NotebookApp.password='' \
    --ServerApp.allow_origin='*' --ServerApp.disable_check_xsrf=True >/dev/null 2>&1 &
elif [ -d ".venv" ]; then
  echo "📦 venv環境を使用してJupyterLabを起動します"
  source .venv/bin/activate
  nohup jupyter lab --ip=0.0.0.0 --port=${JUPYTER_PORT} --no-browser --allow-root \
    --NotebookApp.token='' --NotebookApp.password='' \
    --ServerApp.allow_origin='*' --ServerApp.disable_check_xsrf=True >/dev/null 2>&1 &
else
  echo "❌ Python仮想環境が見つかりません"
  echo "uvまたはvenvで環境をセットアップしてください"
  exit 1
fi

# 実際に割り当てられたポートを取得（リトライ機能付き）
for i in {1..10}; do
  sleep 1
  ACTUAL_PORT=$(ss -tlnp 2>/dev/null | grep jupyter-lab | awk '{print $4}' | cut -d: -f2 | head -1)
  if [ -n "$ACTUAL_PORT" ]; then
    break
  fi
done

if [ "$JUPYTER_PORT" = "0" ] && [ -n "$ACTUAL_PORT" ]; then
  echo "🌐 JupyterLabは http://localhost:${ACTUAL_PORT}/lab でアクセス可能です"
else
  echo "🌐 JupyterLabは http://localhost:${JUPYTER_PORT}/lab でアクセス可能です"
fi
