class CartService
  attr_accessor :articles, :carts, :delivery_fees, :discounts

  def initialize(articles, carts, delivery_fees = nil, discounts = nil)
    @articles = articles
    @carts = carts
    @delivery_fees = delivery_fees
    @discounts = discounts
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
      article = articles.find { |_article| _article["id"] == item["article_id"] }
      get_discounted_price(article, item)
    end.to_i
  end

  def get_discounted_price(article, item)
    total_price = article["price"] * item["quantity"]
    discount = get_discount(article)

    return total_price unless discount.present?

    if discount["type"] == "amount"
      total_price - (discount["value"] * item["quantity"])
    elsif discount["type"] == "percentage"
      discount_amount = percentage_discount_amount(article["price"], discount["value"])
      total_price - (discount_amount * item["quantity"])
    end
  end

  def get_discount(article)
    return if discounts.blank?
    discounts.find do |discount|
      article["id"] == discount["article_id"]
    end
  end

  def percentage_discount_amount(article_price, discount_percentage)
    ((article_price * discount_percentage) / 100.0)
  end

  def apply_delivery_fees_to_cart(carts_with_total)
    DeliveryFeeService.new(carts_with_total, delivery_fees).call
  end
end