class AddLinkCountToTwnFile < ActiveRecord::Migration[7.2]
  def change
    add_column :twnfiles, :link_count, :integer
    add_column :twnfiles, :referenced_by_ids, :json
  end
end
