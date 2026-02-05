## Docker を使った本番相当環境の起動手順

本番と近い構成で Rails(API) + Nuxt(client) を Docker 上で動かすための手順メモです。

### 構成ファイル

- ベース構成: `api/docker-compose.yml`
- 本番相当の上書き: `api/docker-compose.prod.yml`

`docker-compose.yml` には開発向けの設定が定義されており、`docker-compose.prod.yml` で client サービスのビルドターゲットや `BASE_URL` などを上書きします。

### 起動コマンド（本番相当）

```bash
cd api

# 本番相当の構成で起動
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  up --build
```

### ポート

- Rails(API): `http://localhost:3000`
- Nuxt(client): `http://localhost:3001` → コンテナ内のポート `3000` にフォワード

※ 本番では、リバースプロキシ（Nginx やロードバランサ）経由で `/` や `/api` を振り分ける想定。

### 環境変数

- `api/docker-compose.prod.yml` の `client` サービスで設定:

```yaml
services:
  client:
    environment:
      - NODE_ENV=production
      # TODO:本番APIのURL（仮）
      - BASE_URL=https://api.example.com
```

実際の本番環境では、`BASE_URL` をデプロイ先の API エンドポイントに変更すること。


