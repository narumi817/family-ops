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
end

