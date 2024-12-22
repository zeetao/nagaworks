class AddInvoiceUrLtoBooking < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :invoice_url, :string
  end
end
