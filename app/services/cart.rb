class Cart
  include ActiveModel::Model
  
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
    when :book_stay
      self.booking_items = step_params[:booking_items].map do |item_params|
        BookingItem.new(item_params)
      end
    when :book_others
      self.booking_items = step_params[:booking_items].map do |item_params|
        BookingItem.new(item_params)
      end
    when :book_food
      self.booking_items = step_params[:booking_items].map do |item_params|
        BookingItem.new(item_params)
      end
    when :payment
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
  
  def persisted?
    false
  end

  def to_key
    nil
  end

  # Optionally override model name if you want it to appear as 'cart' in form parameters
  def self.model_name
    ActiveModel::Name.new(self, nil, "Cart")
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
