# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# テスト環境ではCORSを無効化（テストではOriginヘッダーが設定されないため）
unless Rails.env.test?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      # 開発環境では localhost からのアクセスを許可（Nuxtは3001ポートで動作）
      # 本番環境では環境変数 ALLOWED_ORIGINS で指定（例: export ALLOWED_ORIGINS="https://example.com,https://www.example.com"）
      if Rails.env.development?
        origins "http://localhost:3001", "http://localhost:3000", /http:\/\/localhost(:\d+)?/
      else
        # ALLOWED_ORIGINS が空の場合は空配列を返す（CORSエラーになるが、設定漏れを防ぐ）
        allowed_origins = ENV.fetch("ALLOWED_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)
        origins allowed_origins
      end

      # 本番環境で直接オリジンを指定する場合の例（上記の行をコメントアウトして、こちらを有効化）:
      # origins "https://example.com", "https://www.example.com"

      resource "*",
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true,
        expose: ['Set-Cookie']  # Cookie関連のヘッダーをクライアント側で確認可能にする
    end
  end
end
