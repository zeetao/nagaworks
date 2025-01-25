class Twnfile < ApplicationRecord
  
  validates :filename_full, presence: true
  validates :filename_full, uniqueness: true

  before_save :populate_fields

  def self.twnrootdirectory
    "/mnt/TWN"
  end

  def populate_fields
    filematrix = self.filename_full.match(/(.*)\/([^\/]+)$/)
    root_filename = filematrix[2]
  	tag_array = filematrix[1].split("/")
  	tag_array.delete("")
  	file_extension_match = root_filename.match(/[.]([[a-z][A-Z][0-9]]+)$/)
    file_extension = file_extension_match.present? ? file_extension_match[1] : nil
    
    self.root_filename = root_filename
    self.tags = tag_array
    self.file_extension = file_extension
  end
  
  def website_url
    "twn.my#{self.filename_full}"
  end
  
  def read_file
    filepath = "#{Twnfile.twnrootdirectory}#{self.filename_full}"
    file = File.open(filepath, "r")
    
    
    
  end
  
  def self.import_from_file(filepath = "/home/ubuntu/environment/nagaworks/db/twn/twnmap.txt")
    
    file = File.open(filepath, "r")
    
    file.each do |line|
    	filedata = line.split(",")
    	created_date = filedata[0].gsub("Created: ","").to_datetime
    	updated_date = filedata[1].gsub(" Last Updated: ", "").to_datetime
    	
    	filename_full = filedata[2].gsub(" Filename: .","").strip
    	
    
      twnfile = Twnfile.find_or_create_by({
        filename_full: filename_full,
        created_at: created_date,
        updated_at: updated_date
      })
      
      twnfile.save
      
    end
  end
  
end