class BookingItemsController < ApplicationController

  def index
    if params[:start_date].present?
      @booking_items = BookingItem.joins(:inventory).where("inventories.category = ?", "Rooms").where("inventories.category = ?", "Rooms")
        .where("start_date >= ?", params[:start_date].to_date)
        .where("start_date <= ?", params[:start_date].to_date + 6.days)
        
      render turbo_stream: turbo_stream.replace("calendar", partial: "booking_items/calendar", locals: {booking_items: @booking_items})
    else
      @booking_items = BookingItem.joins(:inventory)
        .where("inventories.category = ?", "Rooms")
        .where("start_date >= ?", 1.month.ago)
        .where("start_date <= ?", 1.month.ago + 6.days)
    end
  end

end
