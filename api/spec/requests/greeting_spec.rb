require "rails_helper"

RSpec.describe "Greeting API", type: :request do
  before do
    host! "localhost"
  end

  describe "GET /greeting" do
    context "正常系" do
      it "200 OKを返す" do
        get "/greeting"
        expect(response).to have_http_status(:ok)
      end

      it "Hello WorldのメッセージをJSON形式で返す" do
        get "/greeting"
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ "message" => "Hello World" })
      end

      it "Content-Typeがapplication/jsonである" do
        get "/greeting"
        expect(response.content_type).to include("application/json")
      end
    end

    context "異常系" do
      it "GET以外のメソッドで404 Not Foundを返す（ルートが定義されていないため）" do
        post "/greeting"
        expect(response).to have_http_status(:not_found)
      end

      it "存在しないエンドポイントで404 Not Foundを返す" do
        get "/greetings"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

