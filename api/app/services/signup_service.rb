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
      basic_result = SignupValidationService.validate_basic(
        email: email,
        name: name,
        password: password,
        password_confirmation: password_confirmation,
        check_email_presence: true
      )

      # family_nameチェック
      if family_name.blank?
        errors = basic_result[:errors] ? basic_result[:errors].dup : {}
        errors[:family_name] = ["を入力してください"]
        return { success: false, errors: errors, status: :bad_request }
      end

      return basic_result unless basic_result[:success]

      if basic_result[:errors]
        return { success: false, errors: basic_result[:errors], status: :bad_request }
      end

      { success: true }
    end
  end
end

