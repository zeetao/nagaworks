class CreateTwnfiles < ActiveRecord::Migration[7.2]
  def up
    create_table :twnfiles do |t|
      t.text :filename_full
      t.string :root_filename
      t.string :old_twn_url
      t.json :tags
      t.json :categories
      t.text :html_content
      t.text :abstract
      t.string :file_extension
      
      t.timestamps
    end
    
  end
end
