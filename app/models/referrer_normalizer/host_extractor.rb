# frozen_string_literal: true

# Normalizes a raw referrer into a plain host token so Classifier rules can
# stay simple and pattern-match against one canonical form. Browsers and apps
# send referrers in wildly different formats (https:// URLs, android-app://
# URIs, about: strings) — this class absorbs all of that variability.
# Common prefixes (www., m., etc.) are stripped here for the same reason.
class ReferrerNormalizer
  class HostExtractor
    ANDROID_APP_TOKENS = {
      /com\.google\.android\.gm/ => "googleandroidgm",
      /com\.google\.android\.googlequicksearchbox/ => "googlequicksearchbox",
      /com\.linkedin\.android/ => "linkedinandroid",
      /com\.reddit/ => "redditfrontpage",
      /com\.slack/ => "slack"
    }.freeze

    STRIPPED_PREFIXES = %w[www. m. l. out. old. new.].freeze

    def self.host_for(referrer)
      return nil if referrer.blank?
      return from_android_app(referrer) if referrer.start_with?("android-app://")
      return "newtab"                   if referrer.start_with?("about:")

      from_uri(referrer)
    end

    def self.from_android_app(referrer)
      pkg = referrer.sub("android-app://", "").split("/").first.to_s
      _, token = ANDROID_APP_TOKENS.find { |pattern, _| pkg.match?(pattern) }
      token || pkg
    end

    def self.from_uri(referrer)
      uri  = URI.parse(referrer.strip)
      host = uri.host.to_s.downcase
      STRIPPED_PREFIXES.each { |prefix| host = host.delete_prefix(prefix) }
      host
    rescue URI::InvalidURIError
      nil
    end
  end
end
