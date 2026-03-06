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

    # パスワードリセットトークンを検証する
    # @param token [String] トークン
    # @return [PasswordResetToken, nil] 有効なトークンがあれば返し、なければnil
    def verify_token(token)
      return nil if token.blank?

      PasswordResetToken.by_token(token).valid.first
    end

    # パスワードを更新する
    # @param token [String] トークン
    # @param password [String] 新しいパスワード
    # @param password_confirmation [String] 新しいパスワード（確認用）
    # @return [Hash] { success: true } または { success: false, errors: Hash, status: Symbol } / { success: false, error: String, status: Symbol }
    def complete_reset(token:, password:, password_confirmation:)
      token_str = token.to_s

      if token_str.blank?
        return { success: false, error: "トークンが指定されていません", status: :bad_request }
      end

      reset_token = verify_token(token_str)
      unless reset_token
        return { success: false, error: "このリンクは無効か、有効期限が切れています", status: :bad_request }
      end

      errors = {}

      if password.blank?
        errors[:password] = ["を入力してください"]
      end

      if password_confirmation.blank?
        errors[:password_confirmation] = ["を入力してください"]
      end

      if password.present? && password_confirmation.present? && password != password_confirmation
        errors[:password_confirmation] ||= []
        errors[:password_confirmation] << "とパスワードが一致しません"
      end

      return { success: false, errors: errors, status: :bad_request } if errors.any?

      user = reset_token.user

      unless user.update(password: password, password_confirmation: password_confirmation)
        return { success: false, errors: user.errors.to_hash(true), status: :bad_request }
      end

      reset_token.update!(used_at: Time.current)

      { success: true, user: user }
    end
  end
end

