require 'rails_helper'

RSpec.describe "Api::V1::Families::Tasks::Points", type: :request do
  before do
    host! 'www.example.com'
  end

  describe "PUT /api/v1/families/:id/tasks/:task_id/points" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:task) { create(:task, family_id: nil, category: :childcare, points: 10) }

      before do
        # ユーザーを家族に追加
        create(:family_member, user: user, family: family)

        # ログイン
        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "家族固有のポイントを新規作成できる" do
        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: 15
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["points"]).to eq(15)
        expect(json_response["family_id"]).to eq(family.id)
        expect(json_response["task_id"]).to eq(task.id)

        # DBに保存されているか確認
        family_task_point = FamilyTaskPoint.find_by(family_id: family.id, task_id: task.id)
        expect(family_task_point).to be_present
        expect(family_task_point.points).to eq(15)
      end

      it "既存の家族固有ポイントを更新できる" do
        # 既存のポイントを設定
        existing_point = FamilyTaskPoint.create!(
          family: family,
          task: task,
          points: 10
        )

        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: 20
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["points"]).to eq(20)
        expect(json_response["id"]).to eq(existing_point.id)

        # DBが更新されているか確認
        existing_point.reload
        expect(existing_point.points).to eq(20)
      end

      it "ポイントを0に設定できる" do
        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: 0
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["points"]).to eq(0)
      end
    end

    context "異常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:other_family) { create(:family) }
      let(:task) { create(:task, family_id: nil, category: :childcare, points: 10) }

      it "ログインしていない状態で呼ばれた場合、401を返す" do
        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: 15
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to be_present
      end

      it "存在しない家族IDを指定した場合、404を返す" do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        put "/api/v1/families/99999/tasks/#{task.id}/points", params: {
          points: 15
        }

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

        put "/api/v1/families/#{other_family.id}/tasks/#{task.id}/points", params: {
          points: 15
        }

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("この家族にアクセスする権限がありません")
      end

      it "存在しないタスクIDを指定した場合、404を返す" do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        put "/api/v1/families/#{family.id}/tasks/99999/points", params: {
          points: 15
        }

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("タスクが見つかりません")
      end

      it "pointsパラメータがない場合、422を返す" do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {}

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["error"]).to eq("有効なポイント数を指定してください")
      end

      it "負のポイントを指定した場合、422を返す" do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: -1
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["error"]).to eq("有効なポイント数を指定してください")
      end

      it "文字列のポイントを指定した場合、422を返す" do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }

        put "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: "invalid"
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response["error"]).to eq("有効なポイント数を指定してください")
      end
    end
  end

  describe "PATCH /api/v1/families/:id/tasks/:task_id/points" do
    context "正常系" do
      let(:user) { create(:user, password: "password123") }
      let(:family) { create(:family) }
      let(:task) { create(:task, family_id: nil, category: :childcare, points: 10) }

      before do
        create(:family_member, user: user, family: family)

        post "/api/v1/login", params: {
          email: user.email,
          password: "password123"
        }
      end

      it "PUTと同じようにポイントを更新できる" do
        patch "/api/v1/families/#{family.id}/tasks/#{task.id}/points", params: {
          points: 15
        }

        expect(response).to have_http_status(:ok)
        expect(json_response["points"]).to eq(15)
      end
    end
  end
end

