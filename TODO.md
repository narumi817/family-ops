# FamilyOps 開発TODO

家事育児ログアプリ「FamilyOps」の開発タスクリスト

## 📋 プロジェクト構築

### Rails 8 API (api/)

- [x] Rails 8 API専用プロジェクトの作成
- [x] PostgreSQL設定（database.yml）
- [x] RSpecのセットアップ
  - [x] APIモードに適した設定
  - [x] Request spec用のヘルパー作成
- [x] FactoryBotの設定
- [x] solid_cache/solid_queueの設定確認
- [x] rack-corsの設定（CORS対応）
- [x] bcryptの有効化（標準認証）
- [x] Docker Composeの設定（開発環境）
- [x] テスト環境のHost Authorization設定
- [x] テスト環境のログ設定（test.logへの出力）

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
- [x] email_verificationsテーブルの設計・マイグレーション
  - [x] 基本カラム（user_id, email, token, token_expired_at, verified_at）
- [x] family_invitationsテーブルの設計・マイグレーション
  - [x] 基本カラム（family_id, email, token, token_expired_at, invite_user_id, accepted_at）

## 🔐 認証機能

### パスワード認証

- [x] Userモデルの作成
  - [x] has_secure_passwordの設定
  - [x] バリデーション（email, password）
  - [x] OAuth対応のバリデーション（provider/uid or password_digest必須）
- [x] 認証コントローラーの作成
  - [x] ログイン（POST /api/v1/login）
  - [x] ログアウト（DELETE /api/v1/logout）
  - [x] ログイン状態確認（GET /api/v1/logged_in）
  - [x] セッション管理（Cookieベース）
- [x] サインアップ機能の実装
  - [x] メールアドレス確認機能
    - [x] トークン生成・検証ロジック
    - [x] メール送信機能（ActionMailer）
    - [x] 開発環境でのメール確認（letter_opener / letter_opener_web）
  - [x] 画面からのサインアップ（最初の家族メンバー）
    - [x] SignupControllerの作成
    - [x] メールアドレス登録・確認メール送信
    - [x] メールアドレス認証
    - [x] ユーザー情報登録完了（Family作成含む）
  - [x] 招待によるサインアップ（二人目以降）
    - [x] FamilyInvitationモデルの作成
    - [x] InvitationsControllerの作成
    - [x] 招待メール送信
    - [x] 招待トークン検証
    - [x] 招待受諾完了（既存Familyに紐付け）
  - [ ] QRコードによる家族招待（メール送信以外のパターン）
    - [ ] QRで招待トークンを共有（既存の招待tokenを流用する想定）
    - [ ] QR読み取り導線（スマホカメラ/入力コードのフォールバック）
    - [ ] 懸念: メールアドレス確認をどのタイミングで行うか
      - 案A（第一候補）: **既存ユーザー（ログイン済み）=即参加** / **新規ユーザー=メール確認→参加確定**
      - 案B: 先に参加（仮）させて、メール未確認の間は権限/閲覧を制限し、確認後にフルアクセス
- [ ] パスワード忘れ対応
    - [ ] メール送信
    - [ ] パスワード再設定
- [ ] JWT認証の実装（検討）
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
  - [ ] パスワードサインアップ/招待サインアップ/OAuthサインアップのService共通化・リファクタリング検討（SignupService, InvitationSignupService など）

## 🎨 画面

- モバイルファーストデザイン
- 片手操作しやすいボタンサイズ
- 温かみのあるデザイン

### 認証画面

- [x] ログイン画面
- [x] 認証前共通レイアウト（layouts/auth.vue）
- [x] サインアップ画面（通常フロー）
  - [x] /signup/email（メールアドレス入力）
  - [x] /signup/email_sent（確認メール送信完了）
  - [x] /signup/verify（メール認証）
  - [x] /signup/complete（ユーザー情報登録）
- [x] 招待フロー画面
  - [x] /invitations/verify（招待トークン確認）
  - [x] /invitations/complete（招待受諾）
- [ ] Google認証ボタン
- [x] パスワード忘れ

### ダッシュボード

- [x] ホーム画面
  - [x] 当日の累計ポイント表示
- [x] ログ一覧表示
  - 当日のログをタイムライン表示
  - 当日の累計ポイント表示
  - 実行者の色分け
  - メモ表示
- [x] ログ作成フォーム
  - タスク選択
  - 実行時間選択
  - メモ入力
  - ログ作成API呼び出し
- [ ] ログ削除
- [ ] 統計情報表示
- [ ] カレンダー表示
- [ ] ログイン後共通レイアウト（ナビゲーション整理）

### タスク管理

- [x] タスク一覧画面
- [ ] タスク作成・編集画面
- [ ] タスク削除機能
  - 家族独自のタスクのみが対象

### 家族管理

- [ ] 家族一覧画面
- [ ] 家族作成・編集画面
- [ ] 家族メンバー管理画面
- [ ] 家族招待UI
  - [x] メール送信
  - [ ] QRコード表示・読み取り
- [x] タスクポイント設定画面

### ユーザー設定

- [ ] プロフィール編集画面
- [ ] パスワード変更画面

## 📋 タスク機能実装

### Phase 1: 基本機能

- [x] 家族のタスク一覧取得API実装 (GET /api/v1/families/:id/tasks)
  - 全家族共通 + 家族固有のタスクを返す
  - 家族固有のポイントも含める
- [x] 当日の累計ポイント取得API実装 (GET /api/v1/family/points/today)
  - ログイン中のユーザーの当日の累計ポイントを取得
- [x] ログ一覧画面の拡張 (/index.vue)
  - 当日のログをタイムライン表示
  - 当日の累計ポイント表示
  - 実行者の色分け
  - メモ表示
- [x] タスクログ登録画面実装 (/logs/new)
  - タスク選択
  - 実行時間選択
  - メモ入力
  - ログ作成API呼び出し

### Phase 2: タスク管理

- [x] タスクポイント変更API実装 (PUT /api/v1/families/:id/tasks/:task_id/points)
  - FamilyTaskPointの作成・更新
- [x] タスクマスタ管理画面実装 (/families/[id]/tasks)
  - [x] タスク一覧表示（タスク名、カテゴリ、ポイント、説明）
  - [x] ポイント編集UI

### Phase 3: 拡張機能（将来）

- [ ] タスク追加UI実装（ログ登録時）
  - タスク名、カテゴリ、ポイントを入力して家族固有のタスクとして登録
  - 家族のタスク登録API実装 (POST /api/v1/families/:id/tasks)
- [ ] フィルタリング機能実装
  - ログ一覧で人、家事、日時で絞り込み
  - API拡張 (GET /api/v1/family/logs に user_id, task_id パラメータ追加)
- [ ] ゴール設定とポイント消費機能
  - ゴール設定
  - 累計ポイント・使用できるポイントの別管理
- [ ] タスク削除機能
  - 家族のタスク削除APIとUIの実装（論理削除 or 物理削除は要検討）

## 🎨 UI/UX改善

- [ ] スマホ表示レイアウト修正（レスポンシブデザインの調整）
  - タスクマスタ管理画面（/families/[id]/tasks）の改善
  - ナビゲーションをハンバーガーメニューなどにする

## セキュリティ対応
- [ ] 不正アクセス対応検討
  - 2段階認証/アクセス制限etc...

## 🚀 デプロイ準備

- [x] 本番環境の設定
- [x] 環境変数の管理
- [x] データベースマイグレーション
- [ ] エラーハンドリング
- [x] ログ設定
- [ ] パフォーマンス最適化

## 運用・バッチ

- [ ] 論理削除ログの物理削除バッチ
  - `deleted_at` が1年経過したログを物理削除するバッチの実装（cron / Solid Queue 等）

## 🔧 リファクタリング（モデルが大きくなった時）

### Concernを使うべきケース

- [ ] 複数のモデルで共有するロジックをConcernに切り出す
  - 例: `Authenticatable`（認証ロジック）、`SoftDeletable`（論理削除）など
- [ ] モデルが100行を超える場合、複雑なビジネスロジックをConcernに分離

### Service Objectに切り出す

- [x] 複雑なビジネスロジックをService Objectに分離
  - [x] `SignupService`（通常サインアップ）
  - [x] `InvitationSignupService`（招待サインアップ）
  - [x] `FamilyInvitationService`（家族招待メール送信）
  - [x] `SignupValidationService`（サインアップバリデーション共通化）
  - 例: `UserAuthenticationService`、`FamilyMemberService`など
- [x] トランザクション処理が必要な複雑な操作をService Objectに分離

### Query Objectに切り出す

- [ ] 複雑なクエリロジックをQuery Objectに分離
  - 例: `UsersByFamilyQuery`、`LogsByDateRangeQuery`など
- [ ] 複数のスコープを組み合わせた複雑な検索をQuery Objectに分離

### 注意点
- モデルが小規模（50行未満）の場合は、無理に分離しない
- 単一モデル専用のロジックはモデル内に残す
- 過度な抽象化は可読性を下げる可能性がある
- バリデーションやシンプルなスコープはモデル内に残す

