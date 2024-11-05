class CreateBooking < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.string :booking_reference
      t.string :checkfront_reference
      t.float :tatal_price
      t.timestamps
    end
  end
end
