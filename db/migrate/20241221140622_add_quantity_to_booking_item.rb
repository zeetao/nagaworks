class AddQuantityToBookingItem < ActiveRecord::Migration[7.2]
  def change
    add_column :booking_items, :quantity, :integer
  end
end
