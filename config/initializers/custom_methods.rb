require 'csv'
require 'yaml'


# added functionality to ApplicationRecord class
module CustomActiveRecordMethods
  extend ActiveSupport::Concern

  included do
    # Define class-level methods here
  end

  
   
end
ActiveRecord::Base.include CustomActiveRecordMethods

# Methods to extend Objects
module CustomObjectMethods
  
end
String.include(CustomObjectMethods)

# Custom methods universal to application
module CustomApplicationMethods
  def run_safe(whodunnit, &code_block)
  	ActiveRecord::Base.transaction do
    	begin
    		PaperTrail.request(whodunnit: whodunnit) do
      		code_block.call if code_block
      	end
    	rescue StandardError => e
    		byebug if Rails.env == "development"
    	end
    end
  end

  def send_test_email(email_address)
    ActionMailer::Base.mail(
      from: Rails.application.credentials.smtp.development[:sender],
      to: email_address,
      subject: "Test from Nagaworks Mailer - #{Rails.env} - #{Time.now.to_s}",
      body: "Test Message from #{Rails.env} Server"
    ).deliver_now
  end
  
  def supersearch(klass, field, search_term, anyterm=false)
    andor = anyterm ? "OR" : "AND"

    search_terms = search_term.split(/[ ,]/).reject(&:empty?)

    results = klass.where(
      search_terms.map { |term| "#{field} ILIKE ?" }.join(" #{andor} "),
      *search_terms.map { |term| "%#{term}%" }
    )
    return results
  end
  
  def get_parameters_for_supersearch(params)
    search_parameters = params.dup
    ["target_dom", "commit", "controller", "action"].each do |deletekey| search_parameters.delete(deletekey) end
    search_parameters.delete("search") if params[:search].blank?
    
    return search_parameters.to_unsafe_h
  end
  
  def supersearch_plus(klass, search_field_name, params, intermediate = nil)
    params_copy = params.dup
    
    search_terms = params_copy[:search].present? ? params_copy[:search].split(/[ ,]/).reject(&:empty?) : []
    params_copy.delete(:search)
    
    region_search = params[:region].present? ? params_copy[:region] : []
    params_copy.delete(:region)
    
    results = klass.where(params_copy).where(
      search_terms.map { |term| "#{search_field_name} ILIKE ?" }.join(" AND "),
      *search_terms.map { |term| "%#{term}%" }
    )
    
    results = results.search_by_region(region_search, intermediate)
    return results
  end

  def import_from_csv(filepath, modelname)
    array_of_hashes = csv_to_array_of_hashes(filepath)
    array_of_hashes.each do |data_row_hash|
      # Delete nil columns
      data_row_hash.delete(nil)

      # raise ArgumentError if hash has repeated columns
      raise ArgumentError, "Duplicate Columns in data" if data_row_hash.keys.length != data_row_hash.keys.uniq.length
      modelname.constantize.create!(hash_text_keys_to_symbols(data_row_hash))
    end
  end

  def csv_to_array_of_hashes(file_path)
    array_of_hashes = []

    CSV.foreach(file_path, headers: true) do |row|
      array_of_hashes << row.to_h
    end

    array_of_hashes
  end

  def sanitize_csv(input_file_path, output_file_path)
    File.open(output_file_path, 'w') do |output_file|
      File.foreach(input_file_path) do |line|
        sanitized_line = line.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        output_file.write(sanitized_line)
      end
    end
  end

  def write_to_log(file, text)
    File.open("log/#{file}", "a") do |f|
      f.write("#{Time.zone.now.to_s} - #{text}\n")
    end
  end
  
end
Object.include(CustomApplicationMethods)