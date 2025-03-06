# frozen_string_literal: true

# config/initializers/rack_attack.rb
module Rack
  # Provides rate limiting and blocklist functionality for Rack-based applications.
  class Attack
    # Throttle requests: limit each IP to 100 requests per 10 minutes.
    if Rails.env.test?
      throttle('req/ip', limit: 20, period: 1.minute, &:ip)
    else
      throttle('req/ip', limit: 100, period: 10.minutes, &:ip)
    end

    # Optionally, block certain aggressive IP addresses.
    # blocklist('block aggressive IP') do |req|
    #   # IP block condition
    #   req.ip if some_condition?(req.ip)
    # end

    # Safelist localhost for testing purposes.
    # safelist('allow-localhost') do |req|
    #   ['127.0.0.1', '::1'].include?(req.ip)
    # end
  end

  # Optionally log blocked requests for debugging.
  # ActiveSupport::Notifications.subscribe('rack.attack') do |_, _, _, _, req|
  #   Rails.logger.info "Rack::Attack blocked request: #{req.ip}" if req.env['rack.attack.match_type']
  # end
end
