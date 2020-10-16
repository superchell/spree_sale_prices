module Spree
  class SalePrice < Spree::Base

    belongs_to :price, class_name: "Spree::Price"
    delegate :currency, to: :find_or_build_price

    has_one :variant, through: :price

    has_one :calculator, class_name: "Spree::Calculator", as: :calculable, dependent: :destroy
    validates :calculator, presence: true
    accepts_nested_attributes_for :calculator

    scope :active, -> do
      now = Time.zone.now
      where(enabled: true).where('(start_at <= ? OR start_at IS NULL) AND (end_at >= ? OR end_at IS NULL)', now, now)
    end

    after_destroy :touch_product

    # TODO make this work or remove it
    #def self.calculators
    #  Rails.application.config.spree.calculators.send(self.to_s.tableize.gsub('/', '_').sub('spree_', ''))
    #end
    def find_or_build_price
      price || build_price
    end

    def calculator_type
      calculator.class.to_s if calculator
    end

    def calculated_price
      calculator.compute self
    end

    def enable
      update_attribute(:enabled, true)
    end

    def disable
      update_attribute(:enabled, false)
    end

    def active?
      Spree::SalePrice.active.include? self
    end

    def start(end_time = nil)
      now = Time.zone.now

      end_time = nil if end_time.present? && end_time <= now # if end_time is not in the future then make it nil (no end)
      attr = { end_at: end_time, enabled: true }
      attr[:start_at] = now if self.start_at.present? && self.start_at > now # only set start_at if it's not set in the past
      update(attr)
    end

    def stop
      update(end_at: Time.zone.now, enabled: false)
    end

    # Convenience method for displaying the price of a given sale_price in the table
    def display_price
      Spree::Money.new(value || 0, { currency: price.currency })
    end

    protected
      def touch_product
        product = self.variant.product

        # Product
        product.prices.reset
        product.sale_prices.reset

        # Master
        product.master.prices.reset
        product.master.sale_prices.reset
        product.touch
      end

  end
end
