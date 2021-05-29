# Heroku

Reference various useful commands, all run from project root:

```bash
# One time only to create app
heroku create

# Deploy main branch
git push heroku main

# Run migrations
heroku run rake db:migrate

# Configure env vars and verify
heroku config:set ALLOWED_ORIGIN=https://whatever.com
heroku config

# Ingest search documents
cat ~/path/to/search.sql | heroku pg:psql --app app-name

# Run a Rails console
heroku run rails console

# List dynos and their status
heroku ps

# Open app in browser
heroku open

# Monitor logs
heroku logs --tail

# psql
heroku pg:psql db-name --app app-name
```
