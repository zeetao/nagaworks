class Customer < ApplicationRecord
  has_many :bookings
  
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :email, uniqueness: true
  validates :phone, uniqueness: true
  
end