class ApplicationController < ActionController::API
  include ActionController::Cookies

  protected

  # 現在のユーザーを取得する
  # セッションからuser_idを取得してUserを検索
  # @return [User, nil] ログイン中のユーザー、未ログインの場合はnil
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # ユーザーがログインしているかどうかを確認する
  # @return [Boolean] ログイン中の場合true、未ログインの場合false
  def logged_in?
    current_user.present?
  end

  # ログインが必要なアクションで使用する
  # 未ログインの場合は401 Unauthorizedを返す
  def require_login
    unless logged_in?
      render json: { error: "ログインが必要です" }, status: :unauthorized
    end
  end
end
