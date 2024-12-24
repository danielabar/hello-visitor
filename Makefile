services:
	docker compose up

init:
	bundle exec rake db:create
	bundle exec rake db:migrate
	bundle exec rake db:seed

seed:
	bundle exec rake db:seed

migrate:
	bundle exec rake db:migrate

rollback:
	bundle exec rake db:rollback

serve:
	bin/rails s

console:
	bin/rails c

test:
	bundle exec rspec

reset_db:
	bundle exec rake db:reset

routes:
	bundle exec rake routes
