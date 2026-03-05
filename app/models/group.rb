class Group < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users

  has_one_attached :image

  validates :name, presence: true, length: { maximum: 50 }
  validates :introduction, length: { maximum: 200 }
end
