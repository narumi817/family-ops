class SignupValidationService
  class << self
    # サインアップ共通のバリデーション
    # @param email [String] メールアドレス
    # @param name [String] ユーザー名
    # @param password [String] パスワード
    # @param password_confirmation [String] パスワード（確認用）
    # @param check_email_presence [Boolean] emailの必須チェックを行うか（招待サインアップではfalse）
    # @return [Hash] { success: true } または { success: false, errors: Hash, status: :bad_request }
    def validate_basic(email:, name:, password:, password_confirmation:, check_email_presence: true)
      errors = {}

      # 必須チェック
      errors[:email] = ["を入力してください"] if check_email_presence && email.blank?
      errors[:name] = ["を入力してください"] if name.blank?
      errors[:password] = ["を入力してください"] if password.blank?
      errors[:password_confirmation] = ["を入力してください"] if password_confirmation.blank?

      # メールアドレス形式チェック
      if email.present? && !email.match?(URI::MailTo::EMAIL_REGEXP)
        errors[:email] ||= []
        errors[:email] << "は有効な形式ではありません"
      end

      # パスワード一致チェック
      if password.present? && password_confirmation.present? && password != password_confirmation
        errors[:password_confirmation] ||= []
        errors[:password_confirmation] << "とパスワードが一致しません"
      end

      # 既存ユーザーチェック
      if email.present? && User.exists?(email: email)
        errors[:email] ||= []
        errors[:email] << "は既に使用されています"
      end

      return { success: false, errors: errors, status: :bad_request } if errors.any?

      { success: true }
    end
  end
end


