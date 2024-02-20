class MissingDeliveryFeeRangeError < StandardError
  attr_accessor :price

  def initialize(price)
    @price = price
  end

  def message
    "Delivery fee is missing for the range of price - #{price}"
  end
end
