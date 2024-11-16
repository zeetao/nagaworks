class BookingStepsController < ApplicationController
  include Wicked::Wizard
  steps :customer, :booking, :booking_items, :payment
  
  def show
    render_wizard
  end
  
  
end
