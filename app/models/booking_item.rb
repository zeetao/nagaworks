class BookingItem < ApplicationRecord
  belongs_to :booking
  belongs_to :inventory
  
  after_save :update_booking_aggregated_data
  
  def update_customer_aggregated_data
    booking = self.booking
    
    booking.update({
      items_count: booking.booking_items.count
    })
  end
end