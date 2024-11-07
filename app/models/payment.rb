class Payment < ApplicationRecord
  belongs_to :booking
  
  after_save :update_booking_aggregated_data
  
  def update_customer_aggregated_data
    booking = self.booking
    
    payments = booking.payments
    
    booking.update({
      payments_count: payments.count,
      total_payments: (payments.pluck(:paid_amount).sum - payments.pluck(:refund_amount).sum).to_f
    })
  end
end