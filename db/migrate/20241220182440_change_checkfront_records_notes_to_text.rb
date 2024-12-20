class ChangeCheckfrontRecordsNotesToText < ActiveRecord::Migration[7.2]
  def change
    change_column :checkfront_records, :notes, :text
  end
end
