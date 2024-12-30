# frozen_string_literal: true

After do |scenario|
  if scenario.failed?
    # Generate a meaningful screenshot name using scenario details
    timestamp = Time.zone.now.strftime("%Y%m%d-%H%M%S")
    file_name = scenario.name.tr(" ", "_").gsub(/[^0-9A-Za-z_]/, "") # Clean up special characters
    feature_name = File.basename(scenario.location.file).gsub(/[^0-9A-Za-z_]/, "") # Feature file name
    screenshot_path = Rails.root.join("tmp/screenshots", "#{feature_name}-#{file_name}-#{timestamp}.png").to_s

    # Take a screenshot
    page.save_screenshot(screenshot_path, full: true) # rubocop:disable Lint/Debugger

    # Attach the screenshot to the Cucumber report
    attach(screenshot_path, "image/png")
  end
end
