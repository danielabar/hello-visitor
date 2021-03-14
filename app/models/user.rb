class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Removing :registerable because this system should not allow just anyone to register
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
