module Api
  module V1
    module Families
      class TasksController < ApplicationController
        before_action :require_login
        before_action :set_family
        before_action :verify_family_membership

        # 家族に紐づくタスク一覧を取得する
        # GET /api/v1/families/:id/tasks
        # @param category [String] カテゴリで絞り込み（childcare/housework、オプション）
        # @return [JSON] タスク一覧
        def index
          tasks = ::Task.for_family(@family.id)
          tasks = tasks.by_category(params[:category]) if params[:category].present?

          render json: {
            tasks: tasks.map { |task| task_response(task) }
          }, status: :ok
        end

        # タスクのポイントを更新する
        # PUT /api/v1/families/:id/tasks/:task_id/points
        # PATCH /api/v1/families/:id/tasks/:task_id/points
        # @param points [Integer] ポイント数（必須）
        # @return [JSON] 更新されたポイント情報
        def update_points
          task = ::Task.find_by(id: params[:id])
          unless task
            render json: { error: "タスクが見つかりません" }, status: :not_found
            return
          end

          result = FamilyTaskPointService.update_points(@family, task, params[:points])

          unless result[:success]
            error_message = result[:errors].first || "ポイントの更新に失敗しました"
            render json: { error: error_message, errors: result[:errors] }, status: :unprocessable_content
            return
          end

          family_task_point = result[:family_task_point]
          render json: {
            id: family_task_point.id,
            family_id: family_task_point.family_id,
            task_id: family_task_point.task_id,
            points: family_task_point.points,
            updated_at: family_task_point.updated_at
          }, status: :ok
        end

        private

        # 家族を設定する
        # @return [Family, nil] 家族オブジェクト
        def set_family
          @family = ::Family.find_by(id: params[:family_id])
          unless @family
            render json: { error: "家族が見つかりません" }, status: :not_found
          end
        end

        # ログインユーザーが指定された家族に所属しているか確認する
        # 未所属の場合は403 Forbiddenを返す
        def verify_family_membership
          unless current_user.family&.id == @family.id
            render json: { error: "この家族にアクセスする権限がありません" }, status: :forbidden
          end
        end

        # タスクレスポンス用のハッシュを生成する
        # @param task [Task] タスクオブジェクト
        # @return [Hash] レスポンス用のハッシュ
        def task_response(task)
          family_points = task.points_for_family(@family.id)
          {
            id: task.id,
            name: task.name,
            description: task.description,
            category: task.category,
            points: task.points,
            family_points: family_points,
            is_custom: task.family_id.present?
          }
        end
      end
    end
  end
end

