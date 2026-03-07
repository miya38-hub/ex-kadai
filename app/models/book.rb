class Book < ApplicationRecord
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  validates :title, presence: true
  validates :body,  presence: true, length: { maximum: 200 }
  validates :score, presence: true, inclusion: { in: 1.0..5.0 }
  validates :category, presence: true
end
