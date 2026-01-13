---
source_url: https://docs.databricks.com/en/machine-learning/
fetched_at: 2025-12-16
---

# 機械学習基盤

## 概要

Databricks は Mosaic AI を通じて、データ準備から本番監視までの AI ライフサイクル全体を統合プラットフォームで提供。

## MLflow

### 概要

実験追跡とモデル管理の中核ツール。開発プロセス全体を通じて実験追跡、モデル比較、ライフサイクル管理を実現。

### 主な機能

- 実験追跡: パラメータ、メトリクス、アーティファクトの記録
- モデルレジストリ: モデルのバージョン管理と本番化
- モデルサービング: REST API としてのモデルデプロイ

### 基本的な使い方

```python
import mlflow

# 実験の開始
with mlflow.start_run():
    # パラメータの記録
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_param("epochs", 100)

    # メトリクスの記録
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_metric("loss", 0.05)

    # モデルの保存
    mlflow.sklearn.log_model(model, "model")
```

### GenAI 向け機能

- LLM 評価機能
- プロンプトエンジニアリング支援
- 品質向上と監視

## Feature Store

### 概要

特徴量管理システムで、自動データパイプラインと特徴量発見を実現。

### 主な機能

- 特徴量の一元管理
- 特徴量の再利用促進
- オンライン/オフラインサービング
- 時点ルックアップ（Point-in-time lookups）

### ベストプラクティス

- 特徴量テーブルは Unity Catalog で管理
- 特徴量の説明とタグを適切に設定
- 特徴量の鮮度要件を明確化

## モデルサービング

### 概要

カスタムモデルと LLM を REST エンドポイントとしてデプロイ。自動スケーリングと GPU サポートを提供。

### エンドポイントタイプ

- CPU エンドポイント: 一般的なモデル向け
- GPU エンドポイント: 深層学習モデル向け
- Foundation Model APIs: 外部 LLM へのアクセス

### スケーリング設定

```python
# エンドポイント設定例
endpoint_config = {
    "served_models": [{
        "model_name": "my_model",
        "model_version": "1",
        "workload_size": "Small",
        "scale_to_zero_enabled": True
    }]
}
```

## 深層学習

### サポートフレームワーク

- PyTorch
- TensorFlow
- Hugging Face Transformers

### 分散学習

- Horovod: データ並列分散学習
- DeepSpeed: 大規模モデル学習
- Ray: 分散コンピューティング

### ベストプラクティス

- 適切なクラスタサイズの選択
- チェックポイントの活用
- 早期停止の設定
- ハイパーパラメータチューニングの自動化
