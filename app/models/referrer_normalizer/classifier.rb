# frozen_string_literal: true

class ReferrerNormalizer
  class Classifier
    OWN_DOMAIN = "danielabaron.me"

    RULES = [
      # --- Email / messaging (specific google.com subdomains must come BEFORE the generic Google rule) ---
      { match: ->(h) { ["mail.google.com", "googleandroidgm"].include?(h) }, group: "Gmail" },
      { match: ->(h) { h == "keep.google.com" }, group: "Google Keep" },

      # --- AI assistants ---
      { match: ->(h) { h.include?("gemini.google.com") }, group: "Gemini" },
      { match: ->(h) { h.include?("perplexity.ai") }, group: "Perplexity" },
      { match: ->(h) { ["chatgpt.com", "chat.openai.com"].include?(h) }, group: "ChatGPT" },
      { match: ->(h) { h == "claude.ai" }, group: "Claude" },
      { match: ->(h) { h.include?("copilot.microsoft.com") }, group: "Microsoft Copilot" },

      # --- Search engines ---
      { match: ->(h) { h.match?(/(^|\.)google\./) }, group: "Google" },
      { match: ->(h) { h == "googlequicksearchbox" }, group: "Google" },
      { match: ->(h) { h.include?("duckduckgo.com") }, group: "DuckDuckGo" },
      { match: ->(h) { h.include?("bing.com") }, group: "Bing" },
      { match: ->(h) { h == "yandex.ru" || h == "ya.ru" || h.match?(/(^|\.)yandex\./) }, group: "Yandex" },
      { match: ->(h) { ["search.brave.com", "brave.com"].include?(h) }, group: "Brave Search" },
      { match: ->(h) { h.include?("ecosia.org") }, group: "Ecosia" },
      { match: ->(h) { h.include?("kagi.com") }, group: "Kagi" },
      { match: ->(h) { h.include?("startpage.com") }, group: "Startpage" },
      { match: ->(h) { h.include?("qwant.com") }, group: "Qwant" },
      { match: ->(h) { h.include?("search.yahoo.com") || h.end_with?(".yahoo.com") }, group: "Yahoo" },
      { match: ->(h) { h.include?("presearch.com") }, group: "Presearch" },
      { match: ->(h) { h == "you.com" }, group: "You.com" },
      { match: ->(h) { h.include?("baidu.com") }, group: "Baidu" },
      { match: ->(h) { h == "search.lilo.org" }, group: "Lilo" },

      # --- Social / discussion ---
      { match: ->(h) { h == "hn.algolia.com" }, group: "Hacker News" },
      { match: ->(h) { h.include?("reddit.com") || h == "redditfrontpage" }, group: "Reddit" },
      { match: ->(h) { h.include?("ycombinator.com") }, group: "Hacker News" },
      { match: ->(h) { h == "t.co" || h.include?("twitter.com") || h == "x.com" }, group: "Twitter / X" },
      { match: ->(h) { h.include?("linkedin.com") || h == "lnkd.in" || h == "linkedinandroid" }, group: "LinkedIn" },
      { match: ->(h) { h.include?("facebook.com") || h == "fb.me" }, group: "Facebook" },
      { match: ->(h) { h.include?("mastodon") || h.include?("joinmastodon") }, group: "Mastodon" },
      { match: ->(h) { h.include?("bsky.app") || h.include?("bluesky") }, group: "Bluesky" },
      { match: ->(h) { h == "eksisozluk.com" || h.include?("eksisozluk") }, group: "Eksi Sozluk (TR forum)" },

      # --- Messaging / chat ---
      { match: ->(h) { h == "statics.teams.cdn.office.net" || h.include?("teams.microsoft") }, group: "MS Teams" },
      { match: ->(h) { h == "slack" || h.include?("slack.com") }, group: "Slack" },

      # --- Ruby/JS dev newsletters & aggregators ---
      { match: ->(h) { h == "rubyflow.com" }, group: "RubyFlow" },
      { match: ->(h) { h == "rubyweekly.com" }, group: "Ruby Weekly" },
      { match: ->(h) { h == "rubyland.news" }, group: "Rubyland News" },
      { match: ->(h) { h == "javascriptweekly.com" }, group: "JavaScript Weekly" },
      { match: ->(h) { h == "frontendfoc.us" }, group: "Frontend Focus" },
      { match: ->(h) { ["hotwireweekly.com", "www.hotwireweekly.com"].include?(h) }, group: "Hotwire Weekly" },
      { match: ->(h) { h == "changelog.com" }, group: "Changelog" },
      { match: ->(h) { h == "ruby.libhunt.com" }, group: "Libhunt Ruby" },
      { match: ->(h) { h == "rubyonrails.ba" }, group: "Rails BA" },
      { match: ->(h) { h.include?("shortruby.com") || h == "newsletter.shortruby.com" }, group: "Short Ruby" },
      { match: ->(h) { h.include?("tldrnewsletter.com") || h.include?("tldr.tech") }, group: "TLDR Newsletter" },
      { match: ->(h) { h == "news.humancoders.com" }, group: "Human Coders (FR)" },
      { match: ->(h) { h == "dou.ua" }, group: "DOU (UA)" },
      { match: ->(h) { h == "curso.dev" }, group: "curso.dev" },
      { match: ->(h) { h == "dev.to" }, group: "dev.to" },
      { match: ->(h) { h == "maintainable.fm" }, group: "Maintainable (podcast)" },
      { match: ->(h) { h == "planetruby.org" }, group: "Planet Ruby" },
      { match: ->(h) { h == "hacklines.com" }, group: "Hacklines" },

      # --- Read-later / curation ---
      { match: ->(h) { h.include?("feedly.com") }, group: "Feedly" },
      { match: ->(h) { h.include?("inoreader.com") }, group: "Inoreader" },
      { match: ->(h) { h == "refind.com" }, group: "Refind" },
      { match: ->(h) { h.include?("readwise.io") }, group: "Readwise" },
      { match: ->(h) { h.include?("raindrop.io") }, group: "Raindrop" },
      { match: ->(h) { ["api.daily.dev", "daily.dev", "app.daily.dev"].include?(h) }, group: "daily.dev" },
      { match: ->(h) { h == "linktr.ee" }, group: "Linktree" },
      { match: ->(h) { h == "pinboard.in" }, group: "Pinboard" },
      { match: ->(h) { h == "instapaper.com" }, group: "Instapaper" },
      { match: ->(h) { h == "getpocket.com" }, group: "Pocket" },
      { match: ->(h) { h == "feeder.co" }, group: "Feeder" },

      # --- Blog mentions / Substack / Medium ---
      { match: ->(h) { h == "storiesfromtheherd.com" }, group: "Stories from the Herd (Medium)" },
      { match: ->(h) { h == "www.writesoftwarewell.com" }, group: "Write Software Well" },
      { match: ->(h) { h == "writesoftwarewell.com" },     group: "Write Software Well" },
      { match: ->(h) { h == "garrettdimon.com" }, group: "garrettdimon.com" },
      { match: ->(h) { h == "view.hashicorp.com" }, group: "HashiCorp (newsletter)" },
      { match: ->(h) { h.include?("substack.com") }, group: "Substack (other)" },
      { match: ->(h) { h == "medium.com" || h.end_with?(".medium.com") || h == "scribe.rip" }, group: "Medium" },
      { match: ->(h) { h.include?("buttondown.com") || h.include?("buttondown.email") }, group: "Buttondown" },
      { match: ->(h) { h == "andyatkinson.com" }, group: "andyatkinson.com" },

      # --- GitHub ---
      { match: ->(h) { ["github.com", "gist.github.com"].include?(h) }, group: "GitHub" },

      # --- Self-referrers ---
      { match: ->(h) { h == OWN_DOMAIN || h.end_with?(".#{OWN_DOMAIN}") }, group: "self" },

      # --- Browser internal junk ---
      { match: ->(h) { h == "newtab" || h.start_with?("about") }, group: "Browser new tab" }
    ].freeze

    def self.group_for(host)
      rule = RULES.find { |r| r[:match].call(host) }
      rule ? rule[:group] : host
    end
  end
end
