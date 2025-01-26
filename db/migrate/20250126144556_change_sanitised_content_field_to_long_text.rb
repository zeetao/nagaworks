class ChangeSanitisedContentFieldToLongText < ActiveRecord::Migration[7.2]
  def change
    change_column :twnfiles, :sanitised_content, :longtext
  end
end
