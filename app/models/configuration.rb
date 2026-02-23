# app/models/configuration.rb
class Configuration < ApplicationRecord
  # Ensure that parameter is always present and unique
  validates :parameter, presence: true, uniqueness: true

  # Method to get a configuration value by its parameter name
  def self.get(param_name)
    find_by(parameter: param_name)&.value
  end

  # Method to set a configuration value by its parameter name
  def self.set(param_name, new_value)
    config = find_or_initialize_by(parameter: param_name)
    config.update(value: new_value)
  end
end