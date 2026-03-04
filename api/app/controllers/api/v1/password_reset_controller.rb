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

      # パスワードリセットトークンを検証する
      # GET /api/v1/password_reset/verify
      # @param token [String] トークン（必須）
      # @return [JSON] 検証結果（成功時はメールアドレスを返す）
      def verify
        token_param = params[:token].to_s

        if token_param.blank?
          return render json: { error: "トークンが指定されていません" }, status: :bad_request
        end

        reset_token = PasswordResetService.verify_token(token_param)

        unless reset_token
          return render json: { error: "このリンクは無効か、有効期限が切れています" }, status: :bad_request
        end

        render json: {
          email: reset_token.user.email
        }, status: :ok
      end
    end
  end
end

