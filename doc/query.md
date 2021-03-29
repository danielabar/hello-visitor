# Queries

For now, everything runs from today to 1 year ago.

## Total Visits

```sql
select count(id) from visits
where created_at >= now() - interval '1 year';
```

## Visits by Page

```sql
select SPLIT_PART(url, '?', 1) as just_url
  , count(SPLIT_PART(url, '?', 1))
from visits
where created_at >= now() - interval '1 year'
group by SPLIT_PART(url, '?', 1)
order by count(SPLIT_PART(url, '?', 1)) desc;
```

## Referrer

```sql
select referrer
  , count(referrer)
from visits
where created_at >= now() - interval '1 year'
group by referrer
order by count(referrer) desc;
```

## Visits by Day

```sql
select created_at::timestamp::date
  , count(created_at::timestamp::date)
from visits
where created_at >= now() - interval '1 year'
group by created_at::timestamp::date
order by created_at;
```
