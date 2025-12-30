# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発環境では localhost からのアクセスを許可
    # 本番環境では環境変数 ALLOWED_ORIGINS で指定（例: export ALLOWED_ORIGINS="https://example.com,https://www.example.com"）
    origins Rails.env.development? ? /http:\/\/localhost(:\d+)?/ : ENV.fetch("ALLOWED_ORIGINS", "").split(",")

    # 本番環境で直接オリジンを指定する場合の例（上記の行をコメントアウトして、こちらを有効化）:
    # origins "https://example.com", "https://www.example.com"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
