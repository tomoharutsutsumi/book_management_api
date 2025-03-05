FactoryBot.define do
  factory :transaction do
    association :user
    association :book
    transaction_type { :borrow }
    fee_amount { 0.0 }
  end
end
