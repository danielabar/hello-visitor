# frozen_string_literal: true

require "rails_helper"

RSpec.describe VisitsHelper do
  describe "#quick_filter_link" do
    let(:range) { { start_date: 7.days.ago.to_date, end_date: Time.zone.today } }
    let(:current_range) { { start_date: 7.days.ago.to_date, end_date: Time.zone.today } }
    let(:path) { "/visits?visit_search[start_date]=7.days.ago.to_date&visit_search[end_date]=Time.zone.today" }

    it "renders a span with active styles for the active range" do
      result = helper.quick_filter_link("7 Days", range, current_range, path)
      expect(result).to include("<span")
      expect(result).to include("bg-indigo-100")
      expect(result).to include("text-indigo-600")
    end

    it "renders a link for non-active ranges" do
      other_range = { start_date: 1.month.ago.to_date, end_date: Time.zone.today }
      result = helper.quick_filter_link("1 Month", other_range, current_range, path)
      expect(result).to include("<a")
      expect(result).to include("hover:bg-gray-100")
      expect(result).not_to include("bg-indigo-100")
    end
  end
end
