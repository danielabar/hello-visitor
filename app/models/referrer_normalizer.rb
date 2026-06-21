# frozen_string_literal: true

# Coordinates the two-step pipeline that turns a raw referrer string into a
# dashboard-ready group label. HostExtractor handles the messy input formats;
# Classifier maps the resulting host token to a human-readable source name.
# Keeping the steps separate lets each be tested in isolation.
class ReferrerNormalizer
  def self.group_for(raw_referrer)
    return nil if raw_referrer.blank?

    host = HostExtractor.host_for(raw_referrer)
    return nil if host.blank?

    Classifier.group_for(host)
  end
end
