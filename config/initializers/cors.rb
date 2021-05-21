Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['ALLOWED_ORIGIN'] || 'http://localhost:8000'
    resource '/visits', headers: :any, methods: %i[post]
  end

  allow do
    origins ENV['ALLOWED_ORIGIN'] || 'http://localhost:8000'
    resource '/search', headers: :any, methods: %i[get]
  end
end

Rails.logger.info("Cors Configured to allow origin: #{ENV['ALLOWED_ORIGIN'] || 'http://localhost:8000'}")
