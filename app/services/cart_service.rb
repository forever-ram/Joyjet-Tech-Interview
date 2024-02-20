class CartService
  attr_accessor :articles, :carts

  def initialize(articles, carts)
    @articles = articles
    @carts = carts
  end

  def call
    carts.map do |cart|
      {
        "id" => cart["id"],
        "total" => calculate_price(cart)
      }
    end
  end

  private
  def calculate_price(cart)
    return 0 if cart["items"].blank?

    cart["items"].sum do |item|
      article = articles.find { |atricle| atricle["id"] == item["article_id"] }
      article["price"] * item["quantity"]
    end
  end
end