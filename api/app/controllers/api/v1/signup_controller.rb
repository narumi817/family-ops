module Api
  module V1
    class SignupController < ApplicationController
      # メールアドレスを登録し、確認メールを送信する
      # POST /api/v1/signup/email
      # @param email [String] メールアドレス（必須）
      # @return [JSON] 成功メッセージ
      def email
        email_param = params[:email]&.strip

        if email_param.blank?
          return render json: { error: "メールアドレスを入力してください" }, status: :bad_request
        end

        unless email_param.match?(URI::MailTo::EMAIL_REGEXP)
          return render json: { error: "有効なメールアドレスを入力してください" }, status: :bad_request
        end

        # 既にユーザーが登録されているかチェック
        if User.exists?(email: email_param)
          return render json: { error: "このメールアドレスは使用できません" }, status: :unprocessable_entity
        end

        # 確認トークンを取得または生成（既存の未確認トークンがあれば再利用）
        verification = EmailVerification.find_or_create_token(email: email_param, user: nil)

        # 確認メールを送信
        EmailVerificationMailer.confirmation_email(verification).deliver_now

        render json: { message: "確認メールを送信しました" }, status: :ok
      end
    end
  end
end

