require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "POST /api/v1/login" do
    context "正常系" do
      it "ログインに成功し、セッションが保持される（家族に所属している場合）" do
        user = create(:user, password: "password123")
        family = create(:family, name: "テスト家族")
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["logged_in"]).to be true
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["user"]["name"]).to eq(user.name)
        expect(json_response["user"]["email"]).to eq(user.email)
        expect(json_response["family"]["id"]).to eq(family.id)
        expect(json_response["family"]["name"]).to eq("テスト家族")
        expect(session[:user_id]).to eq(user.id)
      end

      it "ログインに成功し、家族に所属していない場合はfamilyがnullになる" do
        user = create(:user, password: "password123")

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["logged_in"]).to be true
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["family"]).to be_nil
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context "異常系" do
      it "無効なパスワードでログインに失敗する" do
        user = create(:user, password: "password123")

        post "/api/v1/login", params: {
          email: user.email,
          password: "wrong_password"
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("メールアドレスまたはパスワードが正しくありません")
        expect(session[:user_id]).to be_nil
      end

      it "存在しないメールアドレスでログインに失敗する" do
        post "/api/v1/login", params: {
          email: "nonexistent@example.com",
          password: "password123"
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("メールアドレスまたはパスワードが正しくありません")
        expect(session[:user_id]).to be_nil
      end

      it "メールアドレスが空の場合、ログインに失敗する" do
        post "/api/v1/login", params: {
          email: "",
          password: "password123"
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("メールアドレスまたはパスワードが正しくありません")
        expect(session[:user_id]).to be_nil
      end

      it "パスワードが空の場合、ログインに失敗する" do
        user = create(:user, password: "password123")

        post "/api/v1/login", params: {
          email: user.email,
          password: ""
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("メールアドレスまたはパスワードが正しくありません")
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE /api/v1/logout" do
    context "正常系" do
      it "ログアウト後にセッションがクリアされる" do
        user = create(:user, password: "password123")

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
        expect(session[:user_id]).to eq(user.id)

        # ログアウト
        delete "/api/v1/logout"

        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to eq("ログアウトしました")
        expect(json_response["logged_in"]).to be false
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "GET /api/v1/logged_in" do
    context "正常系" do
      it "ログイン中の場合、ユーザー情報と家族情報を返す（家族に所属している場合）" do
        user = create(:user, password: "password123")
        family = create(:family, name: "テスト家族")
        create(:family_member, user: user, family: family)

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        # ログイン状態確認
        get "/api/v1/logged_in"

        expect(response).to have_http_status(:ok)
        expect(json_response["logged_in"]).to be true
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["user"]["name"]).to eq(user.name)
        expect(json_response["user"]["email"]).to eq(user.email)
        expect(json_response["family"]["id"]).to eq(family.id)
        expect(json_response["family"]["name"]).to eq("テスト家族")
      end

      it "ログイン中の場合、家族に所属していない場合はfamilyがnullになる" do
        user = create(:user, password: "password123")

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        # ログイン状態確認
        get "/api/v1/logged_in"

        expect(response).to have_http_status(:ok)
        expect(json_response["logged_in"]).to be true
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["family"]).to be_nil
      end

      it "未ログインの場合、logged_in: false を返す" do
        get "/api/v1/logged_in"

        expect(response).to have_http_status(:ok)
        expect(json_response["logged_in"]).to be false
        expect(json_response["user"]).to be_nil
      end
    end
  end
end

