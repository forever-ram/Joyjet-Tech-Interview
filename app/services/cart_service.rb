class CartService
  attr_accessor :articles, :carts, :delivery_fees

  def initialize(articles, carts, delivery_fees = nil)
    @articles = articles
    @carts = carts
    @delivery_fees = delivery_fees
  end

  def call
    carts_with_total = checkout_carts_and_calculate_total_price_for_items
    
    if delivery_fees.present?
      carts_with_total = apply_delivery_fees_to_cart(carts_with_total)
    end

    return carts_with_total
  end

  private

  def checkout_carts_and_calculate_total_price_for_items
    carts.map do |cart|
      {
        "id" => cart["id"],
        "total" => calculate_price(cart)
      }
    end
  end

  def calculate_price(cart)
    return 0 if cart["items"].blank?

    cart["items"].sum do |item|
      article = articles.find { |atricle| atricle["id"] == item["article_id"] }
      article["price"] * item["quantity"]
    end
  end

  def apply_delivery_fees_to_cart(carts_with_total)
    DeliveryFeeService.new(carts_with_total, delivery_fees).call
  end
end