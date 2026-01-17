# サインアップフロー

FamilyOpsアプリケーションのサインアップフロー図

## 1. 画面からサインアップ（最初の家族メンバー）

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Frontend as フロントエンド
    participant API as Rails API
    participant DB as データベース
    participant Mail as メールサービス

    User->>Frontend: 1. メールアドレス入力
    Frontend->>API: POST /api/v1/signup/email
    Note over API: メールアドレス重複チェック
    alt メールアドレスが既に登録済み
        API-->>Frontend: 400 Bad Request (重複エラー)
        Frontend-->>User: エラーメッセージ表示
    else メールアドレス未登録
        API->>DB: トークン生成（確認トークン）
        Note over API: メールアドレス確認用トークンを保存
        API->>Mail: 確認メール送信
        API-->>Frontend: 200 OK
        Frontend-->>User: メール送信完了メッセージ
    end

    User->>Mail: 2. 確認メール受信
    User->>Frontend: 3. メール内の認証リンクをクリック
    Frontend->>API: GET /api/v1/signup/verify?token=xxx
    API->>DB: トークン検証
    alt トークンが有効
        API-->>Frontend: 200 OK (認証成功)
        Frontend->>User: 4. 情報入力フォーム表示
    else トークンが無効/期限切れ
        API-->>Frontend: 400 Bad Request
        Frontend-->>User: エラーメッセージ表示
    end

    User->>Frontend: 5. ユーザー名、パスワード、家族名、役割を入力
    Frontend->>API: POST /api/v1/signup/complete
    Note over API: バリデーション
    API->>DB: User作成
    API->>DB: Family作成
    API->>DB: FamilyMember作成
    API->>DB: セッション作成（ログイン状態）
    API-->>Frontend: 200 OK (ユーザー情報 + セッション)
    Frontend-->>User: ダッシュボード表示（ログイン状態）
```

## 2. 招待によるサインアップ（二人目以降の家族メンバー）

```mermaid
sequenceDiagram
    participant Member1 as 既存ユーザー（家族メンバー1）
    participant Frontend as フロントエンド
    participant API as Rails API
    participant DB as データベース
    participant Mail as メールサービス
    participant Member2 as 招待されたユーザー（家族メンバー2）

    Member1->>Frontend: 1. 家族のメールアドレスを入力
    Frontend->>API: POST /api/v1/families/:id/invitations
    Note over API: メールアドレス重複チェック
    Note over API: 家族メンバー権限チェック
    alt メールアドレスが既に登録済み
        API-->>Frontend: 400 Bad Request (重複エラー)
        Frontend-->>Member1: エラーメッセージ表示
    else メールアドレス未登録
        API->>DB: 招待トークン生成
        Note over API: 家族IDとメールアドレスを紐付け
        API->>Mail: 招待メール送信
        API-->>Frontend: 200 OK
        Frontend-->>Member1: 招待メール送信完了メッセージ
    end

    Member2->>Mail: 2. 招待メール受信
    Member2->>Frontend: 3. メール内の招待リンクをクリック
    Frontend->>API: GET /api/v1/invitations/verify?token=xxx
    API->>DB: 招待トークン検証
    alt トークンが有効
        API-->>Frontend: 200 OK (家族情報 + 認証成功)
        Frontend->>Member2: 4. 情報入力フォーム表示
    else トークンが無効/期限切れ
        API-->>Frontend: 400 Bad Request
        Frontend-->>Member2: エラーメッセージ表示
    end

    Member2->>Frontend: 5. ユーザー名、パスワード、役割を入力
    Frontend->>API: POST /api/v1/invitations/complete
    Note over API: バリデーション
    API->>DB: User作成
    API->>DB: FamilyMember作成（既存のFamilyに紐付け）
    API->>DB: セッション作成（ログイン状態）
    API-->>Frontend: 200 OK (ユーザー情報 + セッション)
    Frontend-->>Member2: ダッシュボード表示（ログイン状態）
```

## データベース設計の検討事項

### 必要なテーブル・カラム

#### 1. Userテーブル
- 既存カラム: `email`, `name`, `password_digest`, `provider`, `uid`
- **追加が必要**: 
  - `email_verified_at` (datetime, null: true) - メールアドレス確認日時（確認完了日時を永続化）

#### 2. EmailVerificationテーブル（新規作成）
- `id` (bigint, primary key)
- `user_id` (bigint, foreign key, null: true) - ユーザーID（ユーザー未作成時はNULL）
- `email` (string, null: false) - 確認対象のメールアドレス
- `token` (string, null: false, unique) - 確認トークン
- `token_expires_at` (datetime, null: false) - トークン有効期限
- `verified_at` (datetime, null: true) - 確認完了日時
- `created_at` (datetime)
- `updated_at` (datetime)
- インデックス: `token` (UNIQUE), `email`, `user_id`

**設計思想:**
- トークンは一時的なデータのため、専用テーブルで管理
- 確認完了後は削除（または`verified_at`を設定）
- ユーザー未作成時でもトークンを発行可能（初期サインアップに対応）

詳細は `DOCS/email_verification_design.md` を参照

#### 3. FamilyInvitationテーブル（新規作成）
- `id` (bigint, primary key)
- `family_id` (bigint, foreign key) - 招待元の家族ID
- `email` (string, null: false) - 招待先のメールアドレス
- `token` (string, null: false, unique) - 招待トークン
- `token_expires_at` (datetime, null: false) - トークン有効期限
- `invited_by` (bigint, foreign key to users) - 招待したユーザーID
- `accepted_at` (datetime, null: true) - 招待受諾日時
- `created_at` (datetime)
- `updated_at` (datetime)
- インデックス: `token`, `email`, `family_id`

## APIエンドポイント

### 1. 画面からのサインアップ

#### メールアドレス登録
- `POST /api/v1/signup/email`
- Request: `{ email: "user@example.com" }`
- Response: `{ message: "確認メールを送信しました" }`

#### メールアドレス認証
- `GET /api/v1/signup/verify?token=xxx`
- Response: `{ verified: true, email: "user@example.com" }`

#### ユーザー情報登録完了
- `POST /api/v1/signup/complete`
- Request: `{ token: "xxx", name: "ユーザー名", password: "password", password_confirmation: "password", family_name: "家族名", role: "mother" }`
- Response: `{ user: {...}, family: {...}, logged_in: true }`

### 2. 招待によるサインアップ

#### 招待メール送信
- `POST /api/v1/families/:id/invitations`
- Request: `{ email: "invited@example.com" }`
- Response: `{ message: "招待メールを送信しました" }`

#### 招待トークン検証
- `GET /api/v1/invitations/verify?token=xxx`
- Response: `{ verified: true, family: {...}, email: "invited@example.com" }`

#### 招待受諾完了
- `POST /api/v1/invitations/complete`
- Request: `{ token: "xxx", name: "ユーザー名", password: "password", password_confirmation: "password", role: "father" }`
- Response: `{ user: {...}, family: {...}, logged_in: true }`

