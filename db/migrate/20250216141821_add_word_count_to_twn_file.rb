class AddWordCountToTwnFile < ActiveRecord::Migration[7.2]
  def change
    add_column :twnfiles, :word_count, :integer
  end
end
