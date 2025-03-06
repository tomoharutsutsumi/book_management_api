# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    title { 'Test Book' }
    status { :available }
  end
end
