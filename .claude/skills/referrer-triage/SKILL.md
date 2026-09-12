---
name: referrer-triage
description: "Triage newly-seen, uncurated referrer hosts on the Hello Visitor dashboard and promote the legitimate ones to named rules in ReferrerNormalizer::Classifier. Use this skill when the user asks to run referrer triage, classify new or unclassified referrers, add referrer rules, or work through the uncurated groups list from the referrer:unclassified rake task. Covers finding candidates, checking them safe via VirusTotal, identifying the site, judging whether it's worth naming, adding the classifier rule plus spec, verifying locally against synced prod data (including exercising the dashboard UI), shipping the PR, deploying, and verifying on prod."
---

# Referrer Triage

Promotes bare-host `referrer_group` values (rows where no
`Classifier` rule matched, so the raw host is stored verbatim) into
named, human-readable groups. This is a recurring maintenance loop,
not a one-time migration — new unrecognized referrers show up
continuously as the dashboard sees new traffic.

Background and the original one-time pass that established this
process live in `scratch/referrer-triage-process/` (see
`add-rules-workflow.md`, `run-unclassified.md`,
`rule-candidates-20260905.md`, `unclear-source-investigation.md`,
`vt-api-calls-20260905.md`) and `scratch/referrer-consolidation/`
(the original schema/backfill rollout this loop follows on from).
Read `add-rules-workflow.md` first if it exists — it may have grown
additional notes since this skill was written.

## Scratch dir for this round's artifacts

Every artifact produced while running this skill — rake task output,
VT command+output logs, the candidate table, backfill logs — goes
under a dated dir, created fresh each round:

```
scratch/referrer-classification/<YYYY-MM-DD>/
```

e.g. `scratch/referrer-classification/2026-09-05/unclassified-run.log`.
Use suitably descriptive filenames within that dir (no need to repeat
the date in the filename — it's already in the directory path).
`scratch/` is gitignored, so none of this is committed.

## Prerequisites

- `heroku` CLI installed and authenticated, `$HEROKU_HELLO_APP_NAME`
  set (same as used for `pgsync`, see project `CLAUDE.md`).
- A VirusTotal API key exported as `$VT_API_KEY` in the developer's
  shell profile (e.g. `~/.zshrc`): `export VT_API_KEY="..."`. Free
  tier is enough (4 lookups/min, 500/day). **Ask the developer to
  confirm this is set before starting** — if `echo $VT_API_KEY` (or
  `source ~/.zshrc && echo $VT_API_KEY` in a fresh Bash call, since
  shell env doesn't persist between tool calls) comes back empty,
  stop and ask them to sign up at virustotal.com and export the key
  before continuing.

## Step 1 — Find candidates

Run the triage task against prod and save the output:

```bash
mkdir -p scratch/referrer-classification/$(date +%Y-%m-%d)
heroku run -a $HEROKU_HELLO_APP_NAME bin/rake referrer:unclassified 2>&1 | tee scratch/referrer-classification/$(date +%Y-%m-%d)/unclassified-run.log
```

This lists the top 20 uncurated `referrer_group` values (bare hosts,
no rule matched) by visit count.

## Step 2 — Build the candidate table

Create `scratch/referrer-classification/<YYYY-MM-DD>/rule-candidates.md`
with a table: `referrer_group | visits | suggested pretty name | notes`.

For each row, use judgment before proposing a name:

- **Low value to name, leave bare** — corporate/internal hosts
  (`.local` domains, intranet tools), link-preview crawlers, `localhost`,
  or anything clearly not a genuine human referral. Note *why* in the
  table rather than silently dropping the row.
- **Clear identity from the hostname alone** — recognizable services
  (`trello.com`, `coda.io`, newsletter/blog domains you already
  recognize) — propose the pretty name directly, no need for VT/site
  visit.
- **Unclear source** — anything you can't confidently name from the
  hostname — goes through Step 3 before naming.
- **Self-referral** (the site's own domain, e.g. a personal GitHub
  Pages mirror) — ask the developer whether they want it labeled or
  left bare; don't assume either way.

## Step 3 — VirusTotal check, then visit the site

For every "unclear source" row, in order:

1. **VirusTotal first.** Do not visit the site before this passes.
   ```bash
   source ~/.zshrc  # picks up $VT_API_KEY in this Bash call
   curl -s --request GET \
     --url https://www.virustotal.com/api/v3/domains/<host> \
     --header "x-apikey: $VT_API_KEY" | python3 -m json.tool
   ```
   Pace requests to stay under the free-tier 4 req/min limit (e.g.
   `sleep 16` between calls in a loop). Check `data.attributes.last_analysis_stats`
   — proceed only if `malicious` and `suspicious` are both `0`. If
   not, do not visit the site; record it in the table as unsafe and
   tell the developer.
2. **Only if green**, visit the site (WebFetch, or WebSearch if the
   site requires auth / gives nothing useful) to figure out what it
   is and propose a pretty name. If the site is auth-walled or
   otherwise inconclusive, leave it unresolved rather than guessing —
   record that plainly in the table.
3. Save the raw command + output for every VT lookup made in
   `scratch/referrer-classification/<YYYY-MM-DD>/vt-api-calls.md`
   (fenced `bash` + `json` blocks, one section per domain) — this is
   the audit trail for the safety check.
4. Update the candidate table from Step 2 with the confirmed pretty
   names (or leave `—` for anything still unresolved).

## Step 4 — Branch and implement

1. Branch off `main`: `referrer-rules-<YYYY-MM-DD>` (dated so
   multiple rounds don't collide).
2. Edit `app/models/referrer_normalizer/classifier.rb` — one `RULES`
   entry per confirmed host, placed in the section matching its
   category (newsletters, webmail, blogs, tools, etc.), adding a new
   `# --- Category ---` section if nothing fits. Rule order only
   matters when a new rule could shadow/be shadowed by an existing
   one (e.g. a specific subdomain rule must precede a broader
   catch-all for the same parent domain) — these additions are almost
   always independent of existing rules.
3. Update `spec/models/referrer_normalizer_spec.rb` — add one example
   per new rule to the `raw => expected` hash. If any newly-classified
   host was previously used as the spec's "fallback to bare host"
   example, swap that example to a still-unclassified host (check
   `Classifier::RULES` to confirm it truly isn't covered).
4. `bin/ci` locally — must be green.

## Step 5 — Verify locally against real data

Sync prod visits into the local dev DB and run the backfill for real,
not just the unit test:

```bash
pgsync visits
bin/rake referrer:backfill
```

Confirm the hosts you just added rules for no longer appear in the
"Uncurated groups" section the backfill task prints at the end.

Then exercise the actual dashboard UI:

1. `bin/dev` to start the server.
2. Log in (Devise) and load the dashboard (`/`).
3. Widen the date range enough to cover the synced visits (the "Top
   Referrers" chart aggregates by `referrer_group`).
4. Confirm the newly-added pretty names appear in the Top Referrers
   chart/breakdown instead of the bare hostnames, with sane visit
   counts. Also try the "Referrer" text-search field
   (`_custom_search.html.erb`) with a raw host substring to spot-check
   filtering still works.
5. Stop the dev server when done.

## Step 6 — Ship it

1. Commit (classifier + spec only — `scratch/` is gitignored, don't
   try to add it).
2. Push, open PR, get it merged.
3. Deploy to Heroku. This is manual — the developer does it
   themselves; don't attempt to trigger a deploy.
4. Re-run backfill on prod so historical rows pick up the new labels:
   ```bash
   heroku run -a $HEROKU_HELLO_APP_NAME bin/rake referrer:backfill 2>&1 | tee scratch/referrer-classification/$(date +%Y-%m-%d)/backfill-run-prod.log
   ```
   This also reruns `referrer:unclassified` at the end, seeding the
   *next* round's candidate list.
5. **Verify on prod**: log into the live dashboard, check the Top
   Referrers chart shows the new pretty names for real traffic (not
   just the synced local copy).

## What doesn't change round to round

No new expand/migrate/contract PR-split is needed for this loop —
that ceremony was for the original schema rollout
(`scratch/referrer-consolidation/README.md`). Every round of this
skill is one branch, one small PR, one deploy, one backfill re-run.

Auto-promotion (labeling based on visit-count thresholds without a
human choosing the name) is a deliberate non-goal — see
`scratch/referrer-research/CONSOLIDATION-PLAN.md`, "Why no
auto-promote heuristic." Every pretty name in this loop is a human
(or an agent, with the human able to review the PR) editorial
decision.
