class CustomersController < ApplicationController

  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to booking_url(@customer), notice: "Booking was successfully created." }
        # format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "Customer was successfully recorded."}) }
        # format.json { render :show, status: :created, location: @customer }
      else
        # format.html { redirect_to new_booking_path, status: :unprocessable_entity, alert: @customer.errors }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @customer.errors}) }
        # format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  # Only allow a list of trusted parameters through.
  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :address)
  end

end
