# TODO

## Devise (WIP)

- Authenticate only for index and show visit, getting started: https://github.com/heartcombo/devise#getting-started
- Devise `config.secret_key ` should come from env var
- Logout
- Create new user at console: https://stackoverflow.com/questions/35909643/devise-user-from-rails-console1.
- Prevent new user registration

```ruby
user = User.new({email: 'test@example.com', password: 'password', password_confirmation: 'password'})
user.save
```

## CORS

Only for POST /visit

## Heroku

Heroku Rails console to create user: https://stackoverflow.com/questions/463916how-can-i-run-rails-console-in-heroku-rails-5-1-and-postgresql   `heroku run rails c -a APP_NAME`

## Visits Index View

Visits Controller index respond to html with view - just a tabular listing for now???

Paginated or only show most recent `n` results

## Future Enhancements

How long user has been on page: https://stackoverflow.com/questions/147636/best-way-to-detect-when-a-user-leaves-a-web-page

Save country from ip: https://stackoverflow.com/questions/1988049/getting-a-user-country-name-from-originating-ip-address-with-ruby-on-rails
