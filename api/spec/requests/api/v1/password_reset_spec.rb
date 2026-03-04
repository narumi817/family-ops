require "rails_helper"

RSpec.describe "Api::V1::PasswordReset", type: :request do
  before do
    host! "www.example.com"
    ActionMailer::Base.deliveries.clear
  end

  describe "POST /api/v1/password_reset" do
    context "正常系" do
      it "パスワード認証ユーザーに対してリセットメールを送信できる" do
        user = create(:user, email: "user@example.com", password: "password123", password_confirmation: "password123")

        expect {
          post "/api/v1/password_reset", params: { email: user.email }
        }.to change(PasswordResetToken, :count).by(1)
          .and change(ActionMailer::Base.deliveries, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to eq("パスワードリセット用のメールを送信しました")

        token = PasswordResetToken.last
        expect(token.user).to eq(user)
        expect(token.token).to be_present
        expect(token.token_expired_at).to be > Time.current
        expect(token.used_at).to be_nil

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([user.email])
        expect(mail.subject).to eq("【FamilyOps】パスワード再設定のご案内")
        expect(mail.body.encoded).to include(token.token)
        expect(mail.body.encoded).to include("/password-reset?token=")
      end

      it "存在しないメールアドレスの場合も成功レスポンスを返す（メールは送信しない）" do
        expect {
          post "/api/v1/password_reset", params: { email: "unknown@example.com" }
        }.not_to change(PasswordResetToken, :count)

        expect(ActionMailer::Base.deliveries.count).to eq(0)
        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to eq("パスワードリセット用のメールを送信しました")
      end
    end

    context "異常系" do
      it "メールアドレスが空の場合、400を返す" do
        post "/api/v1/password_reset", params: { email: "" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("メールアドレスを入力してください")
      end

      it "メールアドレスが未指定の場合、400を返す" do
        post "/api/v1/password_reset", params: {}

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("メールアドレスを入力してください")
      end

      it "無効なメールアドレスの場合、400を返す" do
        post "/api/v1/password_reset", params: { email: "invalid-email" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("有効なメールアドレスを入力してください")
      end
    end
  end

  describe "GET /api/v1/password_reset/verify" do
    context "正常系" do
      it "有効なトークンの場合、メールアドレスを返す" do
        user = create(:user, email: "user@example.com", password: "password123", password_confirmation: "password123")
        token = PasswordResetToken.create!(
          user: user,
          token: "valid-token",
          token_expired_at: 1.hour.from_now
        )

        get "/api/v1/password_reset/verify", params: { token: token.token }

        expect(response).to have_http_status(:ok)
        expect(json_response["email"]).to eq(user.email)
      end
    end

    context "異常系" do
      it "トークンが未指定の場合、400を返す" do
        get "/api/v1/password_reset/verify", params: {}

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("トークンが指定されていません")
      end

      it "存在しないトークンの場合、400を返す" do
        get "/api/v1/password_reset/verify", params: { token: "unknown-token" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end

      it "期限切れトークンの場合、400を返す" do
        user = create(:user, email: "expired@example.com", password: "password123", password_confirmation: "password123")
        token = PasswordResetToken.create!(
          user: user,
          token: "expired-token",
          token_expired_at: 1.hour.ago
        )

        get "/api/v1/password_reset/verify", params: { token: token.token }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end

      it "既に使用済みのトークンの場合、400を返す" do
        user = create(:user, email: "used@example.com", password: "password123", password_confirmation: "password123")
        token = PasswordResetToken.create!(
          user: user,
          token: "used-token",
          token_expired_at: 1.hour.from_now,
          used_at: Time.current
        )

        get "/api/v1/password_reset/verify", params: { token: token.token }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end
    end
  end
end

