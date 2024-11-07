class AddBookingCountToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :bookings_count, :integer
    add_column :customers, :total_booking_value, :float
    add_column :bookings, :items_count, :integer
    add_column :bookings, :payments_count, :integer
    add_column :bookings, :total_payments, :float
    add_column :bookings, :status, :string
    add_column :inventories, :booking_items_count, :integer
  end
end
