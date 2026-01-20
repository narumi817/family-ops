class FamilyInvitationService
  class << self
    # 家族への招待メール送信処理を実行する
    # @param family [Family] 招待先の家族
    # @param inviter [User] 招待者（ログインユーザー）
    # @param email [String] 招待先メールアドレス
    # @return [Hash] 成功時: { success: true, invitation: FamilyInvitation }、
    #                失敗時: { success: false, errors: Hash, status: Symbol } または { success: false, error: String, status: Symbol }
    def invite(family:, inviter:, email:)
      email = email&.strip

      validation_result = validate_params(family, inviter, email)
      return validation_result unless validation_result[:success]

      invitation = FamilyInvitation.find_or_create_token(
        family: family,
        inviter: inviter,
        email: email
      )

      { success: true, invitation: invitation }
    end

    private

    # パラメータ・権限のバリデーション
    # @param family [Family]
    # @param inviter [User]
    # @param email [String]
    # @return [Hash]
    def validate_params(family, inviter, email)
      errors = {}

      if email.blank?
        errors[:email] = ["を入力してください"]
      elsif !email.match?(URI::MailTo::EMAIL_REGEXP)
        errors[:email] = ["は有効な形式ではありません"]
      end

      # 招待者が家族メンバーかどうか
      unless inviter.families.exists?(id: family.id)
        return { success: false, error: "この家族のメンバーではありません", status: :forbidden }
      end

      # すでに同じ家族に所属しているユーザーでないか
      if User.by_email(email).joins(:families).where(families: { id: family.id }).exists?
        errors[:email] ||= []
        errors[:email] << "は既に家族メンバーです"
      end

      return { success: false, errors: errors, status: :bad_request } if errors.any?

      { success: true }
    end
  end
end


