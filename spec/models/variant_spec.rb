require 'spec_helper'

describe Spree::Variant do

  it 'can put a variant on a standard sale' do
    variant = create(:variant)
    price = variant.price

    expect(variant.on_sale?).to be false

    variant.put_on_sale 10.95

    expect(variant.on_sale?).to be true
    expect(variant.original_price).to eql price
    expect(variant.price).to eql 10.95
  end

  it 'changes the price of all attached prices' do
    variant = create(:multi_price_variant)
    variant.put_on_sale 10.95

    expect(variant.prices.count).not_to eql 0
    variant.prices.each do |price|
      expect(price.price).to eql 10.95
    end
  end

  it 'changes the price for each specific currency' do
    variant = create(:multi_price_variant, prices_count: 5)

    variant.prices.each do |price|
      variant.put_on_sale 10.95, { currencies: [ price.currency ] }

      expect(variant.price_in(price.currency).price).to eq 10.95
      expect(variant.original_price_in(price.currency).price).to eql 19.99
    end
  end

  it 'changes the price for multiple currencies' do
    variant = create(:multi_price_variant, prices_count: 5)
    some_prices = variant.prices.sample(3)

    variant.put_on_sale(10.95, {
      currencies: some_prices.map(&:currency)
      # TODO: does not work yet, because sale_prices take the calculator instance away from each other
      #calculator_type: Spree::Calculator::PercentOffSalePriceCalculator.new
    })

    some_prices.each do |price|
      expect(variant.price_in(price.currency).price).to be_within(0.01).of(10.95)
      expect(variant.original_price_in(price.currency).price).to eql 19.99
    end
  end

  it 'can set the original price to something different without changing the sale price' do
    variant = create(:multi_price_variant, prices_count: 5)
    variant.put_on_sale(10.95)
    variant.prices.each do |price|
      price.original_price = 12.90
    end

    variant.prices.each do |price|
      expect(price.on_sale?).to be true
      expect(price.price).to eq 10.95
      expect(price.sale_price).to eq 10.95
      expect(price.original_price).to eq 12.90
    end
  end

  it 'is not on sale anymore if the original price is lower than the sale price' do
    variant = create(:multi_price_variant, prices_count: 5)
    variant.put_on_sale(10.95)
    variant.prices.each do |price|
      price.original_price = 9.90
    end

    variant.prices.each do |price|
      expect(price.on_sale?).to be false
      expect(price.price).to eq 9.90
      expect(price.sale_price).to eq false
      expect(price.original_price).to eq 9.90
    end
  end

  context 'with a valid sale' do

    before(:each) do
      @variant = create(:multi_price_variant, prices_count: 5)
      @variant.put_on_sale(10.95) # sale is started and enabled at this point for all currencies
    end

    it 'can stop and start a sale for all currencies' do
      @variant.stop_sale
      @variant.prices.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be false
      end

      @variant.start_sale
      @variant.prices.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be true
      end
    end

    it 'can disable and enable a sale for all currencies' do
      @variant.disable_sale
      @variant.prices.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be false
      end

      @variant.enable_sale
      @variant.prices.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be true
      end
    end

    it 'can stop and start a sale for specific currencies' do
      price_groups = @variant.prices.in_groups(2)
      @variant.stop_sale(price_groups.first.map(&:currency))

      price_groups.first.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be false
      end

      price_groups.second.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be true
      end

      @variant.start_sale(1.day.ago, price_groups.first.map(&:currency))
      @variant.prices.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be true
      end
    end

    it 'can disable and enable a sale for specific currencies' do
      price_groups = @variant.prices.in_groups(2)
      @variant.disable_sale(price_groups.first.map(&:currency))

      price_groups.first.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be false
      end

      price_groups.second.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be true
      end

      @variant.enable_sale(price_groups.first.map(&:currency))
      @variant.prices.each do |price|
        expect(@variant.on_sale_in?(price.currency)).to be true
      end
    end

  end

end
