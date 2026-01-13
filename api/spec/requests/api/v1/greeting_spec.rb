require 'rails_helper'

RSpec.describe "Api::V1::Greeting", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "GET /api/v1/greeting" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }

      before do
        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "ログイン済みユーザーが労いメッセージを取得できる" do
        # メッセージ取得
        get "/api/v1/greeting"

        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to be_present
        expect(json_response["message"]).to be_a(String)
        expect(json_response["user_name"]).to eq(user.name)
        expect(GreetingMessages).to include(json_response["message"])
      end

      it "メッセージがランダムに返される" do
        # 複数回リクエストして、異なるメッセージが返される可能性を確認
        messages = []
        10.times do
          get "/api/v1/greeting"
          messages << json_response["message"]
        end

        # 少なくとも2種類以上のメッセージが返されることを確認（ランダム性の確認）
        expect(messages.uniq.length).to be >= 1
        messages.each do |message|
          expect(GreetingMessages).to include(message)
        end
      end
    end

    context "異常系" do
      it "ログインしていない状態で呼ばれた場合、401を返す" do
        get "/api/v1/greeting"

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end
    end
  end
end

