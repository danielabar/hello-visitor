# frozen_string_literal: true

# Classifies a raw referrer string into a consolidated group label
# (e.g. https://www.google.de/ -> "Google"). Source of truth for both
# the write path and the backfill task. See
# scratch/referrer-research/CONSOLIDATION-PLAN.md for the rationale.
#
# Rule order in Classifier is load-bearing: specific google.com subdomains
# must precede the generic Google rule.
class ReferrerNormalizer
  def self.group_for(raw_referrer)
    return nil if raw_referrer.blank?

    host = HostExtractor.host_for(raw_referrer)
    return nil if host.blank?

    Classifier.group_for(host)
  end
end
