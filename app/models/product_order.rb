class ProductOrder < ApplicationRecord
  self.table_name = 'products_orders'

  validates :amount, :quantity, presence: true
  validates :amount, numericality: true
  validates :quantity, numericality: { only_integer: true }

  belongs_to :product, inverse_of: :products_orders
  belongs_to :order, inverse_of: :products_orders
end
