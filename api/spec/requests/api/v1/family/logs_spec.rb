require 'rails_helper'

RSpec.describe "Api::V1::Family::Logs", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "GET /api/v1/family/logs" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:other_user) { create(:user) }
      let(:task) { create(:task) }

      before do
        # ユーザーを家族に追加
        create(:family_member, user: user, family: family)
        create(:family_member, user: other_user, family: family)

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "家族のログ一覧を最新順で取得できる" do
        # ログを作成（時間差をつけて）
        log1 = create(:log, user: user, task: task, performed_at: 2.days.ago)
        log2 = create(:log, user: other_user, task: task, performed_at: 1.day.ago)
        log3 = create(:log, user: user, task: task, performed_at: Time.current)

        get "/api/v1/family/logs"

        expect(response).to have_http_status(:ok)
        expect(json_response["logs"].length).to eq(3)
        expect(json_response["logs"][0]["id"]).to eq(log3.id) # 最新順
        expect(json_response["logs"][1]["id"]).to eq(log2.id)
        expect(json_response["logs"][2]["id"]).to eq(log1.id)
      end

      it "ログにtaskとuserの情報が含まれる" do
        log = create(:log, user: user, task: task)

        get "/api/v1/family/logs"

        expect(response).to have_http_status(:ok)
        log_data = json_response["logs"].find { |l| l["id"] == log.id }
        expect(log_data["task"]["id"]).to eq(task.id)
        expect(log_data["task"]["name"]).to eq(task.name)
        expect(log_data["task"]["category"]).to eq(task.category)
        expect(log_data["task"]["points"]).to eq(task.points)
        expect(log_data["user"]["id"]).to eq(user.id)
        expect(log_data["user"]["name"]).to eq(user.name)
      end

      it "日付を指定してログを絞り込める" do
        target_date = Date.today
        log_today = create(:log, user: user, task: task, performed_at: target_date.beginning_of_day)
        log_yesterday = create(:log, user: user, task: task, performed_at: 1.day.ago)

        get "/api/v1/family/logs", params: { date: target_date.to_s }

        expect(response).to have_http_status(:ok)
        log_ids = json_response["logs"].map { |l| l["id"] }
        expect(log_ids).to include(log_today.id)
        expect(log_ids).not_to include(log_yesterday.id)
      end

      it "日付範囲を指定してログを絞り込める" do
        start_date = 3.days.ago.to_date
        end_date = 1.day.ago.to_date

        log_in_range = create(:log, user: user, task: task, performed_at: 2.days.ago)
        log_before = create(:log, user: user, task: task, performed_at: 4.days.ago)
        log_after = create(:log, user: user, task: task, performed_at: Time.current)

        get "/api/v1/family/logs", params: {
          start_date: start_date.to_s,
          end_date: end_date.to_s
        }

        expect(response).to have_http_status(:ok)
        log_ids = json_response["logs"].map { |l| l["id"] }
        expect(log_ids).to include(log_in_range.id)
        expect(log_ids).not_to include(log_before.id)
        expect(log_ids).not_to include(log_after.id)
      end

      it "start_dateのみ指定した場合、start_dateから現在日時までで絞り込める" do
        start_date = 2.days.ago.to_date

        log_after_start = create(:log, user: user, task: task, performed_at: 1.day.ago)
        log_before_start = create(:log, user: user, task: task, performed_at: 3.days.ago)
        log_current = create(:log, user: user, task: task, performed_at: Time.current)

        get "/api/v1/family/logs", params: {
          start_date: start_date.to_s
        }

        expect(response).to have_http_status(:ok)
        log_ids = json_response["logs"].map { |l| l["id"] }
        expect(log_ids).to include(log_after_start.id)
        expect(log_ids).to include(log_current.id)
        expect(log_ids).not_to include(log_before_start.id)
      end

      it "end_dateのみ指定した場合、絞り込まない" do
        end_date = 1.day.ago.to_date

        log_before_end = create(:log, user: user, task: task, performed_at: 2.days.ago)
        log_after_end = create(:log, user: user, task: task, performed_at: Time.current)

        get "/api/v1/family/logs", params: {
          end_date: end_date.to_s
        }

        expect(response).to have_http_status(:ok)
        log_ids = json_response["logs"].map { |l| l["id"] }
        expect(log_ids).to include(log_before_end.id)
        expect(log_ids).to include(log_after_end.id)
      end

      it "ページングが機能する（20件ずつ）" do
        # 25件のログを作成
        25.times do |i|
          create(:log, user: user, task: task, performed_at: i.hours.ago)
        end

        get "/api/v1/family/logs", params: { page: 1 }

        expect(response).to have_http_status(:ok)
        expect(json_response["logs"].length).to eq(20)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["total_pages"]).to eq(2)
        expect(json_response["total_count"]).to eq(25)
      end

      it "2ページ目を取得できる" do
        # 25件のログを作成
        25.times do |i|
          create(:log, user: user, task: task, performed_at: i.hours.ago)
        end

        get "/api/v1/family/logs", params: { page: 2 }

        expect(response).to have_http_status(:ok)
        expect(json_response["logs"].length).to eq(5)
        expect(json_response["current_page"]).to eq(2)
      end

      it "他の家族のログは含まれない" do
        other_family = create(:family)
        other_family_user = create(:user)
        create(:family_member, user: other_family_user, family: other_family)

        log_family = create(:log, user: user, task: task)
        log_other_family = create(:log, user: other_family_user, task: task)

        get "/api/v1/family/logs"

        expect(response).to have_http_status(:ok)
        log_ids = json_response["logs"].map { |l| l["id"] }
        expect(log_ids).to include(log_family.id)
        expect(log_ids).not_to include(log_other_family.id)
      end
    end

    context "異常系" do
      let(:user) { create(:user, password: "password123") }

      it "ログインしていない状態で呼ばれた場合、401を返す" do
        get "/api/v1/family/logs"

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end

      it "無効な日付形式の場合、エラーにならず全件取得する" do
        family = create(:family)
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        get "/api/v1/family/logs", params: { date: "invalid-date" }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end

