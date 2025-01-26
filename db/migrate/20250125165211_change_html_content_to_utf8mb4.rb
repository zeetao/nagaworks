class ChangeHtmlContentToUtf8mb4 < ActiveRecord::Migration[7.2]
  def up
    execute "ALTER TABLE twnfiles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    change_column :twnfiles, :html_content, :text, limit: 16_777_215 # Optional for very large content
  end

  def down
    execute "ALTER TABLE twnfiles CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci"
    change_column :twnfiles, :html_content, :text
  end
end
