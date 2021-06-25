module Rack
  class Attack
    Rack::Attack.blocklist('bad-robots') do |req|
      req.ip if /\S+\.php/.match?(req.path)
    end
  end
end
