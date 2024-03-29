# Hello Visitor

> Look Ma, No Cookies!

Free, privacy focused analytics. Just record visits, no creepy.
## System Dependencies

Before you start, make sure Docker is installed, as well as:

```bash
rbenv install 2.7.2
brew install postgresql

# Only needed if don't already have this dir (older homebrew installation)
sudo mkdir /usr/local/Frameworks
sudo chown $USER /usr/local/Frameworks

# mimemagic dependency
brew install shared-mime-info
bundle install

# Unsure if this is needed before or after yarn install?
bundle exec rails webpacker:install

# Note that node version is 16.0.0, not latest, because: https://stackoverflow.com/questions/74548318/how-to-resolve-error-error0308010cdigital-envelope-routinesunsupported-no
nvm install
npm install --global yarn
yarn install --check-files
```

## Start Services

`make`

## Initialize DB

`make init`

### Local DB Troubleshooting

Connect to Postgres database running in Docker container as `postgres` superuser:

```bash
psql -h 127.0.0.1 -p 5433 -U postgres
# enter POSTGRES_PASSWORD from docker-compose.yml
```

* List all databases: `\l`
* List all roles: `\du`
* Connect to a database, for example, hello: `\c hello`
* List all tables: `\dt`

[Reference](https://chartio.com/resources/tutorials/how-to-list-databases-and-tables-in-postgresql-using-psql/)

## Compile Assets

```bash
bin/webpack-dev-server
```
OR
```bash
bundle exec rake assets:precompile
# OR
bundle exec rake assets:precompile RAILS_ENV=development
```

## Run Server

`make serve`

App is at [http://localhost:3000/], login as example user in [seeds](db/seeds.rb).
## Run Tests

`make rspec`

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

## Spring Issues

Upgrade to latest `spring` in `Gemfile` and then one time:

```shell
# takes a long time
gem pristine --all
bundle install
bundle exec spring binstub --all
```

## TODO

[TODO](doc/todo.md)
