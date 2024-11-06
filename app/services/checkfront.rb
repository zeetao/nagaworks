class Checkfront
  
  def self.import_customers
    checkfront_customers_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/checkfront_customers_snapshot_06Nov2024.csv"
    customers = csv_to_array_of_hashes(checkfront_customers_csv_path)
    
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

    customers.each do |customer|
      
      
    end
    
  end
  
  def self.import_bookings
    checkfront_bookings_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/checkfront_booking_until_31oct2024-awanmulan.csv"
    bookings = csv_to_array_of_hashes(checkfront_bookings_csv_path)  
    
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
    
  end
  
  def self.import_payments
    checkfront_payments_csv_path = "/home/ubuntu/environment/nagaworks/db/checkfront/payments_up_to_06Nov2024.csv"
    payments = csv_to_array_of_hashes(checkfront_payments_csv_path)
    
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
    
  end
  
end