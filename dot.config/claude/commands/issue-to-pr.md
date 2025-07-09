---
description: "Issue to PR (arg: Issue number)"
---

# issue-to-pr

GitHub の issue から作業用ファイルを作成するカスタムコマンド

## 1. 前提条件

- `worktree-create <issue番号>` で作業用worktreeが作成済みであること
- 対象のworktreeディレクトリにいること

## 2. 使い方

```
/issue-to-pr <issue番号>
```

## 3. 処理フロー

1. 既存の作業再開か新規作業かを判定
2. 指定されたissue番号の内容を取得
3. PRテンプレートがあれば読み込み
4. `.i9wa4/pr.md`に統合形式（PR本文 + 作業ログ）で作成
   - PR本文エリア（GitHubテンプレート準拠）
   - 作業ログエリア（詳細な実装記録）
5. **実際のPR作成は手動で行う**

## 4. 実行内容

```bash
# 1. 既存のpr.mdがある場合は作業再開モード
if [ -f .i9wa4/pr.md ]; then
    echo "既存のpr.mdを検出しました。作業を再開します。"

    # 現在のブランチ名を取得
    CURRENT_BRANCH=$(git branch --show-current)
    echo "現在のブランチ: $CURRENT_BRANCH"

    # 最近のコミット履歴を表示
    echo -e "\n最近のコミット履歴:"
    git --no-pager log --oneline -10

    # 作業状態を表示
    echo -e "\n現在の作業状態:"
    git --no-pager status --short

    # pr.mdの内容を表示
    echo -e "\n=== 現在のpr.md ==="
    cat .i9wa4/pr.md

    exit 0
fi

# 2. 新規作成モード
ISSUE_NUMBER="{{ISSUE_NUMBER}}"

# issue内容を取得
echo "Issue情報を取得中..."
ISSUE_DATA=$(gh issue view "$ISSUE_NUMBER" --json title,body,number,assignees,labels 2>/dev/null)

if [ $? -eq 0 ]; then
    ISSUE_TITLE=$(echo "$ISSUE_DATA" | jq -r '.title')
    ISSUE_BODY=$(echo "$ISSUE_DATA" | jq -r '.body // ""')
    echo "✓ Issue情報を取得しました"
    echo "タイトル: ${ISSUE_TITLE}"
else
    echo "⚠ Issue情報の取得に失敗しました（手動で設定してください）"
    ISSUE_TITLE="Issue #${ISSUE_NUMBER}"
    ISSUE_BODY=""
fi

# 3. PRテンプレートを確認
PR_TEMPLATE=""
if [ -f .github/pull_request_template.md ]; then
    PR_TEMPLATE=".github/pull_request_template.md"
    echo "✓ PRテンプレートを発見: ${PR_TEMPLATE}"
elif [ -f .github/PULL_REQUEST_TEMPLATE.md ]; then
    PR_TEMPLATE=".github/PULL_REQUEST_TEMPLATE.md"
    echo "✓ PRテンプレートを発見: ${PR_TEMPLATE}"
elif [ -f docs/pull_request_template.md ]; then
    PR_TEMPLATE="docs/pull_request_template.md"
    echo "✓ PRテンプレートを発見: ${PR_TEMPLATE}"
else
    echo "PRテンプレートが見つかりませんでした"
fi

# 4. 統合形式のpr.mdを作成
echo "統合形式の作業ファイルを作成中..."

cat > .i9wa4/pr.md << EOF
# PR: ${ISSUE_TITLE}

<!-- ===== PR本文エリア（ここまでをPR作成時にコピー） ===== -->

## 関連Issue

* Closes #${ISSUE_NUMBER}

## 概要

* ${ISSUE_TITLE}の対応
$(if [ -n "$ISSUE_BODY" ]; then echo "* $ISSUE_BODY"; fi)

## やったこと

* 作業完了後に記載

## やらないこと

* 無し（あれば記載）

## 動作確認

* 作業完了後に記載

## 特に確認してほしい箇所

* 作業完了後に記載

## その他

* 実装詳細は下記の作業ログを参照

<!-- ===== 作業ログエリア（ここから下は内部用） ===== -->

---

## 対応ロードマップ

- [ ] 調査・分析
- [ ] 実装
- [ ] テスト
- [ ] ドキュメント更新

## テストファイル

<details>
<summary>📋 テストファイルテンプレート</summary>

- ファイル名: `.i9wa4/test_\${ISSUE_NUMBER}.py`
- 以下の内容でテストファイルを作成可能

\`\`\`python
#!/usr/bin/env python3
\"\"\"
Issue #\${ISSUE_NUMBER} のテストファイル
\${ISSUE_TITLE}
\"\"\"

import os
import sys
import unittest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, timezone

# パスを調整してmain scriptをimport
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# TODO: テスト対象の関数をimportまたは定義


class Test\${ISSUE_NUMBER}(unittest.TestCase):
    \"\"\"Issue #\${ISSUE_NUMBER} のテストクラス\"\"\"

    def setUp(self):
        \"\"\"テストセットアップ\"\"\"
        pass

    def test_basic_functionality(self):
        \"\"\"基本機能のテスト\"\"\"
        # TODO: テストケースを実装
        self.assertTrue(True)

    def test_error_handling(self):
        \"\"\"エラーハンドリングのテスト\"\"\"
        # TODO: エラーケースのテスト実装
        pass


def run_tests():
    \"\"\"テスト実行関数\"\"\"
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    suite.addTests(loader.loadTestsFromTestCase(Test\${ISSUE_NUMBER}))

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    print(f\"\\n{'='*60}\")
    print(f\"テスト結果: {result.testsRun}件実行, {len(result.failures)}件失敗, {len(result.errors)}件エラー\")
    print(f\"{'='*60}\")

    return result.wasSuccessful()


if __name__ == \"__main__\":
    print(\"Issue #\${ISSUE_NUMBER} のテスト実行\")
    print(\"=\" * 60)
    success = run_tests()

    if success:
        print(\"\\n✅ すべてのテストが正常に完了しました\")
        sys.exit(0)
    else:
        print(\"\\n❌ テストが失敗しました\")
        sys.exit(1)
\`\`\`

</details>

## 調査結果

<!-- 調査した内容を記載 -->

## 技術詳細

<!-- 実装の技術的な詳細を記載 -->

## 作業ログ

<!-- 日付とともに作業内容を記載 -->

### $(date +%Y-%m-%d)

- 作業開始

## 達成状況

- [ ] issue要件を満たしている
- [ ] テストが通る
- [ ] レビュー準備完了

---
*このファイルはコンテキストウインドウを超えた作業でも参照できるように作成されています*
EOF

echo "✓ 統合形式のpr.mdを作成しました: .i9wa4/pr.md"

# 5. テストファイルのテンプレートを作成
TEST_FILE=".i9wa4/test_${ISSUE_NUMBER}.py"
if [ ! -f "$TEST_FILE" ]; then
    echo "テストファイルのテンプレートを作成中..."

    cat > "$TEST_FILE" << 'TESTEOF'
#!/usr/bin/env python3
"""
Issue #${ISSUE_NUMBER} のテストファイル
${ISSUE_TITLE}
"""

import os
import sys
import unittest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, timezone

# パスを調整してmain scriptをimport
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# TODO: テスト対象の関数をimportまたは定義


class Test${ISSUE_NUMBER}(unittest.TestCase):
    """Issue #${ISSUE_NUMBER} のテストクラス"""

    def setUp(self):
        """テストセットアップ"""
        pass

    def test_basic_functionality(self):
        """基本機能のテスト"""
        # TODO: テストケースを実装
        self.assertTrue(True)

    def test_error_handling(self):
        """エラーハンドリングのテスト"""
        # TODO: エラーケースのテスト実装
        pass


def run_tests():
    """テスト実行関数"""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    suite.addTests(loader.loadTestsFromTestCase(Test${ISSUE_NUMBER}))

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    print(f"\n{'='*60}")
    print(f"テスト結果: {result.testsRun}件実行, {len(result.failures)}件失敗, {len(result.errors)}件エラー")
    print(f"{'='*60}")

    return result.wasSuccessful()


if __name__ == "__main__":
    print("Issue #${ISSUE_NUMBER} のテスト実行")
    print("=" * 60)
    success = run_tests()

    if success:
        print("\n✅ すべてのテストが正常に完了しました")
        sys.exit(0)
    else:
        print("\n❌ テストが失敗しました")
        sys.exit(1)
TESTEOF

    # 変数を置換
    sed -i '' "s/\${ISSUE_NUMBER}/${ISSUE_NUMBER}/g" "$TEST_FILE"
    sed -i '' "s/\${ISSUE_TITLE}/${ISSUE_TITLE}/g" "$TEST_FILE"

    echo "✓ テストファイルテンプレートを作成しました: $TEST_FILE"
else
    echo "✓ テストファイルは既に存在します: $TEST_FILE"
fi

echo ""
echo "次のステップ:"
echo "1. 実装を進めて .i9wa4/pr.md の作業ログエリアに詳細を記録"
echo "2. テストケースを $TEST_FILE に実装"
echo "3. 実装完了後、PR本文エリアを編集"
echo "4. 手動でpushとPR作成を実行"
echo "   - git push -u origin \$(git branch --show-current)"
echo "   - gh pr create (PR本文は .i9wa4/pr.md の上部から取得)"
echo ""
echo "重要: このコマンドは作業ファイルの準備のみを行います。"
echo "     実際のPR作成は手動で行ってください。"
```

## 5. 統合形式でのワークフロー

### 5.1. ファイル構成

- `.i9wa4/pr.md`: 前半がPR本文、後半が作業ログの統合形式
- `.i9wa4/test_[issue番号].py`: テストファイルテンプレート（自動生成）

### 5.2. 作業手順

1. **実装中**: `.i9wa4/pr.md`の作業ログエリア（後半）に詳細を記録
2. **テスト実装**: `.i9wa4/test_[issue番号].py`にテストケースを実装
3. **実装完了**: PR本文エリア（前半）を編集
   - やったこと: 作業ログから主要な変更を転記
   - 動作確認: テスト結果を記載（テストファイルの実行結果を含む）
   - 特に確認してほしい箇所: 重要なポイントを記載
4. **手動でPR作成**:
   - `git push -u origin $(git branch --show-current)`
   - `gh pr create` でPR作成（本文は下記方法で取得）

### 5.3. PR本文の取得方法

```bash
# PR本文エリア（区切り線より上）を取得
sed '/<!-- ===== 作業ログエリア/q' .i9wa4/pr.md | head -n -1 > /tmp/pr_body.md
```

### 5.4. 手動でのPR作成手順

```bash
# 1. ブランチをpush
git push -u origin $(git branch --show-current)

# 2. PR本文を一時ファイルに抽出
sed '/<!-- ===== 作業ログエリア/q' .i9wa4/pr.md | head -n -1 > /tmp/pr_body.md

# 3. PR作成
gh pr create --title "$(head -n 1 .i9wa4/pr.md | sed 's/# PR: //')" --body-file /tmp/pr_body.md

# 4. 一時ファイルを削除
rm /tmp/pr_body.md
```

### 5.5. メリット

- **1ファイル完結**: 情報が分散しない
- **リアルタイム更新**: 実装と並行してPR本文も更新
- **情報の整合性**: PR本文と実装内容の乖離がない
- **シンプルな管理**: 複数ファイルの同期不要
- **安全性**: 意図しないpushやPR作成を防止
- **テスト統合**: テストファイルも自動生成され、テスト駆動開発を促進
