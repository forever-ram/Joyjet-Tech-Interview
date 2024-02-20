require 'rails_helper'

RSpec.describe CartService, type: :service do
  describe "#call" do
    let(:articles) do
      [
        { "id" => 1, "name" => "water", "price" => 100 },
        { "id" => 2, "name" => "honey", "price" => 200 }
      ]
    end

    let(:carts) do
      [
        { "id" => 1, "items" => [{ "article_id" => 1, "quantity" => 2 }] },
        { "id" => 2, "items" => [{ "article_id" => 2, "quantity" => 1 }] }
      ]
    end

    it "calculates total price for each cart" do
      service = CartService.new(articles, carts)
      expect(service.call).to eq([
        { "id" => 1, "total" => 200 },
        { "id" => 2, "total" => 200 }
      ])
    end

    context "when carts are empty" do
      let(:carts) { [] }

      it "returns empty array" do
        service = CartService.new(articles, carts)
        expect(service.call).to eq([])
      end
    end

    context "when items in a cart are empty" do
      let(:carts) do
        [
          { "id" => 1, "items" => [{ "article_id" => 1, "quantity" => 2 }] },
          { "id" => 2, "items" => [] }
        ]
      end

      it "returns total as zero" do
        service = CartService.new(articles, carts)
        expect(service.call).to eq([
          { "id" => 1, "total" => 200 },
          { "id" => 2, "total" => 0 }
        ])
      end
    end
  end
end
