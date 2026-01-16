---
title: "Layer setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/layer-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Layer setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Flayer-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Flayer-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Flayer-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: Layer* **Authors**: Mehmet Ecevit* **GitHub repo**: [layerai/dbt-layer](https://github.com/layerai/dbt-layer) [![](https://img.shields.io/github/stars/layerai/dbt-layer?style=for-the-badge)](https://github.com/layerai/dbt-layer)* **PyPI package**: `dbt-layer-bigquery` [![](https://badge.fury.io/py/dbt-layer-bigquery.svg)](https://badge.fury.io/py/dbt-layer-bigquery)* **Slack channel**: [#tools-layer](https://getdbt.slack.com/archives/C03STA39TFE)* **Supported dbt Core version**: v1.0.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-layer-bigquery

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-layer-bigquery`

## Configuring dbt-layer-bigquery

For Layer-specific configuration, please refer to [Layer configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

### Profile Configuration[​](#profile-configuration "Direct link to Profile Configuration")

Layer Bigquery targets should be set up using the following sections in your `profiles.yml` file.

#### Layer Authentication[​](#layer-authentication "Direct link to Layer Authentication")

Add your `layer_api_key` to your `profiles.yaml` to authenticate with Layer. To get your Layer API Key:

* First, [create your free Layer account](https://app.layer.ai/login?returnTo=%2Fgetting-started).
* Go to [app.layer.ai](https://app.layer.ai) > **Settings** (Cog Icon by your profile photo) > **Developer** > **Create API key** to get your Layer API Key.

#### Bigquery Authentication[​](#bigquery-authentication "Direct link to Bigquery Authentication")

You can use any [authentication method](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup) supported in the official dbt Bigquery adapter since Layer uses `dbt-bigquery` adapter to connect to your Bigquery instance.

A sample profile:

profiles.yml

```
layer-profile:
  target: dev
  outputs:
    dev:
      # Layer authentication
      type: layer_bigquery
      layer_api_key: [the API Key to access your Layer account (opt)]
      # Bigquery authentication
      method: service-account
      project: [GCP project id]
      dataset: [the name of your dbt dataset]
      threads: [1 or more]
      keyfile: [/path/to/bigquery/keyfile.json]
```

#### Description of Layer Bigquery Profile Fields[​](#description-of-layer-bigquery-profile-fields "Direct link to Description of Layer Bigquery Profile Fields")

The following fields are required:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Default Type Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` string Specifies the adapter you want to use. It should be `layer_bigquery`.| `layer_api_key` string (opt) Specifies your Layer API key. If you want to make predictions with public ML models from Layer, you don't need to have this key in your profile. It's required if you load ML models from your Layer account or train an AutoML model.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `layer_project` string (opt) Specifies your target Layer project. If you don't specify, Layer will use the project same name with your dbt project.|  |  |  |  | | --- | --- | --- | --- | | `method` string Specifies the authentication type to connect to your BigQuery. | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Rest of the parameters depends on the BigQuery authentication method you specified.

## Usage[​](#usage "Direct link to Usage")

### AutoML[​](#automl "Direct link to AutoML")

You can automatically build state-of-art ML models using your own dbt models with plain SQL. To train an AutoML model all you have to do is pass your model type, input data (features) and target column you want to predict to `layer.automl()` in your SQL. The Layer AutoML will pick the best performing model and enable you to call it by its dbt model name to make predictions as shown above.

*Syntax:*

```
layer.automl("MODEL_TYPE", ARRAY[FEATURES], TARGET)
```

*Parameters:*

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Syntax Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `MODEL_TYPE` Type of the model your want to train. There are two options:   - `classifier`: A model to predict classes/labels or categories such as spam detection - `regressor`: A model to predict continuous outcomes such as CLV prediction.| `FEATURES` Input column names as a list to train your AutoML model.|  |  | | --- | --- | | `TARGET` Target column that you want to predict. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

*Requirements:*

* You need to put `layer_api_key` to your dbt profile to make AutoML work.

*Example:*

Check out [Order Review AutoML Project](https://github.com/layerai/dbt-layer/tree/mecevit/update-docs/examples/order_review_prediction):

```
SELECT order_id,
       layer.automl(
           -- This is a regression problem
           'regressor',
           -- Data (input features) to train our model
           ARRAY[
           days_between_purchase_and_delivery, order_approved_late,
           actual_delivery_vs_expectation_bucket, total_order_price, total_order_freight, is_multiItems_order,seller_shipped_late],
           -- Target column we want to predict
           review_score
       )
FROM {{ ref('training_data') }}
```

### Prediction[​](#prediction "Direct link to Prediction")

You can make predictions using any Layer ML model within your dbt models. Layer dbt Adapter helps you score your data resides on your warehouse within your dbt DAG with SQL.

*Syntax:*

```
layer.predict("LAYER_MODEL_PATH", ARRAY[FEATURES])
```

*Parameters:*

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Syntax Description|  |  |  |  | | --- | --- | --- | --- | | `LAYER_MODEL_PATH` This is the Layer model path in form of `/[organization_name]/[project_name]/models/[model_name]`. You can use only the model name if you want to use an AutoML model within the same dbt project.| `FEATURES` These are the columns that this model requires to make a prediction. You should pass the columns as a list like `ARRAY[column1, column2, column3]`. | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

*Example:*

Check out [Cloth Detection Project](https://github.com/layerai/dbt-layer/tree/mecevit/update-docs/examples/cloth_detector):

```
SELECT
    id,
    layer.predict("layer/clothing/models/objectdetection", ARRAY[image])
FROM
    {{ ref("products") }}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

iomete setup](https://docs.getdbt.com/docs/core/connect-data-platform/iomete-setup)[Next

Materialize setup](https://docs.getdbt.com/docs/core/connect-data-platform/materialize-setup)

* [Profile Configuration](#profile-configuration)* [Usage](#usage)
    + [AutoML](#automl)+ [Prediction](#prediction)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/layer-setup.md)
