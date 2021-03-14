return unless Rails.env.development?

User.destroy_all
user = User.new({ email: 'test@example.com', password: 'password', password_confirmation: 'password' })
user.save
