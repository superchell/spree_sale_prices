module Spree
  class Calculator::PercentOffSalePriceCalculator < Spree::Calculator
    # TODO validate that the sale price is between 0 and 1
    def self.description
      Spree.t('sale_prices.calculators.percentage.description')
    end

    def compute(sale_price)
      (1.0 - sale_price.value.to_f) * sale_price.variant.original_price.to_f
    end
  end
end