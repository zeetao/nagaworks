class CreateImportTables < ActiveRecord::Migration[7.2]
  def change
    create_table :checkfront_records do |t|
      t.string :table_name
      t.string :status
      t.datetime :migrated_at
      t.json :row_data
      
      t.timestamps
    end
  end
end
