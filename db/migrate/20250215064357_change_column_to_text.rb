class ChangeColumnToText < ActiveRecord::Migration[7.2]
  def change
    change_column :twnfiles, :comment, :text
  end
end
