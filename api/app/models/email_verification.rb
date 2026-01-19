class EmailVerification < ApplicationRecord
  # アソシエーション
  belongs_to :user, optional: true

  # バリデーション
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :token_expired_at, presence: true

  # スコープ
  # @param token [String] 確認トークン
  # @return [ActiveRecord::Relation] 指定されたトークンの確認レコードのコレクション
  scope :by_token, ->(token) { where(token: token) }

  # @param email [String] メールアドレス
  # @return [ActiveRecord::Relation] 指定されたメールアドレスの確認レコードのコレクション
  scope :by_email, ->(email) { where(email: email) }

  # @return [ActiveRecord::Relation] 有効期限切れでない確認レコードのコレクション
  scope :valid, -> { where('token_expired_at > ?', Time.current) }

  # @return [ActiveRecord::Relation] 未確認の確認レコードのコレクション
  scope :unverified, -> { where(verified_at: nil) }

  # トークンが有効かどうかを確認する
  # @return [Boolean] トークンが有効期限以内かつ未確認の場合true
  def valid_token?
    token_expired_at > Time.current && verified_at.nil?
  end

  class << self
    # 確認トークンを生成する
    # @param email [String] メールアドレス
    # @param user [User, nil] ユーザー（オプション、ユーザー未作成時はnil）
    # @return [EmailVerification] 生成された確認レコード
    def generate_token(email:, user: nil)
      token = SecureRandom.urlsafe_base64(32)
      expired_at = 24.hours.from_now

      create!(
        user: user,
        email: email,
        token: token,
        token_expired_at: expired_at
      )
    end

    # トークンで確認レコードを検証する
    # @param token [String] 確認トークン
    # @return [EmailVerification, nil] 有効な確認レコード、見つからないか無効な場合はnil
    def verify_token(token)
      verification = by_token(token).unverified.first
      return nil unless verification&.valid_token?

      verification
    end

    # トークンを検証し、確認済みに更新する
    # @param token [String] 確認トークン
    # @return [EmailVerification, nil] 検証に成功した確認レコード、失敗した場合はnil
    def update_verified(token)
      verification = verify_token(token)
      return nil unless verification

      verification.update!(verified_at: Time.current) if verification.verified_at.nil?
      verification
    end

    # メールアドレスに対する確認トークンを取得または生成する
    # 既存の未確認トークンがあればそれを返し、なければ新規作成する
    # @param email [String] メールアドレス
    # @param user [User, nil] ユーザー（オプション、ユーザー未作成時はnil）
    # @return [EmailVerification] 確認レコード
    def find_or_create_token(email:, user: nil)
      existing_verification = by_email(email).unverified.valid.first
      return existing_verification if existing_verification

      generate_token(email: email, user: user)
    end
  end
end