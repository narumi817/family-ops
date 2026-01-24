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
          return render json: { error: "このメールアドレスは使用できません" }, status: :unprocessable_content
        end

        # 確認トークンを取得または生成（既存の未確認トークンがあれば再利用）
        verification = EmailVerification.find_or_create_token(email: email_param, user: nil)

        # 確認メールを送信
        EmailVerificationMailer.confirmation_email(verification).deliver_now

        render json: { message: "確認メールを送信しました" }, status: :ok
      end

      # メールアドレス確認トークンを検証する
      # GET /api/v1/signup/verify
      # @param token [String] 確認トークン（必須）
      # @return [JSON] 検証結果（成功時はメールアドレスを返す）
      def verify
        token = params[:token].to_s

        if token.blank?
          return render json: { error: "トークンが指定されていません" }, status: :bad_request
        end

        verification = EmailVerification.update_verified(token)
        unless verification
          return render json: { error: "このリンクは無効か、有効期限が切れています" }, status: :bad_request
        end

        render json: {
          email: verification.email,
          verified: true
        }, status: :ok
      end

      # メールアドレス確認完了後にユーザー・家族を作成する
      # POST /api/v1/signup/complete
      # @param email [String] メールアドレス（必須、確認済みであること）
      # @param name [String] ユーザー名（必須）
      # @param password [String] パスワード（必須）
      # @param password_confirmation [String] パスワード（確認用、必須）
      # @param family_name [String] 家族名（必須）
      # @param role [String] 家族内での役割（optional, default: "unspecified"）
      # @return [JSON] 作成されたユーザー・家族情報
      def complete
        result = SignupService.complete(
          email: params[:email],
          name: params[:name],
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          family_name: params[:family_name],
          role: params[:role]
        )

        unless result[:success]
          payload = result[:errors] ? { errors: result[:errors] } : { error: result[:error] }
          return render json: payload, status: result[:status]
        end

        user = result[:user]
        family = result[:family]

        session[:user_id] = user.id

        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email
          },
          family: {
            id: family.id,
            name: family.name
          }
        }, status: :ok
      end
    end
  end
end

