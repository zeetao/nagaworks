class CreateUrlLinksTable < ActiveRecord::Migration[7.2]
  def change
    create_table :url_links do |t|
      t.integer :twnfile_id
      t.text :original_html_link
      t.string :link_type
      t.string :base_domain
      t.string :path
      t.string :parameters
      t.string :file_type
      t.timestamps
    end
  end
end
