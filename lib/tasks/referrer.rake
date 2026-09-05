require "set"

namespace :referrer do
  desc "Recompute referrer_group for all visits. Idempotent — safe to re-run after rule changes."
  task backfill: :environment do
    buckets = Hash.new { |h, k| h[k] = [] }

    Visit.where.not(referrer: [nil, ""]).distinct.pluck(:referrer).each do |raw|
      buckets[ReferrerNormalizer.group_for(raw)] << raw
    end

    buckets.each do |group, raw_referrers|
      count = Visit.where(referrer: raw_referrers).update_all(referrer_group: group)
      puts "  #{group.inspect} <- #{raw_referrers.size} distinct referrers, #{count} rows"
    end

    null_count = Visit.where(referrer: [nil, ""]).update_all(referrer_group: nil)
    puts "  NULL  <- #{null_count} rows with empty referrer"

    puts
    puts "=== Uncurated groups (promotion candidates) ==="
    Rake::Task["referrer:unclassified"].invoke
  end

  desc "Show the top unclassified referrer groups (fallback to bare host) — promotion candidates."
  task unclassified: :environment do
    curated = ReferrerNormalizer::Classifier::RULES.map { |r| r[:group] }.to_set

    rows = Visit.where.not(referrer_group: nil)
                .group(:referrer_group)
                .order(Arel.sql("COUNT(*) DESC"))
                .limit(50)
                .count
                .reject { |group, _| curated.include?(group) }

    puts "%-40s %10s" % ["referrer_group (uncurated)", "visits"]
    rows.first(20).each { |g, n| puts "%-40s %10d" % [g, n] }
  end
end
