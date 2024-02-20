require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  describe "POST #checkout" do
    let(:input) do
      {
        articles: [
          { "id": 1, "name": "water", "price": 100 },
          { "id": 2, "name": "honey", "price": 200 },
          { "id": 3, "name": "mango", "price": 400 },
          { "id": 4, "name": "tea", "price": 1000 }
        ],
        carts: [
          {
            "id": 1,
            "items": [
              { "article_id": 1, "quantity": 6 },
              { "article_id": 2, "quantity": 2 },
              { "article_id": 4, "quantity": 1 }
            ]
          }, {
            "id": 2,
            "items": [
              { "article_id": 2, "quantity": 1 },
              { "article_id": 3, "quantity": 3 }
            ]
          }, {
            "id": 3,
            "items": []
          }
        ]
      }
    end

    let(:output) {{
      "carts": [
        { "id": 1, "total": 2000 },
        { "id": 2, "total": 1400 },
        { "id": 3, "total": 0 }
      ]
    }}

    it 'returns a success response' do
      post :checkout, params: { articles: input[:articles], carts: input[:carts] }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "should call CartService" do
      expect(CartService).to receive(:new).and_return(double('cart_service', call: {}))
      post :checkout, params: { articles: input[:articles], carts: input[:carts] }, as: :json
    end

    it "should return correct response" do
      post :checkout, params: { articles: input[:articles], carts: input[:carts] }, as: :json
      expect(JSON.parse(response.body).deep_symbolize_keys).to eq(output)
    end

    context "Invalid Request Params" do
      it "should return correct error message to inform the incorrect param" do
        invalid_input = input.merge(articles: [*input[:articles], { "id": 5, "name": "coffee", "price": "300" }])
        post :checkout, params: { articles: invalid_input[:articles], carts: invalid_input[:carts] }, as: :json
        expect(JSON.parse(response.body).deep_symbolize_keys).to eq({
          error: "The property '#/articles/4/price' of type string did not match the following type: integer"
        })
      end

      it "should return correct error message if any of carts or articles are missing from the params" do
        post :checkout, params: { articles: input[:articles] }, as: :json
        expect(JSON.parse(response.body).deep_symbolize_keys).to eq({
          error: "The property '#/' did not contain a required property of 'carts'"
        })
      end
    end
  end
end
