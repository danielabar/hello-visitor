# frozen_string_literal: true

# Customizations to `features/support/env.rb` should go in this file

require "capybara/rails"
require "capybara/cuprite"
require "capybara/rspec"
require "capybara-screenshot/cucumber"

Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1920, 1080],
    js_errors: true,
    process_timeout: 60,
    timeout: 20,
    browser_options: {},
    inspector: ENV.fetch("SHOW_INSPECTOR", nil),
    headless: ENV["NOT_HEADLESS"] != "true"
  )
end

Capybara::Screenshot.autosave_on_failure = true
Capybara.asset_host = "http://localhost:3000"
Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot.register_driver(:cuprite) do |driver, path|
  driver.save_screenshot(path)
end

module Capybara
  module Screenshot
    def self.capybara_tmp_path
      Rails.root.join("tmp/screenshots")
    end
  end
end
