class Product < ApplicationRecord
  include ::Discard::Model

  DEFAULT_PICTURE = 'https://upload.wikimedia.org/wikipedia/en/0/00/The_Child_aka_Baby_Yoda_%28Star_Wars%29.jpg'
  PICTURE_SIZE = '250x250'

  validates :name, :description, :quantity, :price, :category, presence: true
  validates :price, numericality: true
  validates :quantity, numericality: { only_integer: true }

  has_many :products_orders, class_name: 'ProductOrder', inverse_of: :product
  has_many :orders, through: :products_orders, inverse_of: :products

  def picture_url
    picture || DEFAULT_PICTURE
  end
end
