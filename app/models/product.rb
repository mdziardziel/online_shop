class Product < ApplicationRecord
  include Discard::Model

  DEFAULT_PICTURE = 'https://upload.wikimedia.org/wikipedia/en/0/00/The_Child_aka_Baby_Yoda_%28Star_Wars%29.jpg'
  PICTURE_SIZE = '250x250'

  validate :name, :description, :quantity, :price, presence: true
  validate :quantity, numericality: true
  validate :price, numericality: { only_integer: true }

  def picture_url
    picture || DEFAULT_PICTURE
  end
end
