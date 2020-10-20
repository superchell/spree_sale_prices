module Spree
  module VariantDecorator

    def self.prepended(base)
      base.has_many :sale_prices, through: :prices
      base.delegate :sale_price, :original_price, :on_sale?, :discount_percent, to: :default_price
      
      base.alias_method :create_sale, :put_on_sale
      base.alias_method :current_sale_in, :active_sale_in
      base.alias_method :next_current_sale_in, :next_active_sale_in
    end

    def put_on_sale(value, options = {})
      currencies = options.fetch(:currencies, [])
      if options[:currency].present?
        currencies << options[:currency] unless currencies.include? options[:currency]
      end
      
      run_on_prices(currencies) { |price| price.put_on_sale(value, options) }
      touch
    end
  
    # TODO make update_sale method
  
    def active_sale_in(currency)
      price_in(currency).active_sale
    end
   
  
    def next_active_sale_in(currency)
      price_in(currency).next_active_sale
    end
    
  
    def sale_price_in(currency)
      Spree::Price.new variant_id: self.id, currency: currency, amount: price_in(currency).sale_price
    end
    
    def discount_percent_in(currency)
      price_in(currency).discount_percent
    end
    
    def on_sale_in?(currency)
      price_in(currency).on_sale?
    end
  
    def original_price_in(currency)
      Spree::Price.new variant_id: self.id, currency: currency, amount: price_in(currency).original_price
    end
  
    def enable_sale(currencies = nil)
      run_on_prices(currencies) { |price| price.enable_sale }
    end
  
    def disable_sale(currencies = nil)
      run_on_prices(currencies) { |price| price.disable_sale }
    end
  
    def start_sale(end_time = nil, currencies = nil)
      run_on_prices(currencies) { |price| price.start_sale(end_time) }
    end
  
    def stop_sale(currencies = nil)
      run_on_prices(currencies) { |price| price.stop_sale }
    end
  
    def destroy_sale(currencies = nil)
      run_on_prices(currencies) { |price| price.destroy_sale }
    end
    
    private
    # runs on all prices or on the ones with the currencies you've specified
    def run_on_prices(currencies = nil, &block)
      if currencies.present? && currencies.any?
        prices_with_currencies = prices.select { |price| currencies.include?(price.currency) }
        prices_with_currencies.each { |price| block.call(price) }
      else
        prices.each { |price| block.call(price) }
      end
      touch
    end

  end
end

Spree::Variant.prepend(Spree::VariantDecorator)
