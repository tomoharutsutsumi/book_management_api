class User < ApplicationRecord
  before_create :generate_account_number

  private

  def generate_account_number
    self.account_number ||= loop do
      token = SecureRandom.hex(5)
      break token unless User.exists?(account_number: token)
    end
  end
end
