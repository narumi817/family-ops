require 'rails_helper'

RSpec.describe "Api::V1::Signup", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "POST /api/v1/signup/email" do
    context "正常系" do
      it "新しいメールアドレスで確認メールを送信できる" do
        email = "newuser@example.com"

        expect {
          post "/api/v1/signup/email", params: { email: email }
        }.to change(EmailVerification, :count).by(1)
          .and change(ActionMailer::Base.deliveries, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to eq("確認メールを送信しました")

        verification = EmailVerification.last
        expect(verification.email).to eq(email)
        expect(verification.user_id).to be_nil
        expect(verification.token).to be_present
        expect(verification.token_expired_at).to be > Time.current

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([email])
        expect(mail.subject).to eq("【FamilyOps】メールアドレス確認のお願い")
        expect(mail.body.encoded).to include(verification.token)
      end

      it "既に未確認のトークンがある場合は再送信する（新しいトークンは生成しない）" do
        email = "existing@example.com"
        existing_verification = EmailVerification.generate_token(email: email, user: nil)
        existing_token = existing_verification.token

        expect {
          post "/api/v1/signup/email", params: { email: email }
        }.not_to change(EmailVerification, :count)

        expect(ActionMailer::Base.deliveries.count).to eq(1)

        expect(response).to have_http_status(:ok)
        expect(json_response["message"]).to eq("確認メールを送信しました")

        # 既存のトークンが保持されていることを確認
        verification = EmailVerification.last
        expect(verification.token).to eq(existing_token)
      end
    end

    context "異常系" do
      it "メールアドレスが空の場合、400を返す" do
        post "/api/v1/signup/email", params: { email: "" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("メールアドレスを入力してください")
      end

      it "メールアドレスが未指定の場合、400を返す" do
        post "/api/v1/signup/email", params: {}

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("メールアドレスを入力してください")
      end

      it "無効なメールアドレスの場合、400を返す" do
        post "/api/v1/signup/email", params: { email: "invalid-email" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("有効なメールアドレスを入力してください")
      end

      it "既に登録済みのメールアドレスの場合、422を返す" do
        existing_user = create(:user, email: "existing@example.com")

        post "/api/v1/signup/email", params: { email: existing_user.email }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("このメールアドレスは使用できません")
      end

      it "メールアドレスに前後の空白がある場合、trimして処理する" do
        email = "  spaced@example.com  "

        post "/api/v1/signup/email", params: { email: email }

        expect(response).to have_http_status(:ok)
        verification = EmailVerification.last
        expect(verification.email).to eq("spaced@example.com")
      end
    end
  end
end

