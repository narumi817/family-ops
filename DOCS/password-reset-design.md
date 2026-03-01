# パスワード忘れ機能 設計メモ

## 概要

- ユーザーがメールアドレスを入力 → リセット用リンクを送信 → リンク先で新パスワードを設定する流れ。
- 既存の「サインアップ（メール確認）」「招待（トークン検証→完了）」と同様のトークン＋メール方式で揃える。

---

## 1. API 側で必要なもの

### 1.1 データベース

トークン管理は **専用テーブル `password_reset_tokens`** で行う。既存の `email_verifications` や `family_invitations` と同じパターンに揃え、トークン生成・検証・無効化を一貫して扱う。

| カラム | 型 | 説明 |
|--------|-----|------|
| `user_id` | bigint, FK, not null | リセット対象ユーザー |
| `token` | string, not null, unique | リセット用トークン |
| `token_expired_at` | datetime, not null | 有効期限（例: 発行から1時間） |
| `used_at` | datetime, nullable | 使用済み日時（未使用は nil） |

- マイグレーションで `password_reset_tokens` テーブルを作成し、`user_id` に users への外部キー、`token` にユニークインデックスを張る。

---

### 1.2 ルート

| メソッド | パス | 説明 |
|----------|------|------|
| `POST` | `/api/v1/password_reset` | メールアドレスを受け取り、該当ユーザーがいればトークン発行・リセットメール送信。 |
| `GET` | `/api/v1/password_reset/verify` | クエリ `token` でトークン検証。有効なら 200 とメール（または user_id）を返す。フロントでリセット画面表示の可否に利用。 |
| `POST` | `/api/v1/password_reset/complete` | `token`, `password`, `password_confirmation` でパスワード更新。成功後はトークン無効化（`used_at` を設定）。 |

※ ルートは `scope :password_reset` でまとめ、既存の `signup` / `invitations` と同様にする。

---

### 1.3 コントローラ

- **PasswordResetController**（例: `api/v1/password_reset_controller.rb`）
  - **create**: メールを受け取る。パスワード認証ユーザー（`password_digest.present?`）かつ登録済みメールならトークン発行＋メール送信。存在しなくても「送信しました」と返す（メールアドレス漏洩を防ぐため）。
  - **verify**: `params[:token]` で検証。有効なら `email` や `valid: true` を返す。無効・期限切れは 400/404。
  - **complete**: `token` + `password` + `password_confirmation` を受け取り、バリデーション後 `user.update(password: ..., password_confirmation: ...)` とトークン無効化（`used_at` を更新）。

※ `create` は認証不要。`verify` / `complete` もトークンのみで実行するため認証不要。

---

### 1.4 モデル・サービス

| 種別 | 内容 |
|------|------|
| **モデル** | `PasswordResetToken`。`belongs_to :user`。`token` は `SecureRandom.urlsafe_base64` 等で生成。有効判定は `token_expired_at > Time.current && used_at.nil?`。 |
| **スコープ** | `by_token(token)`, `valid`（未使用かつ有効期限内）。 |
| **サービス** | `PasswordResetService`。`request_reset(email:)`（トークン生成＋メール送信）、`verify_token(token)`、`complete_reset(token:, password:, password_confirmation:)` でビジネスロジックをまとめる。 |

---

### 1.5 メーラー

| 種別 | 内容 |
|------|------|
| **Mailer** | `PasswordResetMailer`（`ApplicationMailer` 継承）。 |
| **メソッド** | 例: `reset_email(password_reset_token)`。本文に `password_reset_url(token: token)` のようなリンクを埋め込む。 |
| **設定** | 既存の `default_url_options`（開発: localhost:3001、本番: MAILER_HOST）を使い、リンクのホストはクライアント側（Nuxt）のURLにする。 |

※ 本番では Resend を使用しているため、同じく `delivery_method :resend` で送信。

---

### 1.6 セキュリティ・その他

- トークンは **有効期限を短く**（例: 1時間）。既存の `email_verifications`（24時間）より短くする。
- リセット完了後は **トークンを無効化**（`used_at` を設定）。
- **レート制限**（同一IP・同一メールからの連続リクエスト制限）は余裕があれば検討。

---

## 2. 画面（クライアント）側で必要なもの

### 2.1 ルート・ページ

| パス | 役割 |
|------|------|
| `/login` | 既存。ここに「パスワードを忘れた方はこちら」リンクを追加し、`/forgot-password` へ遷移。 |
| `/forgot-password` | メールアドレス入力のみ。送信後は「入力されたメールアドレスに送信しました」と表示（存在しなくても同じメッセージ）。 |
| `/password-reset` | メール内リンクの遷移先。クエリ `?token=xxx` 必須。トークン検証 API を呼び、OK なら新パスワード・確認用の入力フォームを表示。送信で complete API を呼び、成功したらログイン画面へ。 |

※ 既存の `signup/verify`・`invitations/verify` と同様に、`password-reset` は `?token=xxx` で開き、検証後にフォームを表示する形でよい。

---

### 2.2 画面仕様（簡易）

- **ログイン画面（/login）**
  - パスワード入力欄の近くに「パスワードを忘れた方はこちら」→ `/forgot-password` のリンクを追加。

- **パスワード忘れ メール送信（/forgot-password）**
  - レイアウト: `auth`（未ログイン用レイアウト）。
  - 入力: メールアドレスのみ。
  - 送信: `POST /api/v1/password_reset`（body: `{ email }`）。
  - 成功時: 「ご入力いただいたメールアドレスにリセット用リンクを送信しました。」と表示。ログインへのリンク。
  - バリデーション: メール形式。API の 4xx は既存のエラー表示コンポーネントで表示。

- **パスワードリセット 新パスワード設定（/password-reset）**
  - レイアウト: `auth`。
  - 初回: `route.query.token` で `GET /api/v1/password_reset/verify?token=xxx` を呼ぶ。失敗なら「リンクが無効または期限切れです」と表示し、`/forgot-password` へのリンク。
  - 成功時: 新パスワード・確認用の 2 フィールドを表示。既存の `PasswordFields` や signup/complete のバリデーション（最小長・一致）を流用可能。
  - 送信: `POST /api/v1/password_reset/complete`（body: `{ token, password, password_confirmation }`）。
  - 成功時: 「パスワードを変更しました」→ ログイン画面へリダイレクト（またはその場でログインさせるなら auth store の login を呼ぶ）。

---

### 2.3 composables / API 呼び出し

- `useApi` の `$fetch` で以下を呼ぶ想定:
  - `POST /api/v1/password_reset`（create）
  - `GET /api/v1/password_reset/verify?token=xxx`
  - `POST /api/v1/password_reset/complete`
- 必要なら `composables/usePasswordReset.ts` のような薄いラッパーで「送信」「検証」「完了」をまとめてもよい。

---

## 3. 実装順序の提案

1. **API**
   - マイグレーション（`password_reset_tokens` テーブル作成）
   - モデル `PasswordResetToken`（＋スコープ・クラスメソッド）
   - `PasswordResetMailer` とメールテンプレート
   - サービス `PasswordResetService`（request / verify / complete）
   - `PasswordResetController` とルート
   - RSpec（request spec で create, verify, complete の正常・異常）

2. **クライアント**
   - ログイン画面に「パスワードを忘れた方」リンク追加
   - `/forgot-password` ページ（メール送信）
   - `/password-reset` ページ（トークン検証＋新パスワードフォーム）
   - 必要に応じて composable で API ラップ

---

## 4. 既存との対応

| 既存 | パスワードリセット |
|------|---------------------|
| `EmailVerification` + メール | `PasswordResetToken` + メール |
| `GET signup/verify` + `POST signup/complete` | `GET password_reset/verify` + `POST password_reset/complete` |
| `POST signup/email`（トークン発行＋送信） | `POST password_reset`（トークン発行＋送信） |
| 招待 verify → complete | 同様の流れで token 検証 → 完了 |

この設計に沿って実装すれば、既存の認証・メール基盤と一貫した形でパスワード忘れ機能を追加できます。
