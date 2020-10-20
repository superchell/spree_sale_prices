require 'memoist'

module Spree
  module PriceDecorator

    def self.prepended(base)
      base.extend Memoist
      base.has_many :sale_prices

      base.alias_method :current_sale, :active_sale
      base.alias_method :next_current_sale, :next_active_sale

      base.memoize :active_sale
      base.memoize :on_sale?
      base.memoize :price

      base.after_save :flush_class_cache
    end

    def put_on_sale(value, options = {})
      new_sale(value, options).save
    end
  
    def new_sale(value, options = {})
      sale_price_options = {
        value: value,
        start_at: options.fetch(:start_at, Time.zone.now),
        end_at: options.fetch(:end_at, nil),
        enabled: options.fetch(:enabled, true),
        calculator: options.fetch(:calculator_type, Spree::Calculator::FixedAmountSalePriceCalculator.new)
      }
      return sale_prices.new(sale_price_options)
    end
    
    # TODO make update_sale method
  
    def active_sale
      first_sale(sale_prices.active) if on_sale?
    end
  
    def next_active_sale
      first_sale(sale_prices) if sale_prices.present?
    end
  
    def sale_price
      on_sale? ? active_sale.calculated_price : false 
    end
    
    def sale_price=(value)
      if on_sale?
        active_sale.update_attribute(:value, value)
      else
        put_on_sale(value)
      end
    end
  
    def discount_percent
      return 0.0 unless original_price > 0
      return 0.0 unless on_sale?
      (1 - (sale_price / original_price)) * 100
    end
  
    def on_sale?
      active_sales = sale_prices.active
      active_sales.present? && first_sale(active_sales).value < original_price
    end
  
  
    def original_price
      self[:amount]
    end
    
    def original_price=(value)
      self[:amount] = Spree::LocalizedNumber.parse(value)
    end
    
    def price
      (on_sale?) ? sale_price : original_price
    end
  
    def price=(price)
      if on_sale?
        self.sale_price = price
      else
        self[:amount] = Spree::LocalizedNumber.parse(price)
      end
    end
  
    def amount
      price
    end
  
    def enable_sale
      next_active_sale.enable if next_active_sale.present?
    end
  
    def disable_sale
      active_sale.disable if active_sale.present?
    end
  
    def start_sale(end_time = nil)
      next_active_sale.start(end_time) if next_active_sale.present?
    end
  
    def stop_sale
      active_sale.stop if active_sale.present?
    end
  
    def destroy_sale
      active_sale.destroy if active_sale.present?
    end
  
    def flush_class_cache
       self.flush_cache
    end
    
    private
      def first_sale(scope)
        scope.order("created_at DESC").first # Memoize this
      end
  end
end

Spree::Price.prepend(Spree::PriceDecorator)