FactoryBot.define do
  factory :international_price, parent: :price do
    currency { FFaker::Currency.code }
  end
end