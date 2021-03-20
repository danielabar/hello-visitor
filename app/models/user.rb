class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Removing :registerable because this system should not allow just anyone to register
  # Removing :recoverable, don't have a mailer for now, use Rails console to reset password
  devise :database_authenticatable, :rememberable, :validatable
end
