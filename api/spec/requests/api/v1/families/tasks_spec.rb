require 'rails_helper'

RSpec.describe "Api::V1::Families::Tasks", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "GET /api/v1/families/:id/tasks" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:other_family) { create(:family) }

      before do
        # ユーザーを家族に追加
        create(:family_member, user: user, family: family)

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "家族に紐づくタスク一覧を取得できる（全家族共通 + 家族固有）" do
        # 全家族共通のタスク
        global_task1 = create(:task, family_id: nil, category: :childcare, points: 10)
        global_task2 = create(:task, family_id: nil, category: :housework, points: 20)

        # 家族固有のタスク
        custom_task = create(:task, family_id: family.id, category: :childcare, points: 30)

        # 他の家族のタスク（含まれない）
        other_family_task = create(:task, family_id: other_family.id, category: :childcare, points: 40)

        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:ok)
        expect(json_response["tasks"].length).to eq(3)
        task_ids = json_response["tasks"].map { |t| t["id"] }
        expect(task_ids).to include(global_task1.id)
        expect(task_ids).to include(global_task2.id)
        expect(task_ids).to include(custom_task.id)
        expect(task_ids).not_to include(other_family_task.id)
      end

      it "タスク情報に必要な項目が含まれる" do
        task = create(:task, family_id: nil, category: :childcare, points: 10, description: "テスト説明")

        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:ok)
        task_data = json_response["tasks"].find { |t| t["id"] == task.id }
        expect(task_data["id"]).to eq(task.id)
        expect(task_data["name"]).to eq(task.name)
        expect(task_data["description"]).to eq(task.description)
        expect(task_data["category"]).to eq("childcare")
        expect(task_data["points"]).to eq(10)
        expect(task_data["family_points"]).to eq(10)
        expect(task_data["is_custom"]).to eq(false)
      end

      it "家族固有のポイントが設定されている場合、family_pointsに反映される" do
        task = create(:task, family_id: nil, category: :childcare, points: 10)
        # 家族固有のポイントを設定
        FamilyTaskPoint.create!(family: family, task: task, points: 15)

        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:ok)
        task_data = json_response["tasks"].find { |t| t["id"] == task.id }
        expect(task_data["points"]).to eq(10) # デフォルトポイント
        expect(task_data["family_points"]).to eq(15) # 家族固有のポイント
      end

      it "家族固有のポイントが設定されていない場合、デフォルトポイントがfamily_pointsになる" do
        task = create(:task, family_id: nil, category: :childcare, points: 10)

        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:ok)
        task_data = json_response["tasks"].find { |t| t["id"] == task.id }
        expect(task_data["points"]).to eq(10)
        expect(task_data["family_points"]).to eq(10)
      end

      it "is_customが正しく設定される（全家族共通タスク）" do
        global_task = create(:task, family_id: nil, category: :childcare, points: 10)

        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:ok)
        task_data = json_response["tasks"].find { |t| t["id"] == global_task.id }
        expect(task_data["is_custom"]).to eq(false)
      end

      it "is_customが正しく設定される（家族固有タスク）" do
        custom_task = create(:task, family_id: family.id, category: :childcare, points: 30)

        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:ok)
        task_data = json_response["tasks"].find { |t| t["id"] == custom_task.id }
        expect(task_data["is_custom"]).to eq(true)
      end

      context "カテゴリで絞り込み" do
        let!(:childcare_task) { create(:task, family_id: nil, category: :childcare, points: 10) }
        let!(:housework_task) { create(:task, family_id: nil, category: :housework, points: 20) }

        it "childcareで絞り込みができる" do
          get "/api/v1/families/#{family.id}/tasks", params: { category: "childcare" }

          expect(response).to have_http_status(:ok)
          task_ids = json_response["tasks"].map { |t| t["id"] }
          expect(task_ids).to include(childcare_task.id)
          expect(task_ids).not_to include(housework_task.id)
        end

        it "houseworkで絞り込みができる" do
          get "/api/v1/families/#{family.id}/tasks", params: { category: "housework" }

          expect(response).to have_http_status(:ok)
          task_ids = json_response["tasks"].map { |t| t["id"] }
          expect(task_ids).not_to include(childcare_task.id)
          expect(task_ids).to include(housework_task.id)
        end

        it "カテゴリパラメータがない場合、全カテゴリのタスクを返す" do
          get "/api/v1/families/#{family.id}/tasks"

          expect(response).to have_http_status(:ok)
          task_ids = json_response["tasks"].map { |t| t["id"] }
          expect(task_ids).to include(childcare_task.id)
          expect(task_ids).to include(housework_task.id)
        end
      end
    end

    context "異常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:other_family) { create(:family) }

      it "ログインしていない状態で呼ばれた場合、401を返す" do
        get "/api/v1/families/#{family.id}/tasks"

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end

      it "存在しない家族IDを指定した場合、404を返す" do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        get "/api/v1/families/99999/tasks"

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("家族が見つかりません")
      end

      it "所属していない家族のIDを指定した場合、403を返す" do
        create(:family_member, user: user, family: family)
        other_family_user = create(:user)
        create(:family_member, user: other_family_user, family: other_family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        get "/api/v1/families/#{other_family.id}/tasks"

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("この家族にアクセスする権限がありません")
      end
    end
  end
end

