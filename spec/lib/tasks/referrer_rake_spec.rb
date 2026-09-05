# frozen_string_literal: true

require "rails_helper"
require "rake"
require "active_support/testing/stream"

RSpec.describe "referrer rake tasks", type: :task do
  include ActiveSupport::Testing::Stream

  before { Rails.application.load_tasks unless Rake::Task.task_defined?("referrer:backfill") }

  # backfill chains a call to unclassified, so both tasks' invoked-once guard
  # needs resetting after every example, not just the one under test.
  after do
    Rake::Task["referrer:backfill"].reenable
    Rake::Task["referrer:unclassified"].reenable
  end

  describe "referrer:backfill" do
    let(:task) { Rake::Task["referrer:backfill"] }

    it "classifies existing visits and overwrites stale values" do
      google_de = create(:visit, referrer: "https://www.google.de/", referrer_group: nil)
      gmail     = create(:visit, referrer: "https://mail.google.com/", referrer_group: nil)
      direct    = create(:visit, referrer: nil,                        referrer_group: nil)
      blank     = create(:visit, referrer: "",                         referrer_group: nil)
      stale     = create(:visit, referrer: "https://www.google.com/",  referrer_group: "OUTDATED")

      silence_stream($stdout) { task.invoke }

      expect(google_de.reload.referrer_group).to eq("Google")
      expect(gmail.reload.referrer_group).to     eq("Gmail")
      expect(direct.reload.referrer_group).to    be_nil
      expect(blank.reload.referrer_group).to     be_nil
      expect(stale.reload.referrer_group).to     eq("Google")
    end

    it "is idempotent across repeated invocations" do
      visit = create(:visit, referrer: "https://www.google.com/", referrer_group: nil)

      silence_stream($stdout) { task.invoke }
      task.reenable
      silence_stream($stdout) { task.invoke }

      expect(visit.reload.referrer_group).to eq("Google")
    end
  end

  describe "referrer:unclassified" do
    let(:task) { Rake::Task["referrer:unclassified"] }

    it "prints uncurated (bare-host) groups but not curated labels" do
      create_list(:visit, 3, referrer_group: "Google")
      create_list(:visit, 2, referrer_group: "nelson.cloud")

      output = capture_stdout { task.invoke }

      expect(output).to include("nelson.cloud")
      expect(output).not_to include("Google")
    end

    it "surfaces uncurated groups even when curated groups fill the top ranks" do
      curated_groups = ReferrerNormalizer::Classifier::RULES.first(30).pluck(:group)
      curated_groups.each { |group| create_list(:visit, 10, referrer_group: group) }
      create_list(:visit, 2, referrer_group: "nelson.cloud")

      output = capture_stdout { task.invoke }

      expect(output).to include("nelson.cloud")
    end
  end

  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original
  end
end
