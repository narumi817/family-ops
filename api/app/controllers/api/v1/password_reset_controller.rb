module Api
  module V1
    class PasswordResetController < ApplicationController
      # パスワードリセット用メールを送信する
      # POST /api/v1/password_reset
      # @param email [String] メールアドレス（必須）
      # @return [JSON] 成功メッセージ
      def create
        email = params[:email]&.strip

        if email.blank?
          return render json: { error: "メールアドレスを入力してください" }, status: :bad_request
        end

        unless email.match?(URI::MailTo::EMAIL_REGEXP)
          return render json: { error: "有効なメールアドレスを入力してください" }, status: :bad_request
        end

        PasswordResetService.send_reset_email(email)

        render json: { message: "パスワードリセット用のメールを送信しました" }, status: :ok
      end
    end
  end
end

