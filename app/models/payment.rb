class Payment < ApplicationRecord
  belongs_to :booking
  
  after_save :update_booking_aggregated_data
  
  def update_booking_aggregated_data
    booking = self.booking
    
    payments = booking.payments
    
    total_payments = payments.pluck(:paid_amount)
    total_payments.delete(nil)
    
    total_refunds = payments.pluck(:refund_amount)
    total_refunds.delete(nil)
    
    booking.update({
      payments_count: payments.count,
      total_payments: (total_payments.sum - total_refunds.sum).to_f
    })
  end
end