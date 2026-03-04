# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Hello Visitor is a privacy-focused analytics app built with Rails 8.1. It records page visits without tracking cookies. The dashboard shows visit statistics filtered by URL, referrer, and date range.

## Commands

```bash
bin/setup          # Install deps and prepare database
bin/dev            # Start Rails server + TailwindCSS watch (development)
bin/rspec          # Run RSpec unit and integration tests
bin/cucumber       # Run Cucumber browser/feature tests
bin/rubocop        # Lint Ruby code
bin/ci             # Full local CI verification (run before opening PRs)
```

Run a single RSpec test:
```bash
bin/rspec spec/models/visit_spec.rb
bin/rspec spec/models/visit_spec.rb:42  # specific line
```

Run a single Cucumber feature:
```bash
bin/cucumber features/visit_analysis.feature
```

Database tasks via `make`:
```bash
make migrate       # Run pending migrations
make rollback      # Roll back last migration
make replant       # Reseed database (drop + seed)
make console       # Open Rails console
make routes        # Print routes
```

## Architecture

### Visit Recording (cookie-free tracking)
Clients POST to `POST /visits` with `guest_timezone_offset`, `user_agent`, `url`, and optionally `referrer`. The controller (`app/controllers/visits_controller.rb`) adds `remote_ip` server-side. Bot user agents are rejected by `Visit#not_a_bot` using the `browser` gem.

### Dashboard & Query Layer
The dashboard (`visits#index`) creates a `VisitSearch` (an ActiveModel object, not an AR model) from query params, then passes it to `Stats#collect` which delegates to `Visit` class methods. All the actual SQL lives in `app/queries/visit_query.rb` (`VisitQuery`) using raw `find_by_sql` with parameterized queries. Stats aggregations: summary totals, top/bottom pages, referrers, visits-by-date.

### Document Search
`Document` uses `pg_search` for full-text search against `title`, `description`, `category`, and `body` columns. The `SearchController` exposes a JSON endpoint at `GET /search` used (presumably) by an external site's search feature.

### Authentication
Devise with `database_authenticatable`, `rememberable`, and `validatable`. Only the visits `index` and `show` actions require authentication. The `create` endpoint is public (for the tracking pixel/script). CSRF protection is skipped on `VisitsController` to allow cross-origin POSTs; CORS is configured via `rack-cors`.

### Frontend
- Importmap (no build step for JS)
- TailwindCSS v3 (via `tailwindcss-rails`)
- Chartkick + Chart.js for the analytics charts
- Stimulus (Hotwire) for modest JS
- Views use ERB partials in `app/views/visits/` for charts and stats

### Testing
- **RSpec**: models (`spec/models/`) and requests (`spec/requests/`) with FactoryBot + Faker + Shoulda Matchers
- **Cucumber**: browser tests in `features/` using Capybara + Cuprite (headless Chrome driver)

### Key Models
| Model | Type | Purpose |
|-------|------|---------|
| `Visit` | ActiveRecord | Raw visit records |
| `VisitSearch` | ActiveModel | Search/filter form object (no DB table) |
| `Stats` | Plain Ruby | Collects all analytics for the dashboard |
| `VisitQuery` | Plain Ruby | Raw SQL queries for visit aggregations |
| `Document` | ActiveRecord | Content for pg_search full-text search |
| `User` | ActiveRecord | Devise-authenticated dashboard users |
