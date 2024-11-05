class CreateBookingItems < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_items do |t|
      t.integer :booking_id
      t.integer :inventory_id
      t.date :start_date
      t.date :end_date
      t.string :timeslot
      t.float :item_price
      t.timestamps
    end
  end
end
