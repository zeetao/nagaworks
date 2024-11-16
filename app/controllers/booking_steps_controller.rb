class BookingStepsController < ApplicationController
  include Wicked::Wizard
  steps :customer, :booking, :book_stay, :book_others, :book_food, :payment
  
  def show
    render_wizard
  end
  
  
end
