require 'csv'

class CheckfrontRecord < ApplicationRecord
  
  scope :to_migrate, -> { where(status: "Imported") }
  scope :migration_fail, -> { where(status: "Migration Failed") }
  scope :customers, -> { where(table_name: "Customers") }
  scope :new_bookings, -> { where(table_name: "New Bookings") }
  scope :agoda_bookings, -> { where(table_name: "Agoda Bookings") }
  scope :airbnb_bookings, -> { where(table_name: "Airbnb Bookings") }
  scope :checkfront_bookings, -> { where(table_name: "Checkfront Bookings") }
  
  def self.read_csv(filename)
    data = CSV.open(filename, headers: true, header_converters: :symbol).map(&:to_h)
  end
  
  def self.import(table_name, filename)
    # path = "/home/ubuntu/environment/nagaworks/db/checkfront/new"
    # newbooking_filename = "#{path}/Awanmulan Bookings - New Booking.csv"
    # agodabooking_filename = "#{path}/Awanmulan Bookings - Agoda Bookings.csv"
    # airbnbbooking_filename = "#{path}/Awanmulan Bookings - Airbnb Bookings.csv"
    # checkfrontbooking_filename = "#{path}/Awanmulan Bookings - Checkfront Bookings.csv"
    # customer_filename = "#{path}/Awanmulan Bookings - Customer.csv"  
    
    array_of_hashes = read_csv(filename)
    bulk_update_create(array_of_hashes, table_name)
  end
  
  def self.bulk_update_create(array_of_hashes, table_name)
    array_of_hashes.each do |data_row_hash|
      # Delete nil columns
      data_row_hash.delete(nil)

      checkfront_record = CheckfrontRecord.find_by(table_name: table_name, row_data: data_row_hash)

      common_attributes = {
        table_name: table_name,
        row_data: data_row_hash
      }

      if checkfront_record.present?
        # Check if any changes
        if checkfront_record.row_data != data_row_hash
          # Update the existing record
          checkfront_record.update(common_attributes.merge({
            status: "Changed",
            notes: "Record has been updated. Need remigration"
          }))
        end
        # do nothing if no changes
      else
        # Create a new record
        CheckfrontRecord.create!(common_attributes.merge({
          status: "Imported",
          notes: "Newly imported. To be migrated"
        }))
      end
    end
    
  end
end