# Hello Visitor

> Look Ma, No Cookies!

Free, privacy focused analytics. Just record visits, no creepy.
## System Dependencies

Before you start, make sure Docker is installed, as well as:

```
rbenv install 2.7.2
brew install postgresql
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

Heroku TBD...

[TODO](doc/todo.md)
