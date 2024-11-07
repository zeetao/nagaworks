class Booking < ApplicationRecord
  belongs_to :customer
  has_many :booking_items
  has_many :payments
  
  after_save :update_customer_aggregated_data
  
  def update_customer_aggregated_data
    customer = self.customer
    
    customer.update({
      bookings_count: customer.bookings.count,
      total_booking_value: customer.bookings.pluck(:total_price).sum.to_f
    })
  end
  
  
end