class CreateJoinCustomerBookings < ActiveRecord::Migration[7.2]
  def change
    def change
      create_join_table :customers, :bookings do |t|
        t.index :customer_id
        t.index :booking_id
      end
    end
  end
end
