class Family < ApplicationRecord
  # アソシエーション
  has_many :family_members, dependent: :destroy
  has_many :users, through: :family_members
  has_many :family_task_points, dependent: :destroy
  has_many :tasks, through: :family_task_points

  # バリデーション
  validates :name, presence: true
end

