class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.integer :booking_id
      t.float :paid_amount
      t.float :refund_amount
      t.timestamps
    end
  end
end
