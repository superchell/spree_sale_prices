module Spree
  class Calculator::FixedAmountSalePriceCalculator < Spree::Calculator
    # TODO validate that the sale price is less than the original price
    def self.description
      Spree.t('sale_prices.calculators.fix_amount.description')
    end


    def compute(sale_price)
      sale_price.value
    end
  end
end
