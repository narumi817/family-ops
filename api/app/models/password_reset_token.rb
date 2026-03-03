class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :token_expired_at, presence: true

  scope :by_token, ->(token) { where(token: token) }
  scope :unused, -> { where(used_at: nil) }
  scope :valid, -> { unused.where("token_expired_at > ?", Time.current) }

  class << self
    # パスワードリセット用のトークンを取得または生成する
    # @param user [User] リセット対象ユーザー
    # @return [PasswordResetToken] トークンレコード
    def find_or_create_for(user)
      existing = where(user: user).valid.first
      return existing if existing

      create!(
        user: user,
        token: SecureRandom.urlsafe_base64(32),
        token_expired_at: 1.hour.from_now
      )
    end
  end
end

