class Booking < ApplicationRecord
  has_and_belongs_to_many :customers
  has_many :booking_items
  has_many :payments
end