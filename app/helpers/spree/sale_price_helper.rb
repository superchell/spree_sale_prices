module Spree
  module SalePriceHelper

    def content_discount_price(product_or_variant, options={})
      return  if !product_or_variant.on_sale?

      default_opts = {prepend: '', append: ''}

      content_tag :div, class: 'content-discount-price' do
        
        # default_discount_opts = {prepend: Spree.t('sale_prices.discount.saved'), append:  Spree.t('sale_prices.discount.off') }
        default_discount_opts = { prepend: '', append:  Spree.t('sale_prices.discount.off') }
        discount_opts = options[:discount] ? default_discount_opts.merge(options[:discount]) : default_discount_opts

        original_opts = options[:original_price] ? default_opts.merge(options[:original_price]) : default_opts

        original_price = content_tag :span, class: 'sp-original-price' do
          Spree.t("sale_prices.dislay.original", original_opts.merge(price: display_original_price(product_or_variant)))
        end

        discount = content_tag :span, class: 'sp-discount' do
          Spree.t("sale_prices.dislay.discount", discount_opts.merge(discount: display_discount_percent(product_or_variant)))
        end

        sep_char = options[:sep_char] || '•'

        concat original_price
        concat content_tag(:span, sep_char, class: 'sp-separator')
        concat discount
      end
    end

    # c: current price ( sale price)
    # o: original price
    # d: discount
    # s: separator
    def content_sale_price(product_or_variant, options={})
      default_opts = {prepend: '', append: ''}
      on_sale_opts = options[:on_sale] ? default_opts.merge(options[:on_sale]) : default_opts

      if product_or_variant.on_sale?
        # default_discount_opts = {prepend: Spree.t('sale_prices.discount.saved'), append:  Spree.t('sale_prices.discount.off') }
        default_discount_opts = { prepend: '', append:  Spree.t('sale_prices.discount.off') }
        discount_opts = options[:discount] ? default_discount_opts.merge(options[:discount]) : default_discount_opts

        original_opts = options[:original_price] ? default_opts.merge(options[:original_price]) : default_opts

        content_tag :div, class: 'content-sale-price' do

          on_sale_price  = content_tag :div, class: 'sp-sale-price' do
            Spree.t("sale_prices.dislay.on_sale", on_sale_opts.merge(price: display_price(product_or_variant)))
          end

          original_price = content_tag :span, class: 'sp-original-price' do
            Spree.t("sale_prices.dislay.original", original_opts.merge(price: display_original_price(product_or_variant)))
          end

          discount = content_tag :span, class: 'sp-discount' do
            Spree.t("sale_prices.dislay.discount", discount_opts.merge(discount: display_discount_percent(product_or_variant)))
          end

          sep_char = options[:sep_char] || '•'
          separator = content_tag :span, sep_char, class: 'sp-separator'

          result = ActiveSupport::HashWithIndifferentAccess.new c: on_sale_price, o: original_price, d: discount, s: separator

          format = options[:format] || 'cods'
          format.each_char.each do |chr|
            concat result[chr]
          end
        end
      else
        content_tag :div, class: 'sp-price' do
          Spree.t("sale_prices.dislay.on_sale", on_sale_opts.merge(price: display_price(product_or_variant)))
        end
      end
    end

    def safe_display_date_format(date, format=nil)
      format = default_date_format if format.blank?
      
      date.strftime(format) if date.present?
    end

    def default_date_format
      @default_date_format ||= ENV['DEFAULT_DATE_FORMAT'] || '%d/%m/%Y'
      @default_date_format
    end

    def display_original_price(product_or_variant)
      product_or_variant.original_price_in(_current_currency).display_price.to_html
    end
    

    # remove append_text. Use translation instead
    def display_discount_percent(product_or_variant)
      discount = product_or_variant.discount_percent_in(_current_currency)
      
      if discount > 0
        return number_to_percentage(discount, precision: 0).to_html
      else
        return ''
      end 
    end
  
    # Check if a sale is the current sale for a product, returns true or false
    def active_for_sale_price product, sale_price
      product.current_sale_in(_current_currency) == sale_price
    end
  
    def supported_currencies_for_sale_price
      try(:supported_currencies) || [ _current_currency ]
    end
  
    private
      def _current_currency
        try(:current_currency) || Spree::Config[:currency] || 'USD'
      end
  end
end