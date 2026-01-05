# Nix ルール

## nix build

- YOU MUST: `nix build` は必ず `--no-link` オプションを付ける

    ```sh
    nix build .#rumdl --no-link
    ```

- IMPORTANT: `--no-link` を付けないと `./result` シンボリックリンクが作成される

## nix run

- IMPORTANT: packages に登録されているパッケージは `nix run` で実行できる

    ```sh
    nix run .#pike -- scan -d ./terraform
    ```

## カスタムパッケージの追加

- YOU MUST: 新しいカスタムパッケージを追加する手順は README.md の 7.4.2 を参照
- IMPORTANT: ハッシュ取得の流れ
    1. 空ハッシュ (`hash = "";`) で .nix ファイルを作成
    2. `git add` してから `nix build --no-link` を実行
    3. エラーメッセージの `got:` からハッシュをコピー
    4. Go は `vendorHash`、Rust は `cargoHash` も同様に取得
- IMPORTANT: テストが失敗する場合は `doCheck = false;` を追加する
