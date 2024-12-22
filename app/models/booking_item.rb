class BookingItem < ApplicationRecord
  belongs_to :booking
  belongs_to :inventory
  
  after_save :update_booking_aggregated_data
  after_save :update_inventory_aggregated_data
  
  validates :booking_id, :inventory_id, :start_date, :end_date, :item_price, presence: true
  
  def update_booking_aggregated_data
    booking = self.booking
    
    booking.update({
      items_count: booking.booking_items.count
    })
  end
  
  def update_inventory_aggregated_data
    inventory = self.inventory
    
    booking_items = inventory.booking_items
    
    inventory.update({
      booking_items_count: booking_items.count,
      total_booking_value: booking_items.pluck(:item_price).compact.sum.to_f
    })
  end
end