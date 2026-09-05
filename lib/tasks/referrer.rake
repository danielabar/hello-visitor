require "set"
require "logger"

namespace :referrer do
  def referrer_task_logger
    @referrer_task_logger ||= Logger.new(Rails.root.join("log/referrer.log"))
  end

  # Prints to stdout (visible in the terminal / `heroku run` output) and
  # writes the same line to log/referrer.log, so a backfill run leaves a
  # record behind without needing shell redirection.
  def referrer_log(message = "")
    puts message
    referrer_task_logger.info(message)
  end

  desc "Recompute referrer_group for all visits. Idempotent — safe to re-run after rule changes."
  task backfill: :environment do
    buckets = Hash.new { |h, k| h[k] = [] }

    Visit.where.not(referrer: [nil, ""]).distinct.pluck(:referrer).each do |raw|
      buckets[ReferrerNormalizer.group_for(raw)] << raw
    end

    buckets.each do |group, raw_referrers|
      count = Visit.where(referrer: raw_referrers).update_all(referrer_group: group)
      referrer_log "  #{group.inspect} <- #{raw_referrers.size} distinct referrers, #{count} rows"
    end

    null_count = Visit.where(referrer: [nil, ""]).update_all(referrer_group: nil)
    referrer_log "  NULL  <- #{null_count} rows with empty referrer"

    referrer_log
    referrer_log "=== Uncurated groups (promotion candidates) ==="
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

    referrer_log "%-40s %10s" % ["referrer_group (uncurated)", "visits"]
    rows.first(20).each { |g, n| referrer_log "%-40s %10d" % [g, n] }
  end
end
