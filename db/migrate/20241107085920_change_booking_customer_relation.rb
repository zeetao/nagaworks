class ChangeBookingCustomerRelation < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :customer_id, :integer
  end
end
