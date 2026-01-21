class FamilyInvitation < ApplicationRecord
  # アソシエーション
  belongs_to :family
  belongs_to :inviter, class_name: "User", foreign_key: :invite_user_id

  # バリデーション
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :token_expired_at, presence: true

  # スコープ
  scope :by_token, ->(token) { where(token: token) }
  scope :by_email, ->(email) { where(email: email) }
  scope :valid, -> { where("token_expired_at > ?", Time.current) }
  scope :unaccepted, -> { where(accepted_at: nil) }

  # トークンが有効かどうか
  def valid_token?
    token_expired_at > Time.current && accepted_at.nil?
  end

  class << self
    # 招待トークンを検証する
    # @param token [String] 招待トークン
    # @return [FamilyInvitation, nil] 有効な招待レコード、見つからないか無効な場合はnil
    def verify_token(token)
      invitation = by_token(token).unaccepted.first
      return nil unless invitation&.valid_token?

      invitation
    end

    # 招待トークンを生成する
    # @param family [Family] 招待先の家族
    # @param inviter [User] 招待者
    # @param email [String] 招待先メールアドレス
    # @return [FamilyInvitation]
    def generate_token(family:, inviter:, email:)
      token = SecureRandom.urlsafe_base64(32)
      expired_at = 24.hours.from_now

      create!(
        family: family,
        inviter: inviter,
        email: email,
        token: token,
        token_expired_at: expired_at
      )
    end

    # 既存の未受諾・有効な招待があれば再利用し、なければ新規作成する
    # @param family [Family]
    # @param inviter [User]
    # @param email [String]
    # @return [FamilyInvitation]
    def find_or_create_token(family:, inviter:, email:)
      invitation = by_email(email).where(family: family).unaccepted.valid.first
      return invitation if invitation

      generate_token(family: family, inviter: inviter, email: email)
    end
  end
end


