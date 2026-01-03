class FamilyMember < ApplicationRecord
  # Enum定義
  enum :role, {
    other: 0,    # その他（デフォルト）
    mother: 1,   # 母親
    father: 2,   # 父親
    child: 3     # 子
  }

  # アソシエーション
  belongs_to :user
  belongs_to :family

  # コールバック
  after_initialize :set_default_role, if: :new_record?

  # バリデーション
  # Enumが自動的にバリデーションを提供するため、明示的なバリデーションは不要
  validates :user_id, uniqueness: { scope: :family_id, message: "は既にこの家族のメンバーです" }

  # スコープ
  # @param role [Symbol, Integer] 役割（:mother, :father, :child, :other または 1, 2, 3, 0）
  # @return [ActiveRecord::Relation] 指定された役割の家族メンバーのコレクション
  scope :by_role, ->(role) { where(role: role) }

  # @param family_id [Integer] 家族ID
  # @return [ActiveRecord::Relation] 指定された家族のメンバーのコレクション
  scope :by_family, ->(family_id) { where(family_id: family_id) }

  private

  # 新規レコード作成時にデフォルトの役割を設定する
  def set_default_role
    self.role ||= :other
  end
end

