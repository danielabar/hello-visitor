# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferrerNormalizer do
  describe ".group_for" do
    it "returns nil for blank or nil input" do
      expect(described_class.group_for("")).to be_nil
      expect(described_class.group_for(nil)).to be_nil
    end

    it "returns nil for unparseable URIs" do
      expect(described_class.group_for("not a url at all !!!")).to be_nil
    end

    {
      # --- consolidation across Google country domains ---
      "https://www.google.com/search?q=ruby" => "Google",
      "https://www.google.de/" => "Google",
      "https://www.google.ca/" => "Google",
      # --- specific overrides win over the generic Google rule (rule order matters) ---
      "https://mail.google.com/" => "Gmail",
      "https://gemini.google.com/" => "Gemini",
      "https://keep.google.com/" => "Google Keep",
      # --- subdomain stripping + reddit consolidation ---
      "https://www.reddit.com/r/rails/" => "Reddit",
      "https://old.reddit.com/" => "Reddit",
      "https://out.reddit.com/" => "Reddit",
      # --- android-app:// token handling ---
      "android-app://com.reddit.frontpage/" => "Reddit",
      "android-app://com.linkedin.android/" => "LinkedIn",
      "android-app://com.google.android.gm/" => "Gmail",
      # --- one example from each curated category in classify.rb ---
      "https://duckduckgo.com/" => "DuckDuckGo",
      "https://www.perplexity.ai/" => "Perplexity",
      "https://news.ycombinator.com/" => "Hacker News",
      "https://t.co/abc" => "Twitter / X",
      "https://lnkd.in/xyz" => "LinkedIn",
      "https://rubyflow.com/" => "RubyFlow",
      "https://feedly.com/" => "Feedly",
      "https://github.com/foo/bar" => "GitHub",
      "https://storiesfromtheherd.com/post" => "Stories from the Herd (Medium)",
      # --- fallback to bare host when no rule matches ---
      "https://nelson.cloud/some-post" => "nelson.cloud",
      # --- self-referrer sentinel ---
      "https://danielabaron.me/blog/foo" => "self",
      "https://www.danielabaron.me/" => "self",
      # --- browser-internal junk ---
      "about:newtab" => "Browser new tab"
    }.each do |raw, expected|
      it "classifies #{raw.inspect} as #{expected.inspect}" do
        expect(described_class.group_for(raw)).to eq(expected)
      end
    end
  end
end
