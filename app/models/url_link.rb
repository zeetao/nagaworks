require 'nokogiri'
require 'uri'

class UrlLink < ApplicationRecord
  belongs_to :twnfile
  
  before_save :populate_meta_data
  
  
  def self.link_types
    [
      "internal",
      "external"
    ]
  end
  
  def populate_meta_data
    if original_html_link_changed?
      doc = Nokogiri::HTML(original_html_link)
      href = doc.at('a')['href']
      parsed_url = URI.parse(href)
      path = parsed_url.path
      extracted_base_domain = parsed_url.host
      extracted_file_type = path.present? ? File.extname(path) : nil
      
      if extracted_base_domain == nil or extracted_base_domain == "twn.my"
        self.base_domain = "twn.my"
        self.link_type = "internal"
      else
        self.base_domain = extracted_base_domain
        self.link_type = "external"
      end
      
      self.path = parsed_url.path
      self.parameters = parsed_url.query
      self.file_type = extracted_file_type
      
    end
  
  end
  
  

end