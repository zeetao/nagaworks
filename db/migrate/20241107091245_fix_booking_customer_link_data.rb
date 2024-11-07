class FixBookingCustomerLinkData < ActiveRecord::Migration[7.2]
  def up
    checkfront_bookings_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/checkfront_bookings_until_7Nov2024-awanmulan.csv"
    checkfront_bookings = csv_to_array_of_hashes(checkfront_bookings_csv_path)
    
    Booking.all.each do |booking|
      checkfront_booking_reference = booking.checkfront_reference
      
      checkfront_booking = checkfront_bookings.select{|x|x["Booking ID"]==checkfront_booking_reference}.first
      
      checkfront_customer_reference = checkfront_booking["Customer ID"]
      
      customer = Customer.find_by_checkfront_reference(checkfront_customer_reference)
      
      booking.update_column(:customer_id, customer.id)
    end
  end
end
