class BookingsController < ApplicationController
  include Wicked::Wizard
  steps :customer, :book_stay, :book_others, :book_food, :payment

  before_action :set_cart

  def show
    render_wizard
  end

  def update
    if @cart.update(cart_params)
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end 

  def finish_wizard_path
    bookings_path
  end

  private

  def cart_params
    params.require(:cart).permit(
      customer: [:email, :name, :phone, :address],
      book_stay: [:inventory_id, :start_date, :end_date],
      book_others: [:inventory_id, :start_date, :end_date, :timeslot],
      book_food: [:inventory_id, :start_date, :end_date, :timeslot],
      payment: [:paid_amount]
    )
  end
  
  def set_cart
    book_stay_items = cart_params[:book_stay].present? ? cart_params[:book_stay].map { |item| BookingItem.new(item) } : []
    book_others_items = cart_params[:book_others].present? ? cart_params[:book_others].map { |item| BookingItem.new(item) } : []
    book_food_items = cart_params[:book_food].present? ? cart_params[:book_food].map { |item| BookingItem.new(item) } : []
    booking_items_array = (book_stay_items + book_others_items + book_food_items) || []
    
    customer_params = cart_params[:customer].present? ? Customer.new(cart_params[:customer]) : []
    
    @cart = Cart.new(
      customer: customer_params,
      booking: Booking.new,
      booking_items: booking_items_array
    )
  rescue ActionController::ParameterMissing
    @cart = Cart.new
  end

end