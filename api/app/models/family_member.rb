class FamilyMember < ApplicationRecord
  # Enum定義
  enum :role, {
    unspecified: 0, # 指定なし（デフォルト）
    mother: 1,      # 母親
    father: 2,      # 父親
    child: 3,       # 子
    other: 4        # その他
  }

  # アソシエーション
  belongs_to :user
  belongs_to :family

  # コールバック
  after_initialize :set_default_role, if: :new_record?

  # バリデーション
  # Enumが自動的にバリデーションを提供するため、明示的なバリデーションは不要
  # 1ユーザーは1家族にしか所属できない（user_idのユニーク制約）
  validates :user_id, uniqueness: { message: "は既に他の家族に所属しています" }

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
    self.role ||= :unspecified
  end
end

