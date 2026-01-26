class User < ApplicationRecord
  # パスワード認証の場合のみhas_secure_passwordを適用
  has_secure_password validations: false

  # アソシエーション
  has_many :logs, dependent: :restrict_with_error
  has_many :family_members, dependent: :destroy
  has_one :family_member, dependent: :destroy
  has_many :families, through: :family_members
  has_one :family, through: :family_member
  has_many :family_invitations, foreign_key: :invite_user_id, dependent: :destroy

  # バリデーション
  validates :name, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :password, presence: true, if: -> { password_digest.blank? && provider.blank? }
  validate :password_or_oauth_required
  validate :email_required_for_password_auth

  # スコープ
  # @param provider [String] 認証プロバイダー名（例: "google"）
  # @return [ActiveRecord::Relation] 指定されたプロバイダーで認証したユーザーのコレクション
  scope :by_provider, ->(provider) { where(provider: provider) }

  # @param email [String] メールアドレス
  # @return [ActiveRecord::Relation] 指定されたメールアドレスのユーザーのコレクション
  scope :by_email, ->(email) { where(email: email) }

  private

  # パスワード認証またはOAuth認証のどちらかが必須であることを検証する
  def password_or_oauth_required
    if password_digest.blank? && (provider.blank? || uid.blank?)
      errors.add(:base, "パスワード認証またはOAuth認証のどちらかが必要です。")
    end
  end

  # パスワード認証の場合はメールアドレスが必須であることを検証する
  def email_required_for_password_auth
    if password_digest.present? && email.blank?
      errors.add(:email, "パスワード認証の場合はメールアドレスが必要です")
    end
  end
end

