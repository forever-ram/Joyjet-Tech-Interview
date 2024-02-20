require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  describe "POST #checkout" do
    let(:articles) do
      [
        { "id" => 1, "name" => "water", "price" => 100 },
        { "id" => 2, "name" => "honey", "price" => 200 },
        { "id" => 3, "name" => "mango", "price" => 400 },
        { "id" => 4, "name" => "tea", "price" => 1000 }
      ]
    end

    let(:carts) do
      [
        {
          "id" => 1,
          "items" => [
            { "article_id" => 1, "quantity" => 6 },
            { "article_id" => 2, "quantity" => 2 },
            { "article_id" => 4, "quantity" => 1 }
          ]
        }, {
          "id" => 2,
          "items" => [
            { "article_id" => 2, "quantity" => 1 },
            { "article_id" => 3, "quantity" => 3 }
          ]
        }, {
          "id" => 3,
          "items" => []
        }
      ]
    end

    let(:output) {{
      "carts" => [
        { "id" => 1, "total" => 2000 },
        { "id" => 2, "total" => 1400 },
        { "id" => 3, "total" => 0 }
      ]
    }}

    it 'returns a success response' do
      post :checkout, params: { articles: articles, carts: carts }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "should call CartService" do
      expect(CartService).to receive(:new).and_return(double('cart_service', call: {}))
      post :checkout, params: { articles: articles, carts: carts }, as: :json
    end

    it "should return correct response" do
      post :checkout, params: { articles: articles, carts: carts }, as: :json
      expect(JSON.parse(response.body)).to eq(output)
    end

    context "Invalid Request Params" do
      it "should return correct error message to inform the incorrect param" do
        new_articles = [*articles, { "id" => 5, "name" => "coffee", "price" => "300" }]
        post :checkout, params: { articles: new_articles, carts: carts }, as: :json
        expect(JSON.parse(response.body).deep_symbolize_keys).to eq({
          error: "The property '#/articles/4/price' of type string did not match the following type: integer"
        })
      end

      it "should return correct error message if any of carts or articles are missing from the params" do
        post :checkout, params: { articles: articles }, as: :json
        expect(JSON.parse(response.body).deep_symbolize_keys).to eq({
          error: "The property '#/' did not contain a required property of 'carts'"
        })
      end
    end

    context 'With delivery_fees' do
      let(:delivery_fees) do
        [
          {
            "eligible_transaction_volume" => { "min_price" => 0, "max_price" => 1000 },
            "price" => 800
          },
          {
            "eligible_transaction_volume" => { "min_price" => 1000, "max_price" => 2000 },
            "price" => 400
          },
          {
            "eligible_transaction_volume" => { "min_price" => 2000, "max_price" => nil },
            "price" => 0
          }
        ]
      end

      let(:expected_result) do
        {
          "carts" => [
            {
              "id" => 1,
              "total" => 2000
            },
            {
              "id" => 2,
              "total" => 1800
            },
            {
              "id" => 3,
              "total" => 800
            }
          ]
        }
      end

      it "should return correct response" do
        post :checkout, params: {
          articles: articles,
          carts: carts,
          delivery_fees: delivery_fees
        }, as: :json
        expect(JSON.parse(response.body)).to eq(expected_result)
      end

      context 'when missing delivery fee for a range' do
        before { delivery_fees.pop }

        it 'returns an unprocessable entity response' do
          post :checkout, params: {
            articles: articles,
            carts: carts,
            delivery_fees: delivery_fees
          }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
  
        it 'renders the error message' do
          post :checkout, params: {
            articles: articles,
            carts: carts,
            delivery_fees: delivery_fees
          }, as: :json
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Delivery fee is missing for the range of price - 2000' })
        end
      end

      context 'with discounts' do
        let(:discounts) do
          [
            { "article_id" => 1, "type" => "amount", "value" => 20 },
            { "article_id" => 2, "type" => "percentage", "value" => 10 }
          ]
        end

        it "should return cart values on discounted price with delivery_fee applied" do
          post :checkout, params: {
            articles: articles,
            carts: carts,
            delivery_fees: delivery_fees,
            discounts: discounts
          }, as: :json
          expect(JSON.parse(response.body)).to eq({
            "carts" => [
              {
                "id" => 1,
                "total" => 2240 # 1840 (discounted price) + 400 (delivery fee)
              },
              {
                "id" => 2,
                "total" => 1780 # 1380 (discounted price) + 400 (delivery fee)
              },
              {
                "id" => 3,
                "total" => 800
              }
            ]
          })
        end
      end
    end

    context 'with invalid discounts parameter' do
      it 'returns an unprocessable entity response' do
        invalid_discounts = [
          { "article_id" => 2, "type" => "amount" }
        ]
        post :checkout, params: { articles: articles, carts: carts, discounts: invalid_discounts }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders the error message' do
        invalid_discounts = [
          { "article_id" => 2, "type" => "amount" }
        ]
        post :checkout, params: { articles: articles, carts: carts, discounts: invalid_discounts }, as: :json
        expect(JSON.parse(response.body)).to eq({ 'error' => "The property '#/discounts/0' did not contain a required property of 'value'" })
      end
    end
  end
end
