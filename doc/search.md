# Search

## Usage

## Generate Data

Generate `search.sql` from source (eg: Gatsby blog markdown files). Recommend [upsert](https://www.postgresqltutorial.com/postgresql-upsert/) format, for example:

```sql
INSERT INTO documents(title, description, category, published_at, slug, body, created_at, updated_at)
VALUES(
  'Navigate Back & Forth in VS Code',
  'How to Navigate Back and Forth in VS Code',
  'vscode',
  '2020-02-23',
  '/blog/how-to-navigate-back-and-forth-in-vscode/',
  'post body...',
  now(),
  now())
ON CONFLICT (title)
DO NOTHING;
```
## Ingest Documents

```
psql -h 127.0.0.1 -p 5433 -d hello -U hello -f ~/path/to/search.sql
```

## Start Server with Optional Configuration

```
DEFAULT_SEARCH_TERM=rails MAX_SEARCH_RESULTS=5 bundle exec rails s
```

See `config/search.yml` for default configuration.

## Development Details

### Postgres Full Text Search

Multiple search terms separated by `&` or `|`.

```sql
SELECT
  title,
  slug,
  published_at,
  ts_rank(
    to_tsvector('english', description) || to_tsvector('english', title) || to_tsvector('english', category) || to_tsvector('english', body),
    to_tsquery('english', 'ruby & rails')
  ) AS rank
FROM documents
WHERE
  to_tsvector('english', description) || to_tsvector('english', title) || to_tsvector('english', category) || to_tsvector('english', body) @@
  to_tsquery('english', 'ruby & rails')
ORDER BY rank DESC
LIMIT 3;
```

### Integrate with Rails

Follow this [post](https://pganalyze.com/blog/full-text-search-ruby-rails-postgres)

Read [pg_search docs](https://github.com/Casecommons/pg_search/)

Expose an endpoint to return results like:

```ruby
Document.search_doc("rails").limit(3)
```

Where `rails` replaced with param[:q].
