class BookingItemsController < ApplicationController

  def index
    
    if params[:start_date].present?
      @current_date = params[:start_date].to_date
      
      @booking_items = BookingItem.joins(:inventory)
        .where("inventories.category = ?", "Rooms")
        .where("start_date >= ?", @current_date)
        .where("start_date <= ?", @current_date + 7.days)
      
      render turbo_stream: turbo_stream.replace("calendar", partial: "booking_items/calendar", locals: {booking_items: @booking_items, current_date: @current_date})
    else
      @booking_items = BookingItem.joins(:inventory)
        .where("inventories.category = ?", "Rooms")
        .where("start_date >= ?", 1.month.ago)
        .where("start_date <= ?", 1.month.ago + 7.days)
        
      @current_date = @booking_items.first&.start_date || Time.now.to_date
    end
  end

end
