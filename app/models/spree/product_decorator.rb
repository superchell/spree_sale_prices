
module Spree
  module ProductDecorator

    def self.prepended(base)
      base.has_many :sale_prices, through: :prices
      
      base.delegate :active_sale_in, :current_sale_in, :next_active_sale_in, 
                    :next_current_sale_in, :sale_price_in, :on_sale_in?, 
                    :original_price_in, :discount_percent_in, :discount_percent,
                    :sale_price, :original_price, :on_sale?, to: :master

      base.alias_method :create_sale, :put_on_sale
    end


    def put_on_sale(value, options = {})
      all_variants = options[:all_variants] || true
      run_on_variants(all_variants) { |v| v.put_on_sale(value, options) }
      self.touch
    end
  
    def enable_sale(all_variants = true)
      run_on_variants(all_variants) { |v| v.enable_sale }
      self.touch
    end
  
    def disable_sale(all_variants = true)
      run_on_variants(all_variants) { |v| v.disable_sale }
      self.touch
    end
  
    def start_sale(end_time = nil, all_variants = true)
      run_on_variants(all_variants) { |v| v.start_sale(end_time) }
      self.touch
    end
  
    def stop_sale(all_variants = true)
      run_on_variants(all_variants) { |v| v.stop_sale }
      self.touch
    end
  
    def destroy_sale(all_variants = true)
      run_on_variants(all_variants) { |v| v.destroy_sale }
      self.touch
    end
  
    private
      def run_on_variants(all_variants, &block)
        if all_variants && variants.present?
          variants.each { |v| block.call v }
        end
        block.call master
      end
  end
end

Spree::Product.prepend(Spree::ProductDecorator)