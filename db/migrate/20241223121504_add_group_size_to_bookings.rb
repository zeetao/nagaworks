class AddGroupSizeToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :group_size, :text
  end
end
