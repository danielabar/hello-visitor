# Heroku

Reference various useful commands, all run from project root:

```bash
# One time only to create app
heroku create

# Check remotes
git remote -v

# Only if heroku app not listed it remotes
git remote add heroku https://git.heroku.com/app-name.git

# Deploy main branch
git push heroku main

# View releases, see also: https://blog.heroku.com/releases-and-rollbacks
heroku releases --app app-name

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

# List apps
heroku apps

# Open app in browser
heroku open

# Monitor logs
heroku logs --tail

# psql
heroku pg:psql db-name --app app-name
```

## Import DB Prod Copy to Local

Make sure `~/.pgpass` has:

```
127.0.0.1:5432:helloprodcopy*:hello:hello
127.0.0.1:5432:hello:hello:hello
127.0.0.1:5432:postgres:postgres:getThisFromDockerCompose
```

Extract prod db to new local prod copy db, eg: `helloprodcopy_2021-12-12`:

```
PGUSER=postgres PGPASSWORD=getThisFromDockerCompose PGHOST=127.0.0.1 heroku pg:pull getDbNameFromHeroku helloprodcopy_replaceWithDate --app getAppNameFromHeroku
```

Run in newly created prod copy (couldn't find how to do this other than in PgAdmin4):

```sql
-- Dump from Heroku does not include any superuser AFAIK
alter role hello superuser;
```

Wipe out existing seed data from local dev db:

```sql
delete from visits;
```

Dump visits table from prod copy to dev:

* `-h` Hostname is 127.0.0.1, not `localhost` because db is running in Docker
* `-U` Username
* `-w` Do not prompt for password, this will search for matching entries in `~/.pgpass`
* `-a` Data only, does not generate schema, which is what we want because table already exists in dev db
* `-t` Only dump specified table `visits`

```
pg_dump -h 127.0.0.1 -U hello -w -a -t visits helloprodcopy_replaceWithDate | psql -w -h 127.0.0.1 -U hello hello
```
