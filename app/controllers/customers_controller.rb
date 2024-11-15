class CustomersController < ApplicationController
  
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "Customer was successfully created."}) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @customer.errors}), status: :unprocessable_entity }
      end
    end
  end
  
  # def update
  #   respond_to do |format|
  #     if @customer.update(customer_params)
  #       format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "Customer was successfully updated."}) }
  #     else
  #       format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @customer.errors}) }
  #     end
  #   end
  # end
  
  private
  
  # Only allow a list of trusted parameters through.
  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :address)
  end

end
