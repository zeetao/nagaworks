class AddReferenceToPayments < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :checkfront_reference, :string
  end
end
