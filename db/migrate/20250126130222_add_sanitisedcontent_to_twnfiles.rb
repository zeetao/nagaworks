class AddSanitisedcontentToTwnfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :twnfiles, :sanitised_content, :text
  end
end
