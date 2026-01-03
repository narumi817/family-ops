# FamilyOps 開発TODO

家事育児ログアプリ「FamilyOps」の開発タスクリスト

## 📋 プロジェクト構築

### Rails 8 API (api/)

- [x] Rails 8 API専用プロジェクトの作成
- [x] PostgreSQL設定（database.yml）
- [x] RSpecのセットアップ
- [x] FactoryBotの設定
- [x] solid_cache/solid_queueの設定確認
- [x] rack-corsの設定（CORS対応）
- [x] bcryptの有効化（標準認証）
- [x] Docker Composeの設定（開発環境）
- [x] テスト環境のHost Authorization設定

### Nuxt 3 フロントエンド (client/)

- [x] Nuxt 3プロジェクトの作成
- [x] @pinia/nuxtのインストール・設定
- [x] @nuxtjs/tailwindcssのインストール・設定
- [x] プロキシ設定（/api/** → Rails API）
- [x] 環境変数設定（.env）
- [x] composables/useApi.tsの作成
- [x] 動作確認ページの作成（pages/index.vue）
- [x] TypeScript設定（tsconfig.json）

## 🗄️ データベース設計

- [x] usersテーブルの設計・マイグレーション
  - [x] 基本カラム（name, email, password_digest）
  - [x] last_login_atカラムの追加
  - [x] OAuth対応（provider, uid）の追加
- [x] tasksテーブルの設計・マイグレーション
  - [x] 基本カラム（name, description）
  - [x] categoryカラム（integer + Enum）
- [x] logsテーブルの設計・マイグレーション
  - [x] 基本カラム（user_id, task_id, performed_at, notes）
  - [x] インデックス設定
- [x] familiesテーブルの設計・マイグレーション
- [x] family_membersテーブルの設計・マイグレーション
  - [x] roleカラム（integer + Enum）
- [x] family_task_pointsテーブルの設計・マイグレーション

## 🔐 認証機能

### パスワード認証

- [x] Userモデルの作成
  - [x] has_secure_passwordの設定
  - [x] バリデーション（email, password）
  - [x] OAuth対応のバリデーション（provider/uid or password_digest必須）
- [ ] 認証コントローラーの作成
  - [ ] サインアップ（POST /api/auth/signup）
  - [ ] ログイン（POST /api/auth/login）
  - [ ] ログアウト（DELETE /api/auth/logout）
  - [ ] セッション管理
- [ ] JWT認証の実装（オプション）
  - [ ] jwt gemの追加
  - [ ] トークン生成・検証ロジック

### OAuth認証（Google）

- [ ] OmniAuthの設定
  - [ ] omniauth-google-oauth2 gemの追加
  - [ ] 初期化ファイルの設定
- [ ] OAuthコントローラーの作成
  - [ ] 認証開始（GET /api/auth/google）
  - [ ] コールバック処理（GET /api/auth/google/callback）
- [ ] UserモデルのOAuth対応
  - [ ] provider/uidでの検索・作成ロジック

## 📝 モデル実装

- [x] Userモデル
  - [x] アソシエーション定義
  - [x] バリデーション
  - [x] スコープ・メソッド
- [x] Taskモデル
  - [x] Enum定義（category）
  - [x] アソシエーション定義
  - [x] バリデーション
- [x] Logモデル
  - [x] アソシエーション定義
  - [x] バリデーション
  - [x] スコープ（日付範囲、ユーザー別など）
- [x] Familyモデル
  - [x] アソシエーション定義
  - [x] バリデーション
- [x] FamilyMemberモデル
  - [x] Enum定義（role）
  - [x] アソシエーション定義
  - [x] バリデーション
- [x] FamilyTaskPointモデル
  - [x] アソシエーション定義
  - [x] バリデーション
  - [x] ユニーク制約

## 🛣️ APIエンドポイント実装

### 認証関連

- [ ] POST /api/auth/signup - ユーザー登録
- [ ] POST /api/auth/login - ログイン
- [ ] DELETE /api/auth/logout - ログアウト
- [ ] GET /api/auth/me - 現在のユーザー情報取得
- [ ] GET /api/auth/google - Google認証開始
- [ ] GET /api/auth/google/callback - Google認証コールバック

### ユーザー関連

- [ ] GET /api/users - ユーザー一覧（認証済み）
- [ ] GET /api/users/:id - ユーザー詳細
- [ ] PATCH /api/users/:id - ユーザー更新

### タスク関連

- [ ] GET /api/tasks - タスク一覧
- [ ] GET /api/tasks/:id - タスク詳細
- [ ] POST /api/tasks - タスク作成
- [ ] PATCH /api/tasks/:id - タスク更新
- [ ] DELETE /api/tasks/:id - タスク削除

### ログ関連

- [ ] GET /api/logs - ログ一覧（フィルタリング対応）
- [ ] GET /api/logs/:id - ログ詳細
- [ ] POST /api/logs - ログ作成
- [ ] PATCH /api/logs/:id - ログ更新
- [ ] DELETE /api/logs/:id - ログ削除

### 家族関連

- [ ] GET /api/families - 家族一覧（認証済みユーザーの家族）
- [ ] GET /api/families/:id - 家族詳細
- [ ] POST /api/families - 家族作成
- [ ] PATCH /api/families/:id - 家族更新
- [ ] DELETE /api/families/:id - 家族削除
- [ ] POST /api/families/:id/members - 家族メンバー追加
- [ ] DELETE /api/families/:id/members/:user_id - 家族メンバー削除

### ポイント設定関連

- [ ] GET /api/families/:id/task_points - 家族のタスクポイント一覧
- [ ] POST /api/families/:id/task_points - タスクポイント設定
- [ ] PATCH /api/families/:id/task_points/:id - タスクポイント更新
- [ ] DELETE /api/families/:id/task_points/:id - タスクポイント削除

## 🧪 テスト実装

### モデルテスト

- [ ] Userモデルのテスト
- [ ] Taskモデルのテスト
- [ ] Logモデルのテスト
- [ ] Familyモデルのテスト
- [ ] FamilyMemberモデルのテスト
- [ ] FamilyTaskPointモデルのテスト

### リクエストテスト

- [ ] 認証関連のテスト
- [ ] ユーザー関連のテスト
- [ ] タスク関連のテスト
- [ ] ログ関連のテスト
- [ ] 家族関連のテスト
- [ ] ポイント設定関連のテスト

### Factory定義

- [ ] User Factory
- [ ] Task Factory
- [ ] Log Factory
- [ ] Family Factory
- [ ] FamilyMember Factory
- [ ] FamilyTaskPoint Factory

## 🎨 フロントエンド実装

### 認証画面

- [ ] ログイン画面
- [ ] サインアップ画面
- [ ] Google認証ボタン
- [ ] 認証状態管理（Pinia）

### ダッシュボード

- [ ] ホーム画面
- [ ] ログ一覧表示
- [ ] ログ作成フォーム
- [ ] 統計情報表示

### タスク管理

- [ ] タスク一覧画面
- [ ] タスク作成・編集画面
- [ ] タスク削除機能

### 家族管理

- [ ] 家族一覧画面
- [ ] 家族作成・編集画面
- [ ] 家族メンバー管理画面
- [ ] タスクポイント設定画面

### ユーザー設定

- [ ] プロフィール編集画面
- [ ] パスワード変更画面

## 🚀 デプロイ準備

- [ ] 本番環境の設定
- [ ] 環境変数の管理
- [ ] データベースマイグレーション
- [ ] エラーハンドリング
- [ ] ログ設定
- [ ] パフォーマンス最適化

## 📚 ドキュメント

- [ ] API仕様書の作成
- [ ] セットアップガイドの作成
- [ ] 開発ガイドの作成

## 🔧 リファクタリング（モデルが大きくなった時）

### Concernを使うべきケース

- [ ] 複数のモデルで共有するロジックをConcernに切り出す
  - 例: `Authenticatable`（認証ロジック）、`SoftDeletable`（論理削除）など
- [ ] モデルが100行を超える場合、複雑なビジネスロジックをConcernに分離

### Service Objectに切り出す

- [ ] 複雑なビジデンスロジックをService Objectに分離
  - 例: `UserAuthenticationService`、`FamilyMemberService`など
- [ ] トランザクション処理が必要な複雑な操作をService Objectに分離

### Query Objectに切り出す

- [ ] 複雑なクエリロジックをQuery Objectに分離
  - 例: `UsersByFamilyQuery`、`LogsByDateRangeQuery`など
- [ ] 複数のスコープを組み合わせた複雑な検索をQuery Objectに分離

### 注意点

- モデルが小規模（50行未満）の場合は、無理に分離しない
- 単一モデル専用のロジックはモデル内に残す
- 過度な抽象化は可読性を下げる可能性がある
- バリデーションやシンプルなスコープはモデル内に残す

