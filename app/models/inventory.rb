class Inventory < ApplicationRecord
  has_many :booking_items 
end