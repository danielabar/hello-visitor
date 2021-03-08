class Visit < ApplicationRecord
  validates :guest_timezone_offset, presence: true
  validates :user_agent, presence: true
  validates :url, presence: true
end
