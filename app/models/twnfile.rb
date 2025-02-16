require 'nokogiri'

class Twnfile < ApplicationRecord
  has_many :url_links
  
  validates :filename_full, presence: true
  validates :filename_full, uniqueness: true
  
  scope :html, -> { where(file_extension: ["htm", "html"]) }
  scope :images, -> { where(file_extension: ["gif", "jpg", "jpeg", "png", "ico"]) }
  scope :docs, -> { where(file_extension: ["doc", "pdf", "ppt", "docx", "xlsx", "rtf", "txt"]) }
  scope :media, -> { where(file_extension: ["mp4"]) }
  scope :unknown, -> { where(file_extension: [nil, "xml", "tmp", "WIPOrekindlespatenttalks", "HOT", "dta", "js", "bak", "dwt", "php", "htaccess", "current", "hist", "db"]) }
  
  scope :processed, -> { where.not(comment: nil) }
  scope :unprocessed, -> { where(comment: nil) }
 
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
  
    # update sanitised content for field
    if self.html_content_changed?
      text = Twnfile.sanitise_html_text(self.html_content)
      self.sanitised_content = text
    end
  
  end
  
  def website_url
    "twn.my#{self.filename_full}"
  end
  
  def self.sanitise_html_text(html_text)
    doc = Nokogiri::HTML(html_text)
    # Remove scripts, styles, and non-text elements
    doc.css('script, style').remove
    # Extract plain text
    doc.text.gsub(/\s+/, ' ').strip
    
  end
  
  def extract_url_links
    ActiveRecord::Base.transaction do
      begin
        doc = Nokogiri::HTML(self.html_content)
        links = doc.css('a').map { |link| link.to_html }.compact
        
        links.each do |link|
          url_link = UrlLink.find_or_initialize_by(original_html_link: link)
          if url_link.new_record?
            url_link.twnfile_id = self.id
            url_link.save!  
          end
        end
      
        self.update_column(:comment, "Extracted Links #{Time.now.to_datetime}")
      rescue StandardError => e
        self.update_column(:comment, "Extracted Links: Error #{e.message}")
      end
    end
  end
  
  def update_link_count
    link_count = self.url_links.count
    self.update_column(:link_count, link_count)
  end
  
  def update_references
    link_path = self.filename_full.sub(/^\//, "")
    url_link_ids = UrlLink.where("path LIKE ?", "%#{link_path}%").pluck(:id)
    self.update_column(:referenced_by_ids, url_link_ids)
  end
  
  def extract_html
    if ["htm", "html"].include?(self.file_extension)
      html_content = read_file
      sanitized_content = html_content.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
      self.update_column(:html_content, sanitized_content)
    end
  end
  
  def read_file
    filepath = "#{Twnfile.twnrootdirectory}#{self.filename_full}"
    return File.read(filepath)
  end
  
  def extract_data
    # to extrac the contents of the page
    html_content = read_file
    doc = Nokogiri::HTML(html_content)
    content_container = doc.css('table tr')[1]
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