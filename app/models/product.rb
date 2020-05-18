  ##
# product model
class Product < ApplicationRecord
  include ::Discard::Model

  # obrazek awaryjny wyświetlany gdy produkt nie ma obrazka
  DEFAULT_PICTURE = 'https://upload.wikimedia.org/wikipedia/en/0/00/The_Child_aka_Baby_Yoda_%28Star_Wars%29.jpg'
  # rozmiar obrazka
  PICTURE_SIZE = '250x250'

  validates :name, :description, :quantity, :price, :category, presence: true
  validates :price, numericality: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :products_orders, class_name: 'ProductOrder', inverse_of: :product
  has_many :orders, through: :products_orders, inverse_of: :products

  # zwraca oryginalny obrazek lub awaryjny
  def picture_url
    picture || DEFAULT_PICTURE
  end
end
