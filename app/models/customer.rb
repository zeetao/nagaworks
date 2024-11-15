class Customer < ApplicationRecord
  has_many :bookings
  
  validates :name, :phone, :email, presence: true
  validates :email, uniqueness: true
  validates :phone, uniqueness: true
  
end