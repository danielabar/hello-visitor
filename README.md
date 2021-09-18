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

nvm install
npm install --global yarn
yarn install --check-files
```

## Start Services

`make`

## Initialize DB

`make init`

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

## TODO

[TODO](doc/todo.md)
