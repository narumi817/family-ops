class SignupService
  class << self
    # サインアップ完了処理を実行する
    # @param email [String] メールアドレス
    # @param name [String] ユーザー名
    # @param password [String] パスワード
    # @param password_confirmation [String] パスワード（確認用）
    # @param family_name [String] 家族名
    # @param role [String] 家族内での役割（デフォルト: "other"）
    # @return [Hash] 成功時は { success: true, user: User, family: Family }、
    #               失敗時は { success: false, errors: Hash, status: Symbol } または { success: false, error: String, status: Symbol }
    def complete(email:, name:, password:, password_confirmation:, family_name:, role: "other")
      email = email&.strip
      name = name&.strip
      family_name = family_name&.strip
      role = role.to_s

      # バリデーション
      validation_result = validate_params(email, name, password, password_confirmation, family_name)
      return validation_result unless validation_result[:success]

      # メールアドレス確認済みであることをチェック
      verification = EmailVerification.by_email(email).where.not(verified_at: nil).order(verified_at: :desc).first
      unless verification
        return { success: false, error: "メールアドレスが確認されていません", status: :bad_request }
      end

      user = nil
      family = nil

      ActiveRecord::Base.transaction do
        user = User.create!(
          name: name,
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          email_verified_at: verification.verified_at || Time.current
        )

        family = Family.create!(name: family_name)

        FamilyMember.create!(
          user: user,
          family: family,
          role: role
        )

        # 使い終わった確認レコードは削除
        verification.destroy!
      end

      { success: true, user: user, family: family }
    rescue ActiveRecord::RecordInvalid => e
      # モデルバリデーションエラーをフィールドごとのエラー形式で返す
      record = e.record
      errors = record.errors.to_hash(true)
      { success: false, errors: errors, status: :bad_request }
    end

    private

    # パラメータのバリデーション
    # @param email [String] メールアドレス
    # @param name [String] ユーザー名
    # @param password [String] パスワード
    # @param password_confirmation [String] パスワード（確認用）
    # @param family_name [String] 家族名
    # @return [Hash] バリデーション結果
    def validate_params(email, name, password, password_confirmation, family_name)
      errors = {}

      # 必須チェック
      errors[:email] = ["を入力してください"] if email.blank?
      errors[:name] = ["を入力してください"] if name.blank?
      errors[:password] = ["を入力してください"] if password.blank?
      errors[:password_confirmation] = ["を入力してください"] if password_confirmation.blank?
      errors[:family_name] = ["を入力してください"] if family_name.blank?

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

