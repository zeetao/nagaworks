class BookingItem < ApplicationRecord
  belongs_to :booking
  belongs_to :inventory
end