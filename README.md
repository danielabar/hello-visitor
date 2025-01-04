# Hello Visitor

> Look Ma, No Cookies!

Free, privacy focused analytics. Just record visits, no creepy.

## Prerequisites

* Docker
* Ruby installed with version manager of your choice (see `.ruby-version`)
* Homebrew
* `brew install postgresql`
* `nvm install` (to install Node.js version specified in `.nvmrc`)

## Start Services

Install dependencies and prepare database:

```bash
bin/setup
```

Start Rails server and TailwindCSS watch:

```bash
bin/dev
```

App is at http://localhost:3000/, login as example user in [seeds](db/seeds.rb).

## Run Tests

```bash
# RSpec unit and integration tests
bin/rspec

# Cucumber feature/browser tests
bin/cucumber
```

## Linting

```bash
bin/rubocop
```

## Local CI

For full local verification (recommended before opening a PR):

```bash
bin/ci
```

## Working with Production Data

This project comes with seed data to generate random visits. There's also an option to load production data into the development database, from on the latest Heroku PG backup:

```bash
bin/sync_prod_to_dev
```

This will download a PG dump file of the latest backup on Heroku, and generate a table-of-contents list file for the database objects to be restored, which will exclude a few things not relevant for local development.

By default, the script will remove the generated dump and list files upon completion. They can be preserved if needed:

```bash
bin/sync_prod_to_dev --preserve-files
```

## Deploy

[Heroku Getting Started with Rails 6](https://devcenter.heroku.com/articles/getting-started-with-rails6)

[Setup env vars](https://devcenter.heroku.com/articles/config-vars)

Create new user at [Heroku Rails Console](https://devcenter.heroku.com/articles/getting-started-with-rails6#run-the-rails-console), replace `email` and `password` with real values:

```ruby
user = User.new({email: 'test@example.com', password: 'password', password_confirmation: 'password'})
user.save
```

[Using Postgres](https://devcenter.heroku.com/articles/heroku-postgresql#using-the-cli)

[More useful Heroku commands](doc/heroku.md)

## TODO

[TODO](doc/todo.md)
