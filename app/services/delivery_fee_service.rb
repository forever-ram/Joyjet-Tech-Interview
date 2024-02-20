class DeliveryFeeService
  attr_accessor :carts, :delivery_fees

  def initialize(carts, delivery_fees)
    @carts = carts
    @delivery_fees = delivery_fees
  end

  def call
    carts.map do |cart|
      cart.merge("total" => add_delivery_fee(cart["total"]))
    end
  end

  private
  def add_delivery_fee(cart_price)
    delivery_fee = get_delivery_fee(cart_price)
    if delivery_fee.present?
      cart_price + delivery_fee["price"]
    else
      raise MissingDeliveryFeeRangeError, cart_price
    end
  end

  def get_delivery_fee(cart_price)
    delivery_fees.find do |fee|
      cart_price >= fee["eligible_transaction_volume"]["min_price"] &&
      (fee["eligible_transaction_volume"]["max_price"].blank? ||
      cart_price < fee["eligible_transaction_volume"]["max_price"])
    end
  end
end