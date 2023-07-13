Might need to: `bundle update parser`?

Fix this test: `bundle exec rspec spec/requests/visits_spec.rb:37`
`http://localhost:3000/visits.json` is returning the visits AR relation rather than JSON list, eg: `"visits": "#<Visit::ActiveRecord_Relation:0x00000001389f01f8>"`
