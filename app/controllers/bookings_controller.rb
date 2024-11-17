class BookingsController < ApplicationController
  include Wicked::Wizard
  steps :customer, :book_stay, :book_others, :book_food, :payment

  before_action :initialize_cart, only: %i[show update]

  def show
    render_wizard
  end

  def update
    @cart.assign_attributes(step_params)
    if @cart.valid_for_step?(step)
      render_wizard @cart
    else
      render step
    end
  end

  def finish_wizard_path
    bookings_path
  end

  private

  def initialize_cart
    @cart ||= Cart.new(
      customer: Customer.find_by(id: params[:customer_id]),
      booking: Booking.find_by(id: params[:booking_id])
    )
  end

  def step_params
    case step
    when :customer
      params.require(:cart).permit(booking: [:name, :phone, :email, :address, :start_date, :end_date]).merge(step: step)
    when :book_stay
      params.require(:cart).permit(booking_items: [:inventory_id, :start_date, :end_date]).merge(step: step)
    when :book_others
      params.require(:cart).permit(booking_items: [:inventory_id, :start_date, :end_date, :timeslot]).merge(step: step)
    when :book_food
      params.require(:cart).permit(booking_items: [:inventory_id, :start_date, :end_date, :timeslot]).merge(step: step)
    when :payment
      params.require(:cart).permit(payments: [:paid_amount]).merge(step: step)
    end
  end
end