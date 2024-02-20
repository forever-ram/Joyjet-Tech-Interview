require 'rails_helper'

RSpec.describe DeliveryFeeService, type: :service do
  let(:carts) do
    [
      { "id" => 1, "total" => 200 }, # total without delivery fee
      { "id" => 2, "total" => 1000 } # total without delivery fee
    ]
  end

  let(:delivery_fees) do
    [
      { "eligible_transaction_volume" => { "min_price" => 0, "max_price" => 500 }, "price" => 50 },
      { "eligible_transaction_volume" => { "min_price" => 500, "max_price" => 1000 }, "price" => 100 },
      { "eligible_transaction_volume" => { "min_price" => 1000, "max_price" => nil }, "price" => 0 }
    ]
  end

  describe '#call' do
    it 'adds delivery fee to each cart total' do
      delivery_fee_service = DeliveryFeeService.new(carts, delivery_fees)
      expect(delivery_fee_service.call).to eq([
        { "id" => 1, "total" => 250 }, # 200 (cart total) + 50 (delivery fee)
        { "id" => 2, "total" => 1000 } # 1000 (cart total) + 0 (delivery fee)
      ])
    end

    context 'when delivery_fees range is not available for the cart total' do
      it 'raises MissingDeliveryFeeRangeError' do
        delivery_fees.pop # deleted delivery_fees range for cart total 1000
        delivery_fee_service = DeliveryFeeService.new(carts, delivery_fees)
        expect { delivery_fee_service.call }.to raise_error(MissingDeliveryFeeRangeError)
      end
    end
  end
end
