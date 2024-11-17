class Cart
  attr_accessor :customer, :booking, :booking_items, :payments

  def initialize(customer: nil, booking: nil, booking_items: [], payments: [])
    @customer = customer || Customer.new
    @booking = booking || Booking.new
    @booking_items = booking_items.presence || [BookingItem.new]
    @payments = payments.presence ||[Payment.new]
  end

  def assign_attributes(step_params)
    case step_params[:step]
    when :customer
      customer.assign_attributes(step_params[:customer])
    when :booking
      booking.assign_attributes(step_params[:booking])
    when :book_items
      self.booking_items = step_params[:booking_items].map do |item_params|
        BookingItem.new(item_params)
      end
    when :payments
      self.payments = step_params[:payments].map do |payment_params|
        Payment.new(payment_params)
      end
    end
  end

  def valid_for_step?(step)
    case step
    when :customer
      customer.valid?
    when :booking
      booking.valid?
    when :book_items
      booking_items.all?(&:valid?)
    when :payments
      payments.all?(&:valid?)
    else
      false
    end
  end

  def save
    ActiveRecord::Base.transaction do
      customer.save!
      booking.customer = customer
      booking.save!
      booking_items.each { |item| item.booking = booking }
      booking_items.each(&:save!)
    end
  rescue ActiveRecord::RecordInvalid => e
    false
  end
end