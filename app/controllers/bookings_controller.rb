class BookingsController < ApplicationController

  def index
    
  end
  
  def show
  end

  def new
    @booking = Booking.new
  end

  def edit
  end

  # POST /booking or /booking.json
  def create
    @booking = Booking.new(booking_params)

    respond_to do |format|
      if @booking.save
        format.html { redirect_to booking_url(@booking), notice: "Booking was successfully created." }
        # format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "Booking was successfully recorded."}) }
        # format.json { render :show, status: :created, location: @booking }
      else
        # format.html { redirect_to new_booking_path, status: :unprocessable_entity, alert: @booking.errors }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @booking.errors}) }
        # format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        # format.html { redirect_to booking_url(@booking), notice: "Booking was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "Booking was successfully updated."}) }
        # format.json { render :show, status: :ok, location: @booking }
      else
        # format.html { redirect_to edit_booking_path(@booking), status: :unprocessable_entity, alert: @booking.errors }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @booking.errors}) }
        # format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end


end
