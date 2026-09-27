---
name: dependabot-triage
description: "Triage open Dependabot PRs on Hello Visitor one at a time, oldest to newest — classify by CI coverage rather than semver, merge and deploy each one individually, handle the recurring RuboCop-group lint failure, and verify after every deploy to Heroku. Use this skill when the user asks to triage/review/merge Dependabot PRs, catch up on dependency bumps, or work through the open PR queue."
---

# Dependabot Triage

Fetch every open Dependabot PR (`gh pr list --state open --json number,title,headRefName,statusCheckRollup,labels,createdAt`) on this repo. Sort oldest to newest by `createdAt`. Work through them **one at a time, in that order** — each PR gets its own full classify → (merge or hold) → verify → deploy cycle before you move to the next. Report progress as you go; ask before anything destructive (merge, push, deploy).

**If the user names one or more specific PR numbers** (e.g. "just do #255", "handle 255 and 262"), scope the run to only those — still fetch the full list to know where things stand and to sort the named ones oldest-to-newest, but skip every PR not named, and don't feel obligated to work through the rest of the queue afterward unless asked. Note in the worklog directory name that this was a scoped run (e.g. `scratch/dependabot-maintenance/2026-09-13-pr255/`).

Don't batch merges together. Each Dependabot PR touches `Gemfile.lock` (or a workflow file) independently, and processing one at a time means the next PR in the queue is simply rebased against whatever just landed — no juggling multiple stale branches or lockfile-invalidation cascades.

## 0. Keep a worklog for this run

Before doing anything else, once you have the sorted PR list, create a worklog directory and file:

- Directory: `scratch/dependabot-maintenance/YYYY-MM-DD-prN-prN-prN/` — date
  the run started, then every open Dependabot PR number in the queue at
  the start, lowest first (e.g. `scratch/dependabot-maintenance/2026-09-12-pr258-pr260-pr261/`).
  This makes the dir name identify the run without opening anything, even
  though the PRs are handled sequentially rather than as a batch.
- File: `worklog.md` inside that directory.

Log to `worklog.md` as you go, not just at the end — one entry per
meaningful command/action with its outcome (mirror the style used in
`scratch/dependabot-maintenance/section5-devtools-mcp-test.md` from a prior
manual run: numbered steps, the command, then "Outcome: ..."). For each PR
in the queue, cover:

- The classification decision (section 1) and why.
- Any RuboCop-group fix applied (section 2): what failed, what changed.
- Whether it needed a rebase before merging, and how that went (section 3).
- The `bin/ci` result and the `bin/dev`/dev-server smoke check (section 4).
- The `git push heroku main` and the full post-deploy verification
  (section 5) — every chrome-devtools MCP step and its outcome, same
  level of detail as a human would want to audit later. This is the part
  most worth a durable record since it's the check that catches a bad
  deploy.
- For deploy-and-watch / manual-review PRs (section 6): the risk summary
  given to the user, and what they decided.

`scratch/` is gitignored — never stage or commit the worklog.

## 1. Classify each PR by CI coverage, not semver

This repo's CI (`.github/workflows/ci.yml`) runs brakeman, importmap audit, rubocop, rspec, and cucumber (headless Chrome, `assets:precompile`). That's broad — but it never boots the app under production config (no `RAILS_ENV=production`, no real puma).

For each PR, decide:

- **Low risk (auto-mergeable if CI green):** the changed gem/action is dev/test-only (rubocop, shoulda-matchers, capybara, database_cleaner, actions/checkout, actions/upload-artifact, faker, factory_bot), OR it's a patch bump of something CI fully exercises at boot (bootsnap). This also covers gems only loaded in the `development` environment (web-console, byebug, letter_opener, listen) — CI's rspec/cucumber runs never boot in `development`, so CI being green doesn't cover them at all; the section 4 dev-server smoke check is what actually verifies these, not CI.
- **Needs deploy-and-watch (merge, but verify on Heroku before calling it done):** a gem with a production-only surface CI can't reach — the web server (puma), background job/cache adapters, anything touching `config/environments/production.rb`. A major version bump here is the strongest trigger.
- **Needs manual review regardless of CI:** anything touching auth (devise), CSRF/CORS (rack-cors), the database driver (pg), or Rails itself. Green CI is not a complete signal for these — read the changelog/release notes before merging.

Do not use "patch vs. major" alone as the risk signal — a patch bump of puma still lands in the deploy-and-watch bucket.

**If a PR is already red on GitHub** (a check other than the known RuboCop-group failure — see section 2 for that one): first try `gh pr comment <n> --body "@dependabot rebase"` and wait — a rebase against current `main` often clears it on its own, and this takes a while (new commit + full CI run), same as the rebase-before-merge wait in section 3. If it's still red after that:
- Tell the user — don't merge past it and don't just move on to the next PR silently.
- Investigate the failure yourself first (`gh pr checks <n>`, open the failing job log) so the report to the user is "X failed because Y," not just "it's red." Check whether it's this PR's dependency bump causing it (read the failing test/lint output) before assuming it's unrelated flakiness.

Also check the PR's full `Gemfile.lock` diff (`gh pr diff <n> -- Gemfile.lock`), not just the gem(s) named in the title — a grouped/consolidated PR can drag a transitive bump of an unrelated, higher-risk gem along with it. Classify by the riskiest gem actually touched in the diff, not just the headline one.

## 2. Handle the RuboCop-group PR's known failure mode

New RuboCop releases often add cops that fail `lint` on otherwise-unrelated code. This has happened before (PR #205, PR #257). If a PR's `lint` check fails because of this:

- Check out the PR branch (`gh pr checkout <n>`).
- Run `bin/rubocop` and read the new offense(s).
- Fix the underlying code (extract a method, move logic, split the class) per this project's CLAUDE.md. If it's autocorrectable (`bin/rubocop -A`), review the diff before trusting it — but a mechanical directive-syntax fix (e.g. `Style/DirectiveScope` rewriting an existing disable/enable pair) is fine to accept as-is since it doesn't add a new suppression.
- **Never** add `# rubocop:disable`, a new `.rubocop_todo.yml` entry, or `# rubocop:todo` — CLAUDE.md forbids this for new code, including code touched by a dependency bump.
- Push the fix to the Dependabot branch, wait for CI, then treat it like any other low-risk PR.

Pushing your own commit to a Dependabot branch means dependabot will refuse to rebase it later ("this PR has been edited by someone other than Dependabot") — see section 3 for how to update it yourself when that happens.

## 3. Bring the PR up to date, then merge

By the time you get to a PR in the queue, `main` has usually moved (from the previous PR's merge), so the branch needs updating before GitHub will allow the merge (branch protection requires it be up to date):

- Prefer `gh pr comment <n> --body "@dependabot rebase"` and wait for the new commit + CI run.
- Dependabot sometimes responds by **closing the PR and opening a replacement** instead (e.g. "shoulda-matchers is updatable in another way, so this is no longer needed") if a newer combined update supersedes it. Treat the replacement as the continuation of this PR, not a new unrelated item — pick up where you left off with the new PR number.
- If dependabot refuses to rebase (already-edited PR, e.g. from your own section 2 fix), update it yourself: `git rebase origin/main` on the PR branch (not `git merge origin/main` — that creates a merge-bubble commit) and `git push --force-with-lease`. It's a solo dependabot branch, so force-pushing it is safe.

Once it's up to date and CI is green:

- **Low risk:** merge with `gh pr merge <n> --squash --delete-branch`. **Never `--merge`** — this repo keeps a linear history (check `git log --oneline main`, no merge-bubble commits) and a plain merge commit clutters the graph.
- **Deploy-and-watch / manual-review:** don't merge yet — go to section 6 instead, then come back to the queue afterward regardless of what the user decides for this one.

After a low-risk merge, immediately continue to section 4 for that PR before moving to the next one in the queue — don't queue up multiple merges before verifying.

## 4. After merging: local verification

**Postgres for this project runs via Docker Compose** (`docker-compose.yml`
at repo root, Postgres 14, port 5432), not a natively-installed Postgres.
Before `bin/ci` or any local `bin/rails db:*` command, check it's up
(`docker compose ps`, look for the `database` service `running`). **If
it's not running, don't start a native/Homebrew Postgres as a substitute**
— stop and ask the user to run `docker compose up -d` first. A
locally-installed Postgres on the same port will fight with the project's
actual dev database (different role/data, port conflict) rather than fix
anything.

```
git checkout main
git pull
bundle install
bin/ci
```

Then smoke-test the local dev server — `bin/ci` never boots the app, and a
broken `bin/dev` blocks every local dev session, so check it after every
merge, not just when a dev-tooling gem is involved.

**Never start `bin/dev` (or a bare `bin/rails server`) yourself** — same
rule as Postgres above. Ask the user to run `bin/dev` (or start the server
however they normally do) and tell you when it's up, then:

- Confirm `http://localhost:3000` actually responds (e.g. `curl -sI
  http://localhost:3000`) — don't just take the user's word that it
  started, since a boot error can still leave a process alive.
- Ask the user to check the server output for startup errors, or check it
  yourself if they share the log/terminal.
- **Log in and confirm the dashboard actually renders**, using chrome-devtools MCP (same tool as section 5, just pointed at localhost instead of prod) — a 302 to the sign-in page or a bare curl check only proves the server boots, not that the dashboard works. Credentials come from `db/seeds.rb` (`test@example.com` / `password`); reseed with `make replant` first if that user doesn't exist locally.
  - Navigate to `http://localhost:3000/users/sign_in`, fill in the seeded credentials, submit.
  - On the dashboard, confirm the charts (visits-by-date, Top Pages, Top Referrers) actually render — check for `<canvas>` elements via `evaluate_script`, not just "no console errors" — and check `list_console_messages` for errors.
  - **Known false alarm:** the first load after `bin/dev` restarts sometimes throws CSP `Executing inline script violates ... script-src` console errors and the charts fail to render (0 canvases) — a pre-existing quirk from a much older Chartkick-related dependency bump, unrelated to whatever PR is being verified. Before treating this as a regression, reload the page once (`navigate_page` with `type: "reload"`) and recheck; if canvases render clean on reload, it's the known issue, not a new break.
- Ask the user to stop the server when the check is done (don't kill it
  yourself — you didn't start it, and it may be their normal dev session).

If `bin/ci` is green and the dev-server + dashboard check passes, ask the user for confirmation, then `git push heroku main`.

## 5. Post-deploy verification (don't skip this)

Automating the merge only gets to an unverified prod faster.

**Prerequisite (one-time human setup, not something this skill does per run):**
- A dedicated Devise user exists in prod for the agent to log in as, credentials in `$HELLO_VISITOR_AGENT_EMAIL` / `$HELLO_VISITOR_AGENT_PASSWORD` (shell profile, never in the repo, never echoed in a transcript).
- The `chrome-devtools` MCP server is configured for this project (`claude mcp add chrome-devtools npx chrome-devtools-mcp@latest`, or per its own docs). It launches a real local Chrome via CDP — no extra billing, nothing to install beyond Chrome + Node.

**Automated, using chrome-devtools MCP (preferred — exercises the real tracking script, not just the bare endpoint):**

1. Set a unique tag for this deploy, including the deployed commit so the tag also identifies which release it verified: `SMOKE_TAG="hello-visitor-smoke-$(git rev-parse --short HEAD)-$(date -u +%Y%m%dT%H%M%SZ)"`.
2. Get the deployed app's URL: `heroku apps:info -a $HEROKU_HELLO_APP_NAME` (look for the `Web URL:` line). Call it `$APP_URL` below.
3. Launch a browser via chrome-devtools MCP: call `new_page` to open tab 1, then call `emulate` with that `pageId` and `userAgent: "$SMOKE_TAG"` to override the User-Agent for the rest of the session. (Clear an override later by calling `emulate` again with `userAgent: ""`.) If `new_page` was called with the URL directly, the page loads before the UA override takes effect — call `navigate_page` with `type: "reload"` afterward so the tagged UA is actually in effect for the real request.
4. In tab 1, navigate to `https://danielabaron.me/` for real. This fires whatever tracking script the blog actually embeds — catches CORS/CSP breakage that a direct `curl` to `/visits` would miss.
5. Open a second tab: call `new_page` again to get a second `pageId`, and call `emulate` on it too with the same `userAgent: "$SMOKE_TAG"` (each page needs its own override — it doesn't carry over from tab 1). Do the dashboard steps below in this tab, leaving tab 1 open on the blog.
6. In tab 2, log into the dashboard at `$APP_URL/users/sign_in` with `$HELLO_VISITOR_AGENT_EMAIL` / `$HELLO_VISITOR_AGENT_PASSWORD`. (If a session cookie from an earlier verification in the same browser context is still valid, this step may already be authenticated — that's fine, just confirm you land on `/visits` rather than the sign-in form.)
7. Load the dashboard (`$APP_URL/visits`) and confirm the charts render with no console errors (chrome-devtools MCP can read the console log directly).
8. Don't `navigate_page` straight to `$APP_URL/visits.json` — Claude Code's auto-mode classifier blocks that as raw PII (real visitors' IPs/user agents). Instead, in the authenticated tab, use `evaluate_script` to `fetch('/visits.json', { credentials: 'same-origin' })` and return only a computed result (e.g. `data.visits.some(v => v.user_agent === tag)` plus a count) — never the raw rows. Note the response shape: `{summary, by_page, by_page_bottom, by_date, by_month, by_referrer, visits}` — the array to check is `data.visits`, not the top-level object.
9. If the tagged visit isn't there after a short retry (a few seconds — writes are synchronous but allow for latency), treat it as a failed check, not a maybe.

**If chrome-devtools MCP isn't available this run:** don't fall back to a weaker check — stop and walk the user through getting it connected instead:

1. Run `claude mcp list` (or check `/mcp` in-session) to see whether `chrome-devtools` is configured but failed to connect, vs. not configured at all.
2. If configured but disconnected: it usually just needs a session restart (MCP servers connect at startup) — ask the user to restart Claude Code in this project.
3. If not configured at all: it's likely only added to another project's local config (e.g. `~/.claude.json` → `projects.<other-path>.mcpServers`). Check there first — moving/copying the existing entry into the top-level `mcpServers` key makes it available to every project, and is far less work than reinstalling. Only run `claude mcp add chrome-devtools npx chrome-devtools-mcp@latest` if no existing config can be found anywhere.
4. Don't proceed with the deploy-verification step until it's connected — this is a one-time fix, not a recurring cost.

- For a deploy-and-watch PR (puma, etc.), also watch `heroku logs --tail --app "$HEROKU_HELLO_APP_NAME"` for a minute after deploy.
- If anything looks wrong: `heroku rollback --app "$HEROKU_HELLO_APP_NAME"` is the escape hatch — mention it, don't just leave the user to find it.

Once verification passes for this PR, move on to the next PR in the queue (back to section 1's classification for it, since `main` has moved again).

## 6. For deploy-and-watch / manual-review PRs

Don't auto-merge these. Instead:
- `gh pr checkout <n>`
- Skim the release notes/changelog for the version jump.
- Run `bin/ci` locally.
- Run the same dev-server smoke check as section 4 (`bin/dev`, confirm `http://localhost:3000` responds, check for startup errors, stop it).
- Summarize the risk in plain terms (what changed, what could break, what to watch after deploy) and let the user decide.

Whatever the user decides, continue to the next PR in the queue afterward — don't let one deferred PR block triaging the rest.

## Output

End with a short summary table: PR number, verdict (merged+deployed+verified / held for manual review / needs rebase / closed-and-replaced), and any follow-up action still open. Also point the user at the worklog file from section 0.
