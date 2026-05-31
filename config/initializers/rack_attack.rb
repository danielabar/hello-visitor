# frozen_string_literal: true

# Explicit MemoryStore rather than Rails.cache (Solid Cache): Solid Cache is configured
# for production but requires a dedicated Heroku Postgres add-on for its cache database,
# which this app doesn't have. MemoryStore is per-process — counters reset on restart and
# aren't shared across Puma workers — but that's acceptable for single-dyno abuse prevention.
# Follow-up: consolidate Solid Cache onto the primary DB so Rails.cache can be used instead.
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

Rack::Attack.throttle("visits/ip",
                      limit: ENV.fetch("RACK_ATTACK_VISITS_LIMIT", "60").to_i,
                      period: ENV.fetch("RACK_ATTACK_VISITS_PERIOD", "60").to_i) do |req|
  req.ip if req.path == "/visits" && req.post?
end

Rack::Attack.throttle("search/ip",
                      limit: ENV.fetch("RACK_ATTACK_SEARCH_LIMIT", "30").to_i,
                      period: ENV.fetch("RACK_ATTACK_SEARCH_PERIOD", "60").to_i) do |req|
  req.ip if req.path == "/search"
end
