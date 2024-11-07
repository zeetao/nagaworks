class Inventory < ApplicationRecord
  has_many :booking_items
  
  validates :name, :category, :unit_price, :details, :description, presence: true
  
  
  
  
end