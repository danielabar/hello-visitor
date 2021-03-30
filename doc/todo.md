# TODO

## Devise

- Logout
- Devise `config.secret_key ` should come from env var

## POST Constraint

[constraint POST /visits](https://stackoverflow.com/questions/27852655/can-i-accept-post-request-only-from-a-domain-name)

## WIP: Visits Index View

To start, data within last year:
  - total number of visits
  - top pages (horizontal bar chart)
  - top referrers (horizontal bar chart)
  - number of visits per day (line chart)

Buttons for last 30 days, last 1 day, last 1 year.

Date range picker to select any date range (need to calc min/max dates of available data, maybe need to limit to X rows for sanity?)
## Heroku Postgres Cleanup

Free tier max 10K rows, need some auto truncate and archive...

## Data

Add `pathname` column populated by client side js: `window.location.pathname` for shorter for display in UI (compared to `url`).

Add custom validation to `Visit` model to not record user agents like bot, headless, etc.

How long user has been on page: https://stackoverflow.com/questions/147636/best-way-to-detect-when-a-user-leaves-a-web-page

Parse user agent - as it comes in? - maybe do in worker that updates record later.

Save country from ip: https://stackoverflow.com/questions/1988049/getting-a-user-country-name-from-originating-ip-address-with-ruby-on-rails - maybe do in worker that updates record later.
