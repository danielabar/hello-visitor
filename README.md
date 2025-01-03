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
