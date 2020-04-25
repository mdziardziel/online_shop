FactoryBot.define do
  factory :order do
    status { Order::STATUSES.sample }
    amount { Faker::Commerce.price }

    after(:create) do |order|
      create_list(:product_order, 3, order: order)
    end
  end
end