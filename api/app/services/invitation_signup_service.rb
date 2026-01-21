class InvitationSignupService
  class << self
    # 招待経由のサインアップ完了処理を実行する
    # @param token [String] 招待トークン
    # @param name [String] ユーザー名
    # @param password [String] パスワード
    # @param password_confirmation [String] パスワード（確認用）
    # @return [Hash] 成功時は { success: true, user: User, family: Family }、
    #               失敗時は { success: false, errors: Hash, status: Symbol } または { success: false, error: String, status: Symbol }
    def complete(token:, name:, password:, password_confirmation:)
      token = token.to_s
      name = name&.strip

      # トークン必須チェック
      if token.blank?
        return { success: false, error: "トークンが指定されていません", status: :bad_request }
      end

      invitation = FamilyInvitation.verify_token(token)
      unless invitation
        return { success: false, error: "このリンクは無効か、有効期限が切れています", status: :bad_request }
      end

      email = invitation.email
      family = invitation.family

      # パラメータバリデーション
      validation_result = validate_params(email, name, password, password_confirmation)
      return validation_result unless validation_result[:success]

      user = nil

      ActiveRecord::Base.transaction do
        user = User.create!(
          name: name,
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          email_verified_at: Time.current
        )

        FamilyMember.create!(
          user: user,
          family: family
        )

        invitation.update!(accepted_at: Time.current)
      end

      { success: true, user: user, family: family }
    rescue ActiveRecord::RecordInvalid => e
      record = e.record
      errors = record.errors.to_hash(true)
      { success: false, errors: errors, status: :bad_request }
    end

    private

    # パラメータのバリデーション
    # emailは招待情報から取得するため、emailの必須チェックは行わない
    # @param email [String] 招待先メールアドレス（招待レコードから取得）
    # @param name [String] ユーザー名
    # @param password [String] パスワード
    # @param password_confirmation [String] パスワード（確認用）
    # @return [Hash] バリデーション結果（{ success: true } または { success: false, errors: Hash, status: Symbol }）
    def validate_params(email, name, password, password_confirmation)
      SignupValidationService.validate_basic(
        email: email,
        name: name,
        password: password,
        password_confirmation: password_confirmation,
        check_email_presence: false
      )
    end
  end
end


