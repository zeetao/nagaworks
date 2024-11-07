class Inventory < ApplicationRecord
  has_many :booking_items
  
  validates :name, :category, :unit_price, :details, :description, presence: true
  
  def self.categories
    [
      "Stayovers",
      "Visits",
      "Food",
      "Facilities",
      "Extras"
    ]
  end
  
  
end