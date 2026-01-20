class Family < ApplicationRecord
  # アソシエーション
  has_many :family_members, dependent: :destroy
  has_many :users, through: :family_members
  has_many :tasks, dependent: :destroy
  has_many :family_task_points, dependent: :destroy
  has_many :shared_tasks, through: :family_task_points, source: :task
  has_many :family_invitations, dependent: :destroy

  # バリデーション
  validates :name, presence: true
end

