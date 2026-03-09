class User < ApplicationRecord
  has_secure_password
  has_one_attached :profile_image
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :rooms, through: :entries
  has_many :owned_groups, class_name: "Group", foreign_key: :owner_id, dependent: :destroy

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  has_many :followings, through: :active_relationships, source: :followed

  has_many :followers, through: :passive_relationships, source: :follower

  def follow(user)
    active_relationships.find_or_create_by(followed_id: user.id)
  end

  def unfollow(user)
    active_relationships.where(followed_id: user.id).destroy_all
  end

  def following?(user)
    followings.include?(user)
  end

  def mutual_follow?(user)
    following?(user) && user.following?(self)
  end

  validates :name,
            presence: true,
            uniqueness: true,
            length: { in: 2..20 }
  validates :introduction,
            length: { maximum: 50 },
            allow_blank: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
