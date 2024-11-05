class CreateInventory < ActiveRecord::Migration[7.2]
  def change
    create_table :inventories do |t|
      t.string :name
      t.string :category
      t.string :details
      t.string :description
      t.float :unit_price
      t.timestamps
    end
  end
end
