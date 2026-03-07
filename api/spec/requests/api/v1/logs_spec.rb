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

  describe "DELETE /api/v1/logs/:id" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:task) { create(:task) }
      let!(:log) { create(:log, user: user, task: task) }

      before do
        post "/api/v1/login", params: { email: user.email, password: "password123" }
      end

      it "自分が登録したログを論理削除し、204を返す" do
        expect {
          delete "/api/v1/logs/#{log.id}"
        }.not_to change(Log, :count)

        expect(response).to have_http_status(:no_content)
        expect(log.reload.deleted_at).to be_present
      end
    end

    context "異常系" do
      let(:user) { create(:user, password: "password123") }
      let(:other_user) { create(:user, email: "other@example.com", password: "password123") }
      let(:task) { create(:task) }
      let!(:own_log) { create(:log, user: user, task: task) }
      let!(:other_log) { create(:log, user: other_user, task: task) }

      before do
        post "/api/v1/login", params: { email: user.email, password: "password123" }
      end

      it "未ログインの場合、401を返す" do
        delete "/api/v1/logout"
        delete "/api/v1/logs/#{own_log.id}"

        expect(response).to have_http_status(:unauthorized)
        expect(own_log.reload.deleted_at).to be_nil
      end

      it "他人のログを指定した場合、404を返す（存在を漏らさない）" do
        delete "/api/v1/logs/#{other_log.id}"

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("ログが見つかりません")
        expect(other_log.reload.deleted_at).to be_nil
      end

      it "存在しないログIDを指定した場合、404を返す" do
        delete "/api/v1/logs/99999"

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("ログが見つかりません")
      end

      it "既に論理削除済みのログを指定した場合、404を返す" do
        own_log.update!(deleted_at: Time.current)

        delete "/api/v1/logs/#{own_log.id}"

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("ログが見つかりません")
      end
    end
  end
end

