require 'rails_helper'

RSpec.describe "Api::V1::Logs", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    host! 'www.example.com'
  end

  describe "POST /api/v1/logs" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:task) { create(:task) }

      before do
        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "タスクID、実行日時、メモを指定してログを作成できる" do
        performed_at = Time.zone.parse("2024-01-15 10:30:00")

        post "/api/v1/logs", params: {
          log: {
            task_id: task.id,
            performed_at: performed_at.iso8601,
            notes: "テストメモ"
          }
        }

        expect(response).to have_http_status(:created)
        expect(json_response["id"]).to be_present
        expect(json_response["task_id"]).to eq(task.id)
        expect(json_response["task_name"]).to eq(task.name)
        expect(Time.zone.parse(json_response["performed_at"])).to be_within(1.second).of(performed_at)
        expect(json_response["notes"]).to eq("テストメモ")
        expect(json_response["created_at"]).to be_present
      end

      it "実行日時を指定しない場合、現在日時が設定される" do
        freeze_time = Time.zone.parse("2024-01-15 12:00:00")
        travel_to freeze_time do
          post "/api/v1/logs", params: {
            log: {
              task_id: task.id,
              notes: "メモなし"
            }
          }

          expect(response).to have_http_status(:created)
          performed_at = Time.zone.parse(json_response["performed_at"])
          expect(performed_at).to be_within(1.second).of(freeze_time)
        end
      end

      it "メモが空でもログを作成できる" do
        post "/api/v1/logs", params: {
          log: {
            task_id: task.id,
            performed_at: Time.current.iso8601
          }
        }

        expect(response).to have_http_status(:created)
        expect(json_response["notes"]).to be_nil
      end

      it "実行日時が空文字の場合、現在日時が設定される" do
        freeze_time = Time.zone.parse("2024-01-15 12:00:00")
        travel_to freeze_time do
          post "/api/v1/logs", params: {
            log: {
              task_id: task.id,
              performed_at: ""
            }
          }

          expect(response).to have_http_status(:created)
          performed_at = Time.zone.parse(json_response["performed_at"])
          expect(performed_at).to be_within(1.second).of(freeze_time)
        end
      end
    end

    context "異常系" do
      let(:user) { create(:user, password: "password123") }
      let(:task) { create(:task) }

      before do
        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "ログインしていない状態で呼ばれた場合、401を返す" do
        # ログアウト
        delete "/api/v1/logout"

        post "/api/v1/logs", params: {
          log: {
            task_id: task.id
          }
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end

      it "タスクIDが指定されていない場合、422を返す" do
        post "/api/v1/logs", params: {
          log: {
            notes: "メモ"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["errors"]).to be_present
      end

      it "存在しないタスクIDが指定された場合、422を返す" do
        post "/api/v1/logs", params: {
          log: {
            task_id: 99999
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["errors"]).to be_present
      end
    end
  end
end

