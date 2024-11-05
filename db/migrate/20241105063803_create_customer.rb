class CreateCustomer < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.string :checkfront_reference
      t.timestamps
    end
  end
end
