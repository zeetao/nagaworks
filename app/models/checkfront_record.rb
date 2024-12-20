class CheckfrontRecord < ApplicationRecord

  serialize :row_data, JSON
end