# frozen_string_literal: true

# Represents a Visit arriving over HTTP. Holds the raw request inputs
# and knows how to turn them into a Visit ready for persistence:
# applies the request's remote IP, derives referrer_group via
# ReferrerNormalizer, and sanitizes the free-text fields. Returns an
# unsaved Visit so the caller controls persistence and response.
class IncomingVisit
  def initialize(params:, remote_ip:)
    @params = params
    @remote_ip = remote_ip
  end

  def build
    Visit.new(@params).tap do |visit|
      visit.remote_ip = @remote_ip
      visit.referrer_group = ReferrerNormalizer.group_for(visit.referrer)
      sanitize(visit)
    end
  end

  private

  # https://stackoverflow.com/questions/3985989/using-sanitize-within-a-rails-controller
  def sanitize(visit)
    visit.user_agent = ActionController::Base.helpers.sanitize(visit.user_agent)
    visit.url = ActionController::Base.helpers.sanitize(visit.url)
  end
end
