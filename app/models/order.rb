class Order < ApplicationRecord
  STATUSES = %w(ordered cancelled reserved shipped)

  validates :status, :amount, presence: true
  validates :amount, numericality: true

  has_secure_token :token

  has_many :products_orders, class_name: 'ProductOrder', inverse_of: :order
  has_many :products, through: :products_orders, inverse_of: :orders
end
