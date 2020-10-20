FactoryBot.define do
  factory :multi_price_variant, parent: :variant do
    transient do
      prices_count { 3 }
    end

    after(:create) do |variant, evaluator|
      create_list(:international_price, evaluator.prices_count, variant: variant)
    end
  end
end