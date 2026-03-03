class PasswordResetService
  class << self
    # パスワードリセット用メールを送信する
    # @param email [String] メールアドレス
    def send_reset_email(email)
      user = User.find_by(email: email)

      unless user&.password_digest.present?
        Rails.logger.info "[PasswordReset] パスワードリセット要求: 対象ユーザーが見つからないか、パスワード認証ユーザーではありません (email=#{email})"
        return
      end

      token = PasswordResetToken.find_or_create_for(user)
      PasswordResetMailer.reset_email(token).deliver_now
    end
  end
end

