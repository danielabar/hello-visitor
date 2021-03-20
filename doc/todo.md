# TODO

## Devise

- Logout
- Devise `config.secret_key ` should come from env var

## POST Constraint

[constraint POST /visits](https://stackoverflow.com/questions/27852655/can-i-accept-post-request-only-from-a-domain-name)

## Visits Index View

Visits Controller index respond to html with view - just a tabular listing for now???

Something like last 30/60/90 days:
  - most popular pages
  - most frequent browsers, devices etc.

## Heroku Postgres Cleanup

Free tier max 10K rows, need some auto truncate and archive...

## More Data

Parse user agent - as it comes in?

How long user has been on page: https://stackoverflow.com/questions/147636/best-way-to-detect-when-a-user-leaves-a-web-page

Save country from ip: https://stackoverflow.com/questions/1988049/getting-a-user-country-name-from-originating-ip-address-with-ruby-on-rails
