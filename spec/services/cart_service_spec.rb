require 'rails_helper'

RSpec.describe CartService, type: :service do
  let(:articles) do
    [
      { "id" => 1, "name" => "water", "price" => 100 },
      { "id" => 2, "name" => "honey", "price" => 200 }
    ]
  end

  let(:carts) do
    [
      { "id" => 1, "items" => [{ "article_id" => 1, "quantity" => 2 }] },
      { "id" => 2, "items" => [{ "article_id" => 2, "quantity" => 5 }] }
    ]
  end

  let(:delivery_fees) do
    [
      { "eligible_transaction_volume" => { "min_price" => 0, "max_price" => 1000 }, "price" => 50 },
      { "eligible_transaction_volume" => { "min_price" => 1000, "max_price" => nil }, "price" => 0 }
    ]
  end

  describe '#call' do
    context 'when delivery fees are not provided' do
      it 'does not apply any delivery fees' do
        cart_service = CartService.new(articles, carts)
        expect(cart_service.call).to eq([
          { "id" => 1, "total" => 200 }, # (price of water) * 2 (quantity)
          { "id" => 2, "total" => 1000 } # (price of honey) * 5 (quantity)
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

    context 'when delivery fees are provided' do
      it 'applies delivery fees to the total price' do
        cart_service = CartService.new(articles, carts, delivery_fees)
        expect(cart_service.call).to eq([
          { "id" => 1, "total" => 250 }, # (price of water) * 2 (quantity) + 50 (delivery fee)
          { "id" => 2, "total" => 1000 } # (price of honey) * 5 (quantity) +  0 (delivery fee)
        ])
      end
    end

    context 'when discounts are provided' do
      let(:discounts) do
        [
          { "article_id" => 1, "type" => "amount", "value" => 20 },
          { "article_id" => 2, "type" => "percentage", "value" => 10 }
        ]
      end
    
      it 'applies discounts to the total price' do
        cart_service = CartService.new(articles, carts, nil, discounts)
        expect(cart_service.call).to eq([
          { "id" => 1, "total" => 160 }, # (price of water - 20) * 2 (quantity)
          { "id" => 2, "total" => 900 } # (price of honey) * 5 (quantity) - 10% discount
        ])
      end
    end
    
    context 'when both delivery fees and discounts are provided' do
      let(:discounts) do
        [
          { "article_id" => 1, "type" => "amount", "value" => 20 },
          { "article_id" => 2, "type" => "percentage", "value" => 10 }
        ]
      end
    
      it 'applies both delivery fees and discounts to the total price' do
        cart_service = CartService.new(articles, carts, delivery_fees, discounts)
        expect(cart_service.call).to eq([
          { "id" => 1, "total" => 210 }, # (price of water - 20) * 2 (quantity) + 50 (delivery fee)
          { "id" => 2, "total" => 950 } # (price of honey) * 5 (quantity) - 10% discount +  50 (delivery fee)
        ])
      end
    end    
  end
end
