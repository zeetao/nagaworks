class RenameColumnBooking < ActiveRecord::Migration[7.2]
  def change
    rename_column :bookings, :tatal_price, :total_price
  end
end
