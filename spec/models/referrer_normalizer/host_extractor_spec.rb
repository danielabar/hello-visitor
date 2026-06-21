# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferrerNormalizer::HostExtractor do
  describe ".host_for" do
    it "returns nil for blank input" do
      expect(described_class.host_for("")).to be_nil
      expect(described_class.host_for(nil)).to be_nil
    end

    it "returns nil for an unparseable URI" do
      expect(described_class.host_for("not a url !!!")).to be_nil
    end

    context "when referrer uses the android-app:// scheme" do
      it "maps com.google.android.gm to googleandroidgm" do
        expect(described_class.host_for("android-app://com.google.android.gm/")).to eq("googleandroidgm")
      end

      it "maps com.google.android.googlequicksearchbox to googlequicksearchbox" do
        url = "android-app://com.google.android.googlequicksearchbox/"
        expect(described_class.host_for(url)).to eq("googlequicksearchbox")
      end

      it "maps com.linkedin.android to linkedinandroid" do
        expect(described_class.host_for("android-app://com.linkedin.android/")).to eq("linkedinandroid")
      end

      it "maps com.reddit.* to redditfrontpage" do
        expect(described_class.host_for("android-app://com.reddit.frontpage/")).to eq("redditfrontpage")
      end

      it "maps com.slack.* to slack" do
        expect(described_class.host_for("android-app://com.slack.android/")).to eq("slack")
      end

      it "falls back to the bare package name for unknown apps" do
        expect(described_class.host_for("android-app://com.example.unknown/")).to eq("com.example.unknown")
      end
    end

    context "when referrer uses the about: scheme" do
      it "returns newtab for about:newtab" do
        expect(described_class.host_for("about:newtab")).to eq("newtab")
      end

      it "returns newtab for any about: url" do
        expect(described_class.host_for("about:blank")).to eq("newtab")
      end
    end

    context "when referrer is a normal URI" do
      it "extracts the host" do
        expect(described_class.host_for("https://github.com/foo/bar")).to eq("github.com")
      end

      it "strips www." do
        expect(described_class.host_for("https://www.google.com/")).to eq("google.com")
      end

      it "strips m." do
        expect(described_class.host_for("https://m.facebook.com/")).to eq("facebook.com")
      end

      it "strips l." do
        expect(described_class.host_for("https://l.facebook.com/")).to eq("facebook.com")
      end

      it "strips out." do
        expect(described_class.host_for("https://out.reddit.com/")).to eq("reddit.com")
      end

      it "strips old." do
        expect(described_class.host_for("https://old.reddit.com/")).to eq("reddit.com")
      end

      it "strips new." do
        expect(described_class.host_for("https://new.example.com/")).to eq("example.com")
      end

      it "lowercases the host" do
        expect(described_class.host_for("https://GitHub.COM/foo")).to eq("github.com")
      end
    end
  end
end
