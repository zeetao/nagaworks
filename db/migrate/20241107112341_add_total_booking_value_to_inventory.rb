class AddTotalBookingValueToInventory < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :total_booking_value, :float
  end
end
