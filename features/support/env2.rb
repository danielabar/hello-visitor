# frozen_string_literal: true

require "capybara/rails"
require "capybara/cuprite"
require "capybara/rspec"
require "capybara-screenshot/rspec"

# Capybara.default_driver = :rack_test # For tests that don't require JavaScript
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite # For tests that need JavaScript

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1920, 1080],
    js_errors: true,
    process_timeout: 60,
    timeout: 20,
    browser_options: {}, # Add any browser-specific options here
    inspector: ENV.fetch("SHOW_INSPECTOR", nil), # Use `SHOW_INSPECTOR=1` to debug with a browser
    headless: ENV["NOT_HEADLESS"] != "true"
  )
end

# TODO: screenshots on failure not working
# see: https://cucumber.io/docs/guides/browser-automation?lang=ruby#screenshot-on-failure
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
