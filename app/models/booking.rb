class Booking < ApplicationRecord
  belongs_to :customer
  has_many :booking_items
  has_many :payments
  
  after_save :update_customer_aggregated_data
  
  validates :customer_id, presence: true
  
  def update_customer_aggregated_data
    customer = self.customer
    
    customer.update({
      bookings_count: customer.bookings.count,
      total_booking_value: customer.bookings.pluck(:total_price).sum.to_f
    })
  end
  
  
  def get_cumulative_payments
    payments = self.payments
    
    total_payments = payments.pluck(:paid_amount)
    total_payments.delete(nil)
    
    total_refunds = payments.pluck(:refund_amount)
    total_refunds.delete(nil)
    
    (total_payments.sum - total_refunds.sum).to_f
  end
  
  
end