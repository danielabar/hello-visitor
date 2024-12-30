# frozen_string_literal: true

After do |scenario|
  if scenario.failed?
    screenshot_path = Rails.root.join("tmp/screenshots", "screenshot-#{scenario.__id__}.png").to_s
    page.save_screenshot(screenshot_path, full: true) # rubocop:disable Lint/Debugger
    attach(screenshot_path, "image/png")
  end
end
