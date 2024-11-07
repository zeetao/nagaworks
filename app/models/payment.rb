class Payment < ApplicationRecord
  belongs_to :booking
  
  after_save :update_booking_aggregated_data
  
  def update_booking_aggregated_data
    booking = self.booking
    
    booking.update({
      payments_count: booking.payments.count,
      total_payments: booking.get_cumulative_payments
    })
  end
end