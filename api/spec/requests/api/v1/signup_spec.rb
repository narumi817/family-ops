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

  describe "GET /api/v1/signup/verify" do
    context "正常系" do
      it "有効なトークンでメールアドレスを検証できる" do
        verification = EmailVerification.generate_token(email: "verify@example.com", user: nil)

        get "/api/v1/signup/verify", params: { token: verification.token }

        expect(response).to have_http_status(:ok)
        expect(json_response["email"]).to eq("verify@example.com")
        expect(json_response["verified"]).to be true
        expect(verification.reload.verified_at).to be_present
      end
    end

    context "異常系" do
      it "トークンが指定されていない場合、400を返す" do
        get "/api/v1/signup/verify"

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("トークンが指定されていません")
      end

      it "存在しないトークンの場合、400を返す" do
        get "/api/v1/signup/verify", params: { token: "invalid-token" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end

      it "有効期限切れのトークンの場合、400を返す" do
        verification = EmailVerification.generate_token(email: "expired@example.com", user: nil)
        verification.update!(token_expired_at: 1.hour.ago)

        get "/api/v1/signup/verify", params: { token: verification.token }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end

      it "既に検証済みのトークンの場合、400を返す" do
        verification = EmailVerification.generate_token(email: "used@example.com", user: nil)
        verification.update!(verified_at: Time.current)

        get "/api/v1/signup/verify", params: { token: verification.token }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end
    end
  end

  describe "POST /api/v1/signup/complete" do
    let(:email) { "signup-complete@example.com" }

    context "正常系" do
      it "確認済みメールアドレスでユーザーと家族を作成し、ログイン状態にする" do
        # 確認済みメールアドレスを用意
        verification = EmailVerification.generate_token(email: email, user: nil)
        verification.update!(verified_at: Time.current)

        expect {
          post "/api/v1/signup/complete", params: {
            email: email,
            name: "サインアップユーザー",
            password: "password123",
            password_confirmation: "password123",
            family_name: "サインアップ家族",
            role: "mother"
          }
        }.to change(User, :count).by(1)
          .and change(Family, :count).by(1)
          .and change(FamilyMember, :count).by(1)

        expect(response).to have_http_status(:ok)

        json = json_response
        user = User.last
        family = Family.last

        expect(json["user"]["id"]).to eq(user.id)
        expect(json["user"]["name"]).to eq("サインアップユーザー")
        expect(json["user"]["email"]).to eq(email)

        expect(json["family"]["id"]).to eq(family.id)
        expect(json["family"]["name"]).to eq("サインアップ家族")

        expect(user.email_verified_at).to be_present
        expect(session[:user_id]).to eq(user.id)
        expect(EmailVerification.by_email(email)).to be_empty
      end
    end

    context "異常系" do
      it "必須パラメータが不足している場合、400を返す" do
        post "/api/v1/signup/complete", params: {
          email: "",
          name: "",
          password: "",
          password_confirmation: "",
          family_name: ""
        }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]).to be_present
        expect(json_response["errors"]["email"]).to include("を入力してください")
        expect(json_response["errors"]["name"]).to include("を入力してください")
        expect(json_response["errors"]["password"]).to include("を入力してください")
        expect(json_response["errors"]["password_confirmation"]).to include("を入力してください")
        expect(json_response["errors"]["family_name"]).to include("を入力してください")
      end

      it "メールアドレスが不正な形式の場合、400を返す" do
        post "/api/v1/signup/complete", params: {
          email: "invalid-email",
          name: "ユーザー",
          password: "password123",
          password_confirmation: "password123",
          family_name: "家族名"
        }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]).to be_present
        expect(json_response["errors"]["email"]).to include("は有効な形式ではありません")
      end

      it "パスワードと確認用パスワードが一致しない場合、400を返す" do
        post "/api/v1/signup/complete", params: {
          email: email,
          name: "ユーザー",
          password: "password123",
          password_confirmation: "different",
          family_name: "家族名"
        }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]).to be_present
        expect(json_response["errors"]["password_confirmation"]).to include("とパスワードが一致しません")
      end

      it "既にユーザーが存在するメールアドレスの場合、400を返す" do
        create(:user, email: email)

        post "/api/v1/signup/complete", params: {
          email: email,
          name: "ユーザー",
          password: "password123",
          password_confirmation: "password123",
          family_name: "家族名"
        }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]).to be_present
        expect(json_response["errors"]["email"]).to include("は既に使用されています")
      end

      it "メールアドレスが確認済みでない場合、400を返す" do
        # EmailVerification はあるが verified_at がNULL
        EmailVerification.generate_token(email: email, user: nil)

        post "/api/v1/signup/complete", params: {
          email: email,
          name: "ユーザー",
          password: "password123",
          password_confirmation: "password123",
          family_name: "家族名"
        }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("メールアドレスが確認されていません")
      end
    end
  end
end

