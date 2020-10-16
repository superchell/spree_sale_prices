require 'spec_helper'

RSpec.describe Spree::SalePriceHelper, type: :helper do

  describe 'default_date_format' do
    it 'return the date format if it exists' do
      assign(:default_date_format,  '%Y-%m-%d')

      expect(helper.default_date_format).to eq '%Y-%m-%d'
    end

    it 'return date format from ENV["DEFAULT_DATE_FORMAT"] if DEFAULT_DATE_FORMAT present' do
      assign(:default_date_format, nil)
      ENV["DEFAULT_DATE_FORMAT"] = '%Y/%m/%d'

      expect(helper.default_date_format).to eq '%Y/%m/%d'
    end

    it 'return date format %d/%m/%Y if non is set' do
      assign(:default_date_format, nil)
      ENV["DEFAULT_DATE_FORMAT"] = nil

      expect(helper.default_date_format).to eq '%d/%m/%Y'
    end

  end

  describe '#safe_display_date_format' do
    it 'return formatted date in provided format' do
      date = Date.new(2020, 12, 31)
      format = '%Y-%m-%d'

      result = helper.safe_display_date_format(date, format)
      expect(result).to eq '2020-12-31'
    end

    it 'return date with default format if format is missing' do
      date = Date.new(2020, 12, 31)
      allow(helper).to receive(:default_date_format).and_return('%Y/%m/%d')
      

      result = helper.safe_display_date_format(date)
      expect(result).to eq '2020/12/31'
    end

    it 'return nil if date is blank' do
      date = nil
      result = helper.safe_display_date_format(date)
      expect(result).to eq nil

    end
  end

  describe '#supported_currencies_for_sale_price' do
    context '(chaining backwards compatibility)' do
      it 'can fallback to hardcoded standard currency' do
        expect(helper.supported_currencies_for_sale_price).to eq(['USD'])
      end

      it 'can fallback to config if present' do
        allow(Spree::Config).to receive(:[]).with(:currency).and_return('CHF')
        expect(helper.supported_currencies_for_sale_price).to eq(['CHF'])
      end

      it 'can fallback to current_currency if present (part of newer spree core)' do
        allow(helper).to receive(:current_currency).and_return('CHF')
        expect(helper.supported_currencies_for_sale_price).to eq(['CHF'])
      end

      it 'can use spree_multi_currency if present' do
        allow(helper).to receive(:supported_currencies).and_return(['CHF'])
        expect(helper.supported_currencies_for_sale_price).to eq(['CHF'])
      end
    end
  end
end
