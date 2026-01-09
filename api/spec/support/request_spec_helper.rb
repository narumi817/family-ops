# Request spec用のヘルパーメソッド
module RequestSpecHelper
  # JSONレスポンスをパースする
  # @return [Hash] パースされたJSON
  def json_response
    JSON.parse(response.body)
  end

  # 認証済みリクエストのヘッダーを設定する
  # @param user [User] ログインするユーザー
  # @param password [String] パスワード（デフォルト: 'password123'）
  def login_as(user, password: 'password123')
    post '/api/v1/login', params: {
      email: user.email,
      password: password
    }
  end

  # ログアウトする
  def logout
    delete '/api/v1/logout'
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end

