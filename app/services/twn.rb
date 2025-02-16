class Twn
  
  def self.update_link_meta_data
    Twnfile.html.processed.in_batches(of: 1000) do |batch|
      batch.each do |twnfile|
        Twnfile.transaction do
          twnfile.update_link_count
          twnfile.update_references
          twnfile.update_column(:comment, "updated link count and references #{Time.now}")
        end
      end
    end
  end
  
end