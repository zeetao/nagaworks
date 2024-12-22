class Checkfront
  
  def self.migrate_customers
    
    CheckfrontRecord.customers.to_migrate.each do |checkfront_record|
      ActiveRecord::Base.transaction do
        checkfront_customer = checkfront_record.row_data
        
        # keys = ["email", "phone", "source", "address", "created_date", "customer_ref", "customer_name"]
        customer = Customer.find_by({
          email: checkfront_customer["email"]
        })
        
        if customer 
          # customer already exists
          checkfront_record.migrated_at = customer.updated_at
          
          customer.assign_attributes({
            name: checkfront_customer["customer_name"],
            phone: checkfront_customer["phone"],
            address: checkfront_customer["address"],
            checkfront_reference: checkfront_customer["customer_ref"],
            created_at: checkfront_customer["created_date"].to_date
          })
          
          if customer.changed?
            checkfront_record.status = "Migrated"
            checkfront_record.notes = "Customer id: #{customer.id} updated: #{customer.changes}"
            customer.save
          else
            checkfront_record.status = "Migrated"
            checkfront_record.notes = "Customer already exist. No changes. id: #{customer.id}"
            customer.save
          end
        else 
          # customer does not exist
          customer = Customer.new({
            name: checkfront_customer["customer_name"],
            email: checkfront_customer["email"],
            phone: checkfront_customer["phone"],
            address: checkfront_customer["address"],
            checkfront_reference: checkfront_customer["customer_ref"],
            created_at: checkfront_customer["created_date"].to_date
          })
          
          if customer.save
            checkfront_record.migrated_at = Time.now.to_datetime
            checkfront_record.status = "Migrated"
            checkfront_record.notes = "New Customer Created id: #{customer.id}"  
          else
            checkfront_record.migrated_at = Time.now.to_datetime
            checkfront_record.status = "Migration Failed"
            checkfront_record.notes = "Error in create: #{customer.errors.full_messages}"
          end
          
        end
        
        checkfront_record.save
        
      end
    end
    
  end
  
  def self.migrate_extra_bookings
    # These bookings are newly created since the last import. Need to only do this once
    checkfront_bookings = [
    	{booking_id: "AXKA-061124", created_at: "2020-11-06", check_in: "2025-01-29", check_out: "2025-01-31", customer_id: "MJ4-621-509", room: [["Rahsiah", 1, 1800.00]], amount: 1800.00, status: "Paid", payments: [{"2024-11-06" => 1800.00}]}, 
    	{booking_id: "DVRF-241024", created_at: "2024-10-24", check_in: "2025-01-24", check_out: "2025-01-25", customer_id: "ZN6-109-173", room: [["Rahsiah", 1, 900.00]], amount: 900.00, status: "Paid", payments: [{"2024-10-24" => 900.00}]}, 
    	{booking_id: "YRPN-131124", created_at: "2024-11-13", check_in: "2025-01-18", check_out: "2025-01-19", customer_id: "FT3-678-051", room: [["Durian Runtuh", 1, 700.00], ["Rahsiah", 1, 900.00]], amount: 1600.00, status: "Paid", payments: [{"2024-11-13" => 1600.00}]}, 
    	{booking_id: "HXLF-161124", created_at: "2024-11-16", check_in: "2025-01-11", check_out: "2025-01-12", customer_id: "SV1-165-813", room: [["Durian Runtuh", 1, 1100.00], ["Rahsiah", 1, 500.00]], amount: 1600.00, status: "Paid", payments: [{"2024-11-16" => 1100.00}, {"2024-11-18" => 500.00}]},
    	{booking_id: "BDVV-261024", created_at: "2024-10-26", check_in: "2024-12-31", check_out: "2025-01-01", customer_id: "SB2-567-765", room: [["Evensong", 1, 500.00], ["Sasterawan", 1, 500.00]], amount: 1000.00, status: "Paid", payments: [{"2024-10-27" => 1000.00}]},
    	{booking_id: "VCYY-311024", created_at: "2024-10-31", check_in: "2024-12-31", check_out: "2025-01-01", customer_id: "KF1-603-451", room: [["Durian Runtuh", 1, 1100.00]], amount: 1100.00, status: "Deposit", payments: [{"2024-11-06" => 550.00}]},
    	{booking_id: "AZHV-261024", created_at: "2024-10-26", check_in: "2024-12-23", check_out: "2024-12-25", customer_id: "NX1-683-923", room: [["Evensong", 1, 500.00], ["Uncle Manz BBQ Chicken Quarter Chicken - Premarinated raw meats", 1, 25.00], ["Uncle Manz BBQ Lamb 250gm - Premarinated raw meats", 1, 30.00]], amount: 1055.00, status: "Paid", payments: [{"2024-10-27" => 1555.00}]},
    	{booking_id: "AVXK-121124", created_at: "2024-11-12", check_in: "2024-12-21", check_out: "2024-12-22", customer_id: "ZA2-678-094", room: [["Rahsiah", 1, 900.00], ["Uncle Manz BBQ Chicken Quarter Chicken - Premarinated raw meats", 2, 50.00], ["Uncle Manz BBQ Lamb 250gm - Premarinated raw meats", 5, 150]], amount: 1100.00, status: "Paid", payments: [{"2024-11-12" => 1100.00}]},
    	{booking_id: "QLAT-251124", created_at: "2024-11-25", check_in: "2024-12-21", check_out: "2024-12-23", customer_id: "TJ6-424-245", room: [["Senjja", 1, 1800.00]], amount: 1800.00, status: "Paid", payments: [{"2024-11-25" => 1800.00}]},
    	{booking_id: "XFHD-021124", created_at: "2024-11-02", check_in: "2024-12-20", check_out: "2024-12-22", customer_id: "LH1-778-706", room: [["Evensong", 1, 1000.00]], amount: 1000.00, status: "Paid", payments: [{"2024-11-04" => 1000.00}]},
    	{booking_id: "VTCY-261124", created_at: "2024-11-26", check_in: "2024-12-19", check_out: "2024-12-21", customer_id: "SP3-071-063", room: [["Senjja", 1, 1800.00]], amount: 1800.00, status: "Paid", payments: [{"2024-11-27" => 1800.00}]},
    	{booking_id: "YDAM-241124", created_at: "2024-11-24", check_in: "2024-12-14", check_out: "2024-12-15", customer_id: "QR5-852-192", room: [["Senjja", 1, 900.00]], amount: 900.00, status: "Paid", payments: [{"2024-11-27" => 900.00}]},
    	{booking_id: "NNXM-221124", created_at: "2024-11-22", check_in: "2024-12-13", check_out: "2024-12-15", customer_id: "QQ1-393-510", room: [["Sasterawan", 1, 1000.00]], amount: 1000.00, status: "Paid", payments: [{"2024-11-23" => 1000.00}]},
    	{booking_id: "YBTJ-221124", created_at: "2024-11-22", check_in: "2024-12-13", check_out: "2024-12-15", customer_id: "QQ1-393-510", room: [["Evensong", 1, 1000.00]], amount: 1000.00, status: "Paid", payments: [{"2024-11-23" => 1000.00}]},
    	{booking_id: "QJNN-031124", created_at: "2024-11-03", check_in: "2024-12-06", check_out: "2024-12-08", customer_id: "PY3-217-626", room: [["Rahsiah", 1, 1800.00], ["Uncle Manz BBQ Chicken Quarter Chicken - Premarinated raw meats", 2, 50.00], ["Uncle Manz BBQ Lamb 250gm - Premarinated raw meats", 4, 120.00]], amount: 1970.00, status: "Paid", payments: [{"2024-11-04" => 1970.00}]},
    	{booking_id: "MLTG-221124", created_at: "2024-11-22", check_in: "2024-11-26", check_out: "2024-11-27", customer_id: "KA1-116-737", room: [["Evensong", 1, 500.00]], amount: 500.00, status: "Paid", payments: [{"2024-11-22" => 250.00}, {"2024-11-26" => 250.00}]},
    	{booking_id: "JJQL-021124", created_at: "2024-11-02", check_in: "2024-11-25", check_out: "2024-11-26", customer_id: "QM8-911-465", room: [["Sasterawan", 1, 500.00]], amount: 500.00, status: "Paid", payments: [{"2024-11-02" => 500.00}]},
    	{booking_id: "DFLJ-151024", created_at: "2024-10-15", check_in: "2024-11-24", check_out: "2024-11-27", customer_id: "GN7-097-521", room: [["Best Deal: Curi Curi Week Days!", 1, 0.00]], amount: 0.00, status: "Paid", payments: []},
    	{booking_id: "KDMZ-201124", created_at: "2024-11-20", check_in: "2024-11-23", check_out: "2024-11-24", customer_id: "TL5-955-841", room: [["Evensong", 1 ,500.00]], amount: 500.00, status: "Paid", payments: [{"2024-11-21" => 500.00}]},
    	{booking_id: "SNHK-251024", created_at: "2024-10-25", check_in: "2024-11-23", check_out: "2024-11-24", customer_id: "ZF7-886-146", room: [["Extra Bed", 1, 100.00], ["Sasterawan", 1, 500.00]], amount: 600.00, status: "Paid", payments: [{"2024-10-25" => 600.00}]},
    	{booking_id: "NPTC-161124", created_at: "2024-11-16", check_in: "2024-11-17", check_out: "2024-11-17", customer_id: "PB6-413-903", room: [["Day Visitor - Half Day", 1, 200.00]], amount: 200.00, status: "Paid", payments: [{"2024-11-16" => 200.00}]},
    	{booking_id: "XAZD-171124", created_at: "2024-11-17", check_in: "2024-11-17", check_out: "2024-11-18", customer_id: "NQ7-808-534", room: [["Evensong", 1, 500.00]], amount: 500.00, status: "Paid", payments: [{"2024-11-17" => 500.00}]},
    	{booking_id: "LNZF-011124", created_at: "2024-11-01", check_in: "2024-11-16", check_out: "2024-11-17", customer_id: "YK3-379-830", room: [["Hike into Lata Berembun - 5 minutes drive away", 5, 0.00], ["Senjja", 1, 900.00]], amount: 900.00, status: "Paid", payments: [{"2024-11-01" => 900.00}]},
    	{booking_id: "AJRV-081124", created_at: "2024-11-08", check_in: "2024-11-16", check_out: "2024-11-17", customer_id: "LT1-006-848", room: [["Evensong", 1, 500.00]], amount: 500.00, status: "Paid", payments: [{"2024-11-08" => 500.00}]},
    	{booking_id: "FPAV-281024", created_at: "2024-10-28", check_in: "2024-11-16", check_out: "2024-11-17", customer_id: "RA8-620-369", room: [["Sasterawan", 1, 500.00]], amount: 500.00, status: "Paid", payments: [{"2024-10-29" => 500.00}]},
    	{booking_id: "JKAZ-161124", created_at: "2024-11-16", check_in: "2024-11-16", check_out: "2024-11-17", customer_id: "QS7-371-756", room: [["Khemah", 2, 200.00], ["Tent - 4/5 persons", 1, 80.00]], amount: 280.00, status: "Paid", payments: [{"2024-11-16" => 280.00}]},
    	{booking_id: "XRPY-161024", created_at: "2024-10-16", check_in: "2024-11-16", check_out: "2024-11-17", customer_id: "TY3-359-166", room: [["Durian Runtuh", 1, 1100.00], ["Rahsiah", 1, 500.00]], amount: 1600.00, status: "Paid", payments: [{"2024-10-17" => 1600.00}]},
    	{booking_id: "JBRF-181024", created_at: "2024-10-18", check_in: "2024-11-09", check_out: "2024-11-11", customer_id: "AR2-396-884", room: [["Senjja", 1, 1000.00], ["Uncle Manz BBQ Chicken Quarter Chicken - Premarinated raw meats", 1, 25.00], ["Uncle Manz BBQ Lamb 250gm - Premarinated raw meats", 1, 30.00]], amount: 1055.00, status: "Paid", payments: [{"2020-10-18" => 1555.00}]},
    	{booking_id: "JXNX-081124", created_at: "2024-11-08", check_in: "2024-11-09", check_out: "2024-11-10", customer_id: "QD5-583-367", room: [["Durian Runtuh", 1, 900.00]], amount: 900.00, status: "Paid", payments: [{"2024-11-10" => 900.00}]},
    	{booking_id: "ATXY-011124", created_at: "2024-11-01", check_in: "2024-11-08", check_out: "2024-11-09", customer_id: "BH9-332-807", room: [["Senjja", 1, 900.00]], amount: 900.00, status: "Paid", payments: [{"2024-11-01" => 900.00}]},
    	{booking_id: "PMKN-170224", created_at: "2024-02-17", check_in: "2024-02-20", check_out: "2024-02-22", customer_id: "VG3-426-069", room: [["Evensong", 1, 500.00], ["Sasterawan", 1, 500.00]], amount: 2000.00, status: "HOLD", payments: [{"2024-02-17" => 2000.00}]},
    	{booking_id: "MZDP-030124", created_at: "2024-01-03", check_in: "2024-01-05", check_out: "2024-01-07", customer_id: "YR9-876-922", room: [["Evensong", 1, 500.00]], amount: 1000.00, status: "HOLD", payments: [{"2024-01-03" => 500.00}]},
    	{booking_id: "NTMF-151223", created_at: "2023-12-15", check_in: "2023-12-15", check_out: "2023-12-16", customer_id: "AZ9-978-147", room: [["Evensong", 1, 500.00], ["Meal ordered, Uncle Manz BBQ Lamb 250gm - Premarinated raw meats", 2, 30.00]], amount: 560.00, status: "HOLD", payments: [{"2023-12-15" => 560.00}]},
    	{booking_id: "XYLZ-100223", created_at: "2023-02-10", check_in: "2023-02-18", check_out: "2023-02-20", customer_id: "DN8-848-731", room: [["Evensong", 1, 1120.00]], amount: 1120.00, status: "HOLD", payments: [{"2023-02-10" => 560.00}]},
    	{booking_id: "BVLS-170920", created_at: "2020-09-17", check_in: "2020-09-17", check_out: "2020-09-17", customer_id: "AB1-096-622", room: [["Tempeh Shepard's Pie - Vegetarian", 2, 40]], amount: 40.00, status: "Paid", payments: [{"2020-09-17" => 40.00}]}
    ]
    
    checkfront_bookings.each do |checkfront_booking_data|
    	ActiveRecord::Base.transaction do
    		booking_id = checkfront_booking_data[:booking_id]
    		created_at = checkfront_booking_data[:created_at].to_date
    		check_in = checkfront_booking_data[:check_in].to_date
    		check_out = checkfront_booking_data[:check_out].to_date
    		customer_id = checkfront_booking_data[:customer_id]
    		amount = checkfront_booking_data[:amount].to_f
    		status = checkfront_booking_data[:status]
    		booking_item_array = checkfront_booking_data[:room]
    		payments_array = checkfront_booking_data[:payments]
    
    		customer = Customer.find_by_checkfront_reference(customer_id)
    		booking = Booking.find_or_create_by({checkfront_reference: booking_id, customer_id: customer.id})
    		
    		booking_item_array.each do |name, count, sub_total|
    			inventory = Inventory.find_or_create_by(name: name)
    			inventory.save(validate: false)
    
    			booking_item = BookingItem.find_or_create_by({
    				booking_id: booking.id,
    				inventory_id: inventory.id,
    				start_date: check_in.to_datetime,
    				end_date: check_out.to_datetime,
    				quantity: count.to_i,
    				item_price: sub_total.to_d,
    				created_at: created_at.to_datetime
    			})
    			booking_item.save
    		end
    	end
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