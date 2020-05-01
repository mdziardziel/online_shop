  ##
# product model
class Product < ApplicationRecord
  include ::Discard::Model

  # fallback picture for product when no one is saved in database
  DEFAULT_PICTURE = 'https://upload.wikimedia.org/wikipedia/en/0/00/The_Child_aka_Baby_Yoda_%28Star_Wars%29.jpg'
  # picture size
  PICTURE_SIZE = '250x250'

  validates :name, :description, :quantity, :price, :category, presence: true
  validates :price, numericality: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :products_orders, class_name: 'ProductOrder', inverse_of: :product
  has_many :orders, through: :products_orders, inverse_of: :products

  # returns original picture url or fallfack when original doesn't exist
  def picture_url
    picture || DEFAULT_PICTURE
  end
end
