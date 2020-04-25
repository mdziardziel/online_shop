FactoryBot.define do
  factory :product_order do
    product
    order
    quantity { Faker::Number.positive.to_i }
    amount { Faker::Commerce.price }
  end
end