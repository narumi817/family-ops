module Api
  module V1
    class SessionsController < ApplicationController
      # ログイン処理
      # POST /api/v1/login
      # @param email [String] メールアドレス
      # @param password [String] パスワード
      # @return [JSON] ユーザー情報（成功時）またはエラーメッセージ（失敗時）
      def create
        user = User.find_by(email: params[:email])
        
        return render_unauthorized unless user&.authenticate(params[:password])

        session[:user_id] = user.id
        render_user_info(user)
      end

      # ログアウト処理
      # DELETE /api/v1/logout
      # @return [JSON] 成功メッセージ
      def destroy
        session.delete(:user_id)
        render json: { message: "ログアウトしました", logged_in: false }, status: :ok
      end

      # ログイン状態確認
      # GET /api/v1/logged_in
      # @return [JSON] ユーザー情報（ログイン中）または logged_in: false（未ログイン）
      def logged_in
        return render_logged_out unless current_user

        render_user_info(current_user)
      end

      private

      # ユーザー情報をJSONで返す
      # @param user [User] ユーザーオブジェクト
      def render_user_info(user)
        family = user.family
        family_data = family ? {
          id: family.id,
          name: family.name
        } : nil

        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email
          },
          family: family_data,
          logged_in: true
        }, status: :ok
      end

      # 認証エラーを返す
      def render_unauthorized
        render json: { error: "メールアドレスまたはパスワードが正しくありません" }, status: :unauthorized
      end

      # 未ログイン状態を返す
      def render_logged_out
        render json: { logged_in: false }, status: :ok
      end
    end
  end
end

