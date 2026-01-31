require 'rails_helper'

RSpec.describe "Api::V1::Family::Points", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "GET /api/v1/family/points/today" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:task1) { create(:task, family_id: nil, category: :childcare, points: 10) }
      let(:task2) { create(:task, family_id: nil, category: :housework, points: 20) }

      before do
        # ユーザーを家族に追加
        create(:family_member, user: user, family: family)

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "当日の累計ポイントを取得できる" do
        today = Date.current
        # 当日のログを作成
        create(:log, user: user, task: task1, performed_at: today.beginning_of_day + 1.hour)
        create(:log, user: user, task: task2, performed_at: today.beginning_of_day + 2.hours)

        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:ok)
        expect(json_response["user_id"]).to eq(user.id)
        expect(json_response["user_name"]).to eq(user.name)
        expect(json_response["today_points"]).to eq(30) # 10 + 20
        expect(json_response["date"]).to eq(today.to_s)
      end

      it "ログがない場合、ポイントは0になる" do
        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:ok)
        expect(json_response["today_points"]).to eq(0)
      end

      it "昨日のログは含まれない" do
        today = Date.current
        yesterday = 1.day.ago.to_date

        # 当日のログ
        create(:log, user: user, task: task1, performed_at: today.beginning_of_day + 1.hour)
        # 昨日のログ
        create(:log, user: user, task: task2, performed_at: yesterday.beginning_of_day + 1.hour)

        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:ok)
        expect(json_response["today_points"]).to eq(10) # 当日のログのみ
      end

      it "家族固有のポイントが設定されている場合、そのポイントを使用する" do
        today = Date.current
        # 家族固有のポイントを設定
        FamilyTaskPoint.create!(family: family, task: task1, points: 15)

        # 当日のログを作成
        create(:log, user: user, task: task1, performed_at: today.beginning_of_day + 1.hour)
        create(:log, user: user, task: task2, performed_at: today.beginning_of_day + 2.hours)

        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:ok)
        # task1は家族固有ポイント15、task2はデフォルトポイント20
        expect(json_response["today_points"]).to eq(35) # 15 + 20
      end

      it "他のユーザーのログは含まれない" do
        today = Date.current
        other_user = create(:user)
        create(:family_member, user: other_user, family: family)

        # 自分のログ
        create(:log, user: user, task: task1, performed_at: today.beginning_of_day + 1.hour)
        # 他のユーザーのログ
        create(:log, user: other_user, task: task2, performed_at: today.beginning_of_day + 2.hours)

        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:ok)
        expect(json_response["today_points"]).to eq(10) # 自分のログのみ
      end
    end

    context "異常系" do
      let(:user) { create(:user, password: "password123") }

      it "ログインしていない状態で呼ばれた場合、401を返す" do
        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end

      it "家族に所属していないユーザーの場合、404を返す" do
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        get "/api/v1/family/points/today"

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("家族が見つかりません")
      end
    end
  end
end

