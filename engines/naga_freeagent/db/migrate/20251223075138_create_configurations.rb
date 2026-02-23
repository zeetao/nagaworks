class CreateConfigurations < ActiveRecord::Migration[7.2]
  def change
    create_table :configurations do |t|
      t.string :parameter
      t.string :value

      t.timestamps
    end
  end
end
