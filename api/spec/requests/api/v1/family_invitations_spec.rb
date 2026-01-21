require "rails_helper"

RSpec.describe "Family invitations API", type: :request do
  before do
    host! "www.example.com"
  end

  describe "POST /api/v1/families/:id/invitations" do
    let(:family) { create(:family, name: "テスト家族") }
    let(:user) { create(:user, password: "password123") }

    before do
      create(:family_member, user: user, family: family)

      post "/api/v1/login", params: {
        email: user.email,
        password: "password123"
      }
    end

    context "正常系" do
      it "家族メンバーが有効なメールアドレスを指定すると招待メールを送信する" do
        email = "invitee@example.com"

        expect {
          post "/api/v1/families/#{family.id}/invitations", params: { email: email }
        }.to change(FamilyInvitation, :count).by(1)
         .and change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to have_http_status(:created)

        json = json_response
        expect(json["message"]).to eq("招待メールを送信しました")
        expect(json["invitation"]["email"]).to eq(email)
        expect(json["invitation"]["family_id"]).to eq(family.id)
      end

      it "同じメールアドレスに未受諾・有効な招待がある場合は再利用する" do
        email = "invitee@example.com"
        existing = FamilyInvitation.generate_token(family: family, inviter: user, email: email)

        expect {
          post "/api/v1/families/#{family.id}/invitations", params: { email: email }
        }.not_to change(FamilyInvitation, :count)

        expect(response).to have_http_status(:created)
        expect(json_response["invitation"]["id"]).to eq(existing.id)
      end
    end

    context "異常系" do
      it "ログインしていない場合、401を返す" do
        delete "/api/v1/logout"

        post "/api/v1/families/#{family.id}/invitations", params: { email: "test@example.com" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end

      it "家族メンバーでないユーザーが招待しようとした場合、403を返す" do
        other_family = create(:family)
        other_user = create(:user, password: "password123")
        create(:family_member, user: other_user, family: other_family)

        delete "/api/v1/logout"
        post "/api/v1/login", params: {
          email: other_user.email,
          password: "password123"
        }

        post "/api/v1/families/#{family.id}/invitations", params: { email: "test@example.com" }

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("この家族のメンバーではありません")
      end

      it "メールアドレスが空の場合、400を返す" do
        post "/api/v1/families/#{family.id}/invitations", params: { email: "" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]["email"]).to include("を入力してください")
      end

      it "メールアドレスの形式が不正な場合、400を返す" do
        post "/api/v1/families/#{family.id}/invitations", params: { email: "invalid-email" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]["email"]).to include("は有効な形式ではありません")
      end

      it "既に同じ家族のメンバーであるメールアドレスの場合、400を返す" do
        existing_user = create(:user, email: "member@example.com", password: "password123")
        create(:family_member, user: existing_user, family: family)

        post "/api/v1/families/#{family.id}/invitations", params: { email: existing_user.email }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]["email"]).to include("は既に家族メンバーです")
      end
    end
  end

  describe "GET /api/v1/invitations/verify" do
    let(:family) { create(:family, name: "テスト家族") }
    let(:inviter) { create(:user, name: "招待者", email: "inviter@example.com", password: "password123") }
    let(:email) { "invitee@example.com" }

    context "正常系" do
      it "有効なトークンで招待情報を取得できる" do
        invitation = FamilyInvitation.generate_token(family: family, inviter: inviter, email: email)

        get "/api/v1/invitations/verify", params: { token: invitation.token }

        expect(response).to have_http_status(:ok)
        json = json_response
        expect(json["email"]).to eq(email)
        expect(json["family"]["id"]).to eq(family.id)
        expect(json["family"]["name"]).to eq("テスト家族")
        expect(json["inviter"]["id"]).to eq(inviter.id)
        expect(json["inviter"]["name"]).to eq("招待者")
        expect(json["invited"]).to be true
      end
    end

    context "異常系" do
      it "トークンが指定されていない場合、400を返す" do
        get "/api/v1/invitations/verify", params: { token: "" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("トークンが指定されていません")
      end

      it "存在しないトークンの場合、400を返す" do
        get "/api/v1/invitations/verify", params: { token: "non-existent-token" }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end

      it "有効期限切れのトークンの場合、400を返す" do
        invitation = FamilyInvitation.generate_token(family: family, inviter: inviter, email: email)
        invitation.update!(token_expired_at: 1.hour.ago)

        get "/api/v1/invitations/verify", params: { token: invitation.token }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end

      it "既に受諾済みのトークンの場合、400を返す" do
        invitation = FamilyInvitation.generate_token(family: family, inviter: inviter, email: email)
        invitation.update!(accepted_at: Time.current)

        get "/api/v1/invitations/verify", params: { token: invitation.token }

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("このリンクは無効か、有効期限が切れています")
      end
    end
  end
end


