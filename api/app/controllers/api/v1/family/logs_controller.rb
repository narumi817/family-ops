module Api
  module V1
    module Family
      class LogsController < ApplicationController
        before_action :require_login

        # 家族のログ一覧を取得する
        # GET /api/v1/family/logs
        # @param date [String] 日付（YYYY-MM-DD形式、オプション）
        # @param start_date [String] 開始日（YYYY-MM-DD形式、オプション）
        # @param end_date [String] 終了日（YYYY-MM-DD形式、オプション）
        # @param page [Integer] ページ番号（デフォルト: 1、オプション）
        # @return [JSON] ログ一覧
        def index
          family_ids = current_user.families.pluck(:id)
          family_user_ids = FamilyMember.where(family_id: family_ids).pluck(:user_id).uniq
          logs = Log.for_family_with_filters(
            family_user_ids,
            date: params[:date],
            start_date: params[:start_date],
            end_date: params[:end_date]
          ).recent.page(page_number).per(20)

          render json: {
            logs: logs.map { |log| log_response(log) },
            current_page: logs.current_page,
            total_pages: logs.total_pages,
            total_count: logs.total_count
          }, status: :ok
        end

        private

        # ページ番号を取得する
        # @return [Integer] ページ番号（デフォルト: 1）
        def page_number
          params[:page].to_i.positive? ? params[:page].to_i : 1
        end

        # ログレスポンス用のハッシュを生成する
        # @param log [Log] ログオブジェクト
        # @return [Hash] レスポンス用のハッシュ
        def log_response(log)
          {
            id: log.id,
            task: {
              id: log.task.id,
              name: log.task.name,
              category: log.task.category,
              points: log.task.points
            },
            user: {
              id: log.user.id,
              name: log.user.name
            },
            performed_at: log.performed_at,
            notes: log.notes,
            created_at: log.created_at
          }
        end
      end
    end
  end
end

