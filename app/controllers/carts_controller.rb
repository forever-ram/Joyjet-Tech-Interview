class CartsController < ApplicationController
  # POST /carts/checkout
  def checkout
    begin
      JSON::Validator.validate!(request_schema, checkout_params.to_unsafe_h)
      render json: { carts: cart_service.call }, status: :ok
    rescue JSON::Schema::ValidationError, MissingDeliveryFeeRangeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      logger.error "An error occurred: #{e.message}"
      render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
    end
  end

  private
  def request_schema
    schema_path = Rails.root.join('app/schemas/checkout_request_schema.json')
    JSON.parse(File.read(schema_path))
  end

  def checkout_params
    params.permit(
      articles: [:id, :name, :price],
      carts: [:id, items: [:article_id, :quantity]],
      delivery_fees: [:price, eligible_transaction_volume: [:min_price, :max_price]]
    )
  end

  def cart_service
    @cart_service ||= CartService.new(
      checkout_params[:articles],
      checkout_params[:carts],
      checkout_params[:delivery_fees]
    )
  end
end
