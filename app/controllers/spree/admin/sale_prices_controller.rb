module Spree
  module Admin
    class SalePricesController < BaseController

      before_filter :load_product

      respond_to :js, :html

      def index
        @sale_prices = @product.sale_prices
      end

      def create
        @sale_price = @product.put_on_sale params[:sale_price][:value], sale_price_params
        respond_with(@sale_price)
      end

      def destroy
        @sale_price = Spree::SalePrice.find(params[:id])

        # Destroy all sale prices by finding via attributes
        Spree::Product.find_by_id(@sale_price.variant.product.id).sale_prices.where({
          value: @sale_price.value,
          start_at: @sale_price.start_at,
          end_at: @sale_price.end_at,
          enabled: @sale_price.enabled,
        }).destroy_all
        #@sale_price.destroy

        respond_with(@sale_price)
      end

      private

      def load_product
        @product = Spree::Product.find_by(slug: params[:product_id])
        redirect_to request.referer unless @product.present?
      end

      def sale_price_params
        params.require(:sale_price).permit(
            :id,
            :value,
            :currency,
            :start_at,
            :end_at,
            :enabled
        )
      end
    end
  end
end
