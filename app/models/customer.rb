class Customer < ApplicationRecord
  has_many :bookings
  
  validates :email, confirmation: true # Requires a email_confirmation field in the form and must be the same
  validates :name, :phone, :email, :email_confirmation, presence: true
  
  
  
end