FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    picture { Faker::Avatar.image(size: Product::PICTURE_SIZE) }
    quantity { Faker::Number.positive.to_i }
    price { Faker::Commerce.price }
    category { Faker::Commerce.department }
  end
end