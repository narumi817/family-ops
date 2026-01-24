# Nuxtフロントのコンポーネント方針（ゆるいアトミックデザイン）

ガチガチに階層を固定するのではなく、**共通化できる部品は段階的にコンポーネント化**していく方針。

## 目的

- 画面実装の重複（フォーム、エラー表示、ボタン等）を減らす
- 画面（`pages/`）を「配線」に寄せ、UIはコンポーネントに集約する
- 将来的な画面追加・デザイン変更を楽にする

## ディレクトリ構成（提案）

```txt
client/
  components/
    atoms/                 # 単体UI（状態を持たない or 最小）
      buttons/
        BaseButton.vue
      inputs/
        TextInput.vue
        SelectInput.vue
      feedback/
        InlineError.vue
        AlertBox.vue
        Spinner.vue

    molecules/             # atomsの組み合わせ（フォームの1項目など）
      forms/
        FormField.vue      # label + input slot + error
      navigation/
        NavLink.vue

    organisms/             # 画面の“塊”（カード、ヘッダー、サイドバー等）
      auth/
        AuthCard.vue
      navigation/
        AppHeader.vue

    features/              # 機能に閉じた部品（画面跨ぎで使うがドメイン依存）
      signup/
        SignupEmailForm.vue
        SignupCompleteForm.vue
      invitations/
      family/

  pages/                   # ルーティング単位（配線を薄く）
  layouts/                 # auth/default など
  composables/             # API/フォーム/ストレージ等の再利用ロジック
  stores/                  # Pinia
  utils/                   # 純関数（formatter等）
  types/                   # APIレスポンス型等
  assets/
```

## 運用ルール（迷った時の判断基準）

### pagesは「配線」
- **API呼び出し / ルーティング / store連携**をここに寄せる
- 入力UIは、可能なら `features/*` や `organisms/*` に逃がす

### atoms
- **props中心**で完結（storeやAPIに触らない）
- 例: ボタン、インプット、スピナー、エラー表示

### molecules
- atomsを組み合わせた部品（**フォームの1行**など）
- 例: `FormField`（label + slot + error）

### organisms
- 画面の大きい塊（**カード、ヘッダー、フォームセクション**）
- 例: `AuthCard`（タイトル + slot + footer）

### features
- 「この機能だけ」のUI（サインアップ/招待/家族管理など）
- 2ページ以上で再利用するが、atoms/molecules/organismsにすると抽象化しすぎる場合はここ

## どこに置くかの目安

- **2ページ以上で再利用** or **今後増える見込み** → `atoms/molecules/organisms` へ
- **現状その画面（またはその機能）だけ** → `features/<feature>/` へ
- 迷ったら最初は `features` に置き、増えてきたら昇格（移動）する

## 適用方針（既存画面）

今後の画面追加・改修のタイミングで、以下の順で置き換えていく。

1. **エラー表示・ボタン・入力**（atoms）
2. **フォーム項目**（molecules）
3. **authカード等の枠**（organisms）
4. **フローごとのフォーム**（features）


