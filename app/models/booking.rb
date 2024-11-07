class Booking < ApplicationRecord
  belongs_to :customer
  has_many :booking_items
  has_many :payments
  
  after_save :update_customer_aggregated_data
  
  def update_customer_aggregated_data
    
    
  end
  
  
end