module Api
  module V1
    class LogsController < ApplicationController
      before_action :require_login

      # 家事ログを投稿する
      # POST /api/v1/logs
      # @param task_id [Integer] タスクID（必須）
      # @param performed_at [String] 実行日時（オプション、空の場合は現在日時）
      # @param notes [String] メモ（オプション）
      # @return [JSON] 作成されたログ情報
      def create
        log = current_user.logs.build(log_params)

        return render json: { errors: log.errors.full_messages }, status: :unprocessable_content unless log.save

        render json: log_response(log), status: :created
      end

      private

      # ログ作成用のパラメータを取得する
      # performed_atが空の場合は現在日時を設定
      # @return [ActionController::Parameters] 許可されたパラメータ
      def log_params
        permitted_params = params.require(:log).permit(:task_id, :performed_at, :notes)
        permitted_params[:performed_at] = Time.current if permitted_params[:performed_at].blank?
        permitted_params
      end

      # ログレスポンス用のハッシュを生成する
      # @param log [Log] ログオブジェクト
      # @return [Hash] レスポンス用のハッシュ
      def log_response(log)
        {
          id: log.id,
          task_id: log.task_id,
          task_name: log.task.name,
          performed_at: log.performed_at,
          notes: log.notes,
          created_at: log.created_at
        }
      end
    end
  end
end

