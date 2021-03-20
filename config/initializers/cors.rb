# TODO: allowed origin should come from env var
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8000'
    resource '/visits', headers: :any, methods: %i[post]
  end
end
