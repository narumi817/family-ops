# ログ削除機能 作業洗い出し

## 概要

「自分が登録したログ」だけを**論理削除**できるようにする。  
ログは `user_id` で所有者が決まっているため、**削除できるのは `log.user_id == 現在ログイン中のユーザーID` のときのみ**とする。  
物理削除は行わず、`deleted_at` を設定して一覧・集計から除外する。

---

## 1. API 側

### 1.1 データベース（論理削除用カラム）

| カラム | 型 | 説明 |
|--------|-----|------|
| `deleted_at` | datetime, nullable | 論理削除日時。NULL のとき有効なログ、設定済みのとき削除済み |

- マイグレーションで `logs` テーブルに `deleted_at` を追加する。
- 既存レコードは `deleted_at: nil` のまま（有効として扱う）。

### 1.2 ルート

| メソッド | パス | 説明 |
|----------|------|------|
| `DELETE` | `/api/v1/logs/:id` | 指定IDのログを論理削除する（自分のログのみ可） |

- 既存の `resources :logs, only: [:create]` に `:destroy` を追加する。

### 1.3 モデル（`Log`）

- **スコープを追加**
  - `scope :not_deleted, -> { where(deleted_at: nil) }` を定義する。
- **default_scope と 明示的 scope のどちらが保守しやすいか**
  - **明示的 scope（推奨）**: 一覧・集計の呼び出し元で `.not_deleted` を付ける。
    - メリット: 挙動が読み取りやすい。`destroy` で `Log.not_deleted.find_by(id:)` と書けば、論理削除済みは見つからず 404 にでき、`unscoped` が不要。新しいクエリを書くときも「有効なログだけ」が意図として残る。
  - **default_scope**: `default_scope { where(deleted_at: nil) }` にすると、すべてのクエリで自動的に除外されるが、`destroy` で「論理削除済みなら 404」にしたい場合は `Log.unscoped.find_by(id:)` が必要になり、パターンが二通りになる。また「隠れた条件」になるため、新規メンバーが気づきにくい。
  - **結論**: 呼び出し箇所が少ない前提なら、**明示的に `not_deleted` を付ける方式**の方が保守しやすい。
- **一覧・集計で論理削除を除外**
  - `for_family_with_filters`: 先頭で `not_deleted` を付与（`includes(:user, :task).not_deleted.for_family_users(...)`）。
  - `today_points_for_user`: `by_user` の前に `not_deleted` を付与（`not_deleted.by_user(user_id).by_date(date)...`）。
- **削除処理**
  - 物理削除は行わず、`log.update(deleted_at: Time.current)` で論理削除とする。

### 1.4 コントローラ（`Api::V1::LogsController`）

- **destroy アクションを追加**
  - `Log.not_deleted.find_by(id: params[:id])` でログを取得（論理削除済みは対象外）。
  - ログが存在しない → `404 Not Found`。
  - `log.user_id != current_user.id` → `403 Forbidden`（他人のログは削除不可）。
  - 上記以外 → `log.update(deleted_at: Time.current)` し、`204 No Content` で返す。
- 認証は既存どおり `before_action :require_login` でよい。

### 1.5 テスト（RSpec）

- **リクエストスペック**（`spec/requests/api/v1/logs_spec.rb` に追加）
  - **正常系**
    - ログイン済みで、自分が登録したログのIDを指定して DELETE → 204。該当ログの `deleted_at` が設定され、レコードはDBに残ること。一覧APIや当日ポイントからは除外されること。
  - **異常系**
    - 未ログインで DELETE → 401。
    - 他人のログのIDを指定して DELETE → 403（または 404）。
    - 存在しないログIDで DELETE → 404。
    - 既に論理削除済みのログIDで DELETE → 404。

---

## 2. クライアント側

### 2.1 ログ一覧画面（`pages/index.vue`）

- **削除ボタンの表示**
  - 各ログ行に「削除」ボタン（またはゴミ箱アイコン）を出す。
  - **表示条件**: `log.user.id === authStore.user?.id` のときだけ表示（自分が登録したログのみ）。
- **削除処理**
  - クリック時に確認（`window.confirm` またはモーダル）：「このログを削除しますか？」など。
  - OK の場合のみ `DELETE /api/v1/logs/:id` を呼ぶ。
  - 成功時:
    - 一覧から該当ログを除外する（`logs.value = logs.value.filter(l => l.id !== id)`）か、`fetchLogs()` と `fetchTodayPoints()` を再実行して一覧・当日ポイントを更新。
  - 失敗時: エラーメッセージを表示（トーストや画面上のメッセージなど）。

### 2.2 その他ページ

- ログ登録画面（`/logs/new`）は「登録」のみで、削除は一覧から行う想定のため**変更不要**。
- 他にログを一覧表示している画面があれば、同様に「自分のログのみ削除ボタン表示 + DELETE 呼び出し」を検討する。

---

## 3. 実装順序の提案

1. **API**
   - マイグレーションで `logs.deleted_at` を追加。
   - `Log` モデルに `not_deleted` スコープを追加し、`for_family_with_filters` と `today_points_for_user` で使用。
   - ルートに `destroy` を追加。
   - `LogsController#destroy` を実装（`not_deleted` で取得 → 所有者チェック → `deleted_at` 更新 → 204）。
   - RSpec で上記の正常・異常系を追加（論理削除であること・一覧から消えることを確認）。
2. **クライアント**
   - `index.vue` で「自分のログ」にだけ削除ボタンを表示。
   - 削除前に確認ダイアログを表示。
   - DELETE 実行後、一覧（と当日ポイント）を再取得するか、ローカル状態から該当ログを削除して表示を更新。

---

## 4. 補足

- **論理削除**: レコードは残し、`deleted_at` を設定するだけ。一覧・当日ポイントはすべて `not_deleted` で除外する。復元機能は今回の範囲外とする。
- **権限**: 家族のログ一覧では「家族全員のログ」が見えるが、削除は「自分が登録したログ」に限定する。
- **UX**: 誤削除を防ぐため、削除前の確認は必須にした方がよい。
- **レスポンス**: 削除成功は `204 No Content` で返す。
