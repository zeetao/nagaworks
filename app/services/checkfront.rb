class Checkfront
  
  def self.import_customers
    checkfront_customers_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/checkfront_customers_snapshot_06Nov2024.csv"
    checkfront_customers = csv_to_array_of_hashes(checkfront_customers_csv_path)
    
    # customer format = {
    # 	"Customer"=>"Mr. Ngan",
    # 	"Bookings"=>"1",
    # 	"Phone"=>"+60122933964",
    # 	"Customer ID"=>"MJ4-621-509",
    # 	"Total"=>"1800.00",
    # 	"Last booking"=>"06/11/2024",
    # 	"Status"=>"Active",
    # 	"Email"=>"nganwaikong@gmail.com",
    # 	"Address"=>"",
    # 	"City"=>"",
    # 	"Region"=>"",
    # 	"Country"=>"",
    # 	"Zip / Postal"=>"",
    # 	"Created"=>"06/11/2024"
    # }

    checkfront_customers.each do |checkfront_customer|
      customer = Customer.find_or_create_by({
        name: checkfront_customer["Customer"],
        email: checkfront_customer["Email"],
        phone: checkfront_customer["Phone"],
        address: checkfront_customer["Address"],
        checkfront_reference: checkfront_customer["Customer ID"],
        created_at: checkfront_customer["Created"].to_date
      })
      
      customer.update_column(:updated_at, Time.now) if customer.updated_at.blank?
    end
    
  end
  
  def self.import_bookings
    # checkfront_bookings_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/checkfront_booking_until_31oct2024-awanmulan.csv"
    checkfront_bookings_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/checkfront_bookings_until_7Nov2024-awanmulan.csv"
    checkfront_bookings = csv_to_array_of_hashes(checkfront_bookings_csv_path)
    
    # booking format = {
    # 	"Booking"=>"Teratak Bonda",
    # 	"Created"=>"16/11/2011 07:13 PM",
    # 	"Start date"=>"18/11/2011",
    # 	"End date"=>"19/11/2011",
    # 	"Customer"=>"Su Ann",
    # 	"Amount"=>"800.00",
    # 	"Status"=>"Paid",
    # 	"Booking ID"=>"CXRA-161111",
    # 	"SKU"=>"1525657348",
    # 	"Payment Type"=>"",
    # 	"Date Modified"=>"16/11/2011 07:13 PM",
    # 	"First Name"=>"Su",
    # 	"Last Name"=>"Ann",
    # 	"Email"=>"su-ann@palatepalette.com",
    # 	"Customer ID"=>"TS6-531-802",
    # 	"Source"=>"admin",
    # 	"Partner Account"=>"",
    # 	"Amount Paid"=>"800.00",
    # 	"Amount Due"=>"0.00",
    # 	"Sub-total"=>"800.00",
    # 	"Taxes"=>"0.00",
    # 	"Qty"=>"1",
    # 	"Discount Code"=>"",
    # 	"TID"=>"",
    # 	"Provider"=>"",
    # 	"Customer Language"=>"",
    # 	"Check In / Out"=>"checkin",
    # 	"Number of Adults/Children"=>"(3) admin: Palate Palette",
    # 	"Phone (preferably with whatsapp)"=>"+60122261237",
    # 	"Address - Street or resident name level sufficient"=>"",
    # 	"Address"=>"",
    # 	"Other requests"=>"",
    # 	"Same day booking?"=>"",
    # 	"guesthouse_name"=>"",
    # 	"Catering Requests (10 pax and above only)"=>"",
    # 	"customer_region"=>"14",
    # 	"City"=>"Kuala lumpur",
    # 	"Country"=>"Malaysia",
    # 	"Postal / Zip"=>"",
    # 	"Stay up to date on our newsletter."=>"",
    # 	"Booking instructions"=>""
    # }
    
    # Get the list of unique checkfront booking references
    checkfront_booking_references = checkfront_bookings.map{|x| x["Booking ID"]}.uniq
    
    # look through each checkfront booking reference to find a collection of booking items
    checkfront_booking_references.each do |checkfront_booking_reference|
      # Start Atomic transaction. Required for consistency
      ActiveRecord::Base.transaction do
        # find or create the booking with the unique checkfront_booking_reference
        booking = Booking.find_or_create_by({
          checkfront_reference: checkfront_booking_reference
        })
        
        # Update the updated column if nil
        booking.update_column(:updated_at, Time.now) if booking.updated_at.blank?
        
        # Find the booking items for this checkfront_booking_reference
        checkfront_booking_items = checkfront_bookings.select{|x|x["Booking ID"]==checkfront_booking_reference}
        
        # nullify first the booking created date
        booking_created_date = nil
        
        # nullify customer_reference 
        customer_reference = nil
        
        # loop through each booking item for that unique checkfront_booking_reference and create the booking item and inventory 
        checkfront_booking_items.each do |checkfront_booking_item|
          # Find or create the inventory from the booking item
          inventory = Inventory.find_or_create_by({
            name: checkfront_booking_item["Booking"]
          })
          
          if (inventory.created_at > checkfront_booking_item["Created"].to_datetime)
            # If the booking_item stated creation date is before the inventory creation date, then update the inventory creation date to match. 
            # This is so the inventory date is always the earliest date the inventory gets booked
            inventory.update_column(:created_at, checkfront_booking_item["Created"].to_datetime) 
          elsif (inventory.updated_at < checkfront_booking_item["Created"].to_datetime)
            # if the updated_at date is less than the booking date, update the updated at date
            # save the created at date to the updated_at date so there is a last use date on the inventory
            # update the inventory price to the latest price
            inventory.update({
              updated_at: checkfront_booking_item["Created"].to_datetime,
              unit_price: checkfront_booking_item["Amount"].to_f
            }) 
          end
          
          # Set booking created date with first booking item created date
          booking_created_date = checkfront_booking_item["Created"].to_datetime
          
          # set customer_reference
          customer_reference = checkfront_booking_item["Customer ID"]
          
          booking_item = BookingItem.find_or_create_by({
            booking_id: booking.id, 
            inventory_id: inventory.id, 
            start_date: checkfront_booking_item["Start date"].to_date, 
            end_date: checkfront_booking_item["End date"].to_date, 
            item_price: checkfront_booking_item["Amount"].to_f,
            created_at: booking_created_date
          })
          
          booking_item.update_column(:updated_at, Time.now) if booking_item.updated_at.blank?
          
        end
        
        # set total booking price by summing all the booking_items per booking
        total_booking_price = checkfront_booking_items.map{|x|x["Amount"].to_f}.sum
        
        # set customer booking owner
        customer = Customer.find_by_checkfront_reference(customer_reference)
        
        booking.update({
          total_price: total_booking_price,
          customer_id: customer.id,
          created_at: booking_created_date
        })
        
      end # End Atomic transaction
    end
    
  end
  
  def self.import_payments
    checkfront_payments_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/payments_up_to_06Nov2024.csv"
    checkfront_payments = csv_to_array_of_hashes(checkfront_payments_csv_path)
    
    # payments = {
    #   "Transaction ID"=>"VCYY-311024-1",
    #   "Date"=>"06/11/2024 04:22 PM",
    #   "Event"=>"PAID",
    #   "Amount"=>"550.00",
    #   "Payment Type"=>"POS - Cash",
    #   "User Account"=>"admin",
    #   "Payment Customer"=>"Fumiko Konno",
    #   "Payment Provider"=>"None",
    #   "Provider Transaction"=>"672b273d85809",
    #   "Booking Date"=>"31/12/2024",
    #   "Info"=>""
    # }
    
    checkfront_payments.each do |checkfront_payment|
      booking_reference = checkfront_payment["Transaction ID"].match(/([[a-z][A-Z]]+[-][0-9]+)[-][0-9]+/)[1]
      booking = Booking.find_by_checkfront_reference(booking_reference)
      
      # Skip this transaction if can't find the booking. This means that the booking has not been inserted yet
      next if booking.blank?
      
      payment = Payment.find_or_create_by({
        checkfront_reference: checkfront_payment["Transaction ID"]
      })
      
      payment_params = {
        booking_id: booking.id,
        checkfront_reference: checkfront_payment["Transaction ID"],
        created_at: checkfront_payment["Date"].to_datetime,
        updated_at: checkfront_payment["Date"].to_datetime
      }
      
      case checkfront_payment["Event"]
      when "PAID"
        payment_params[:paid_amount] = checkfront_payment["Amount"].to_f
      when "REFUND"
        payment_params[:refund_amount] = checkfront_payment["Amount"].to_f
      end
      
      payment.update(payment_params)
    end
  
  end
  
end