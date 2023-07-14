services:
	docker compose up

init:
	bundle exec rake db:create
	bundle exec rake db:migrate
	bundle exec rake db:seed

seed:
	bundle exec rake db:seed

replant:
	bundle exec rake db:seed:replant

migrate:
	bundle exec rake db:migrate

rollback:
	bundle exec rake db:rollback

serve:
	bin/rails s

serve_assets:
	bin/webpack-dev-server

console:
	bin/rails c

test:
	bundle exec rspec

reset_db:
	bundle exec rake db:reset

prepare_test_db:
	bin/rails db:test:prepare

routes:
	bundle exec rake routes
