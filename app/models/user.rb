class User < ApplicationRecord
  before_create :generate_account_number

  validates :account_number, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  private

  def generate_account_number
    self.account_number ||= loop do
      token = SecureRandom.hex(5)
      break token unless User.exists?(account_number: token)
    end
  end
end
