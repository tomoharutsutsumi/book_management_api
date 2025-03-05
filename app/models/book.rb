class Book < ApplicationRecord
  enum status: { available: 0, borrowed: 1 }

  has_many :transactions, dependent: :destroy

  # heroku run rails db:seed?
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
end
