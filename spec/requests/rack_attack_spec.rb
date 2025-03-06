# spec/requests/rack_attack_spec.rb
require 'rails_helper'

RSpec.describe "Rack::Attack Rate Limiting", type: :request do
  let!(:user) { create(:user, balance: 100.0) }

  before do
    Rack::Attack.cache.store.clear
  end

  it "throttles requests after reaching the limit" do
    limit = 20

    limit.times do |i|
      get "/api/v1/users/#{user.id}/reports?period=monthly", as: :json
      expect(response.status).not_to eq(429), "Request #{i+1} unexpectedly throttled"
    end

    get "/api/v1/users/#{user.id}/reports?period=monthly", as: :json
    expect(response.status).to eq(429)
  end
end
