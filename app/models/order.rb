class Order < ApplicationRecord
  STATUSES = %w(paid cancelled reserved shipped)
  PAID_STATUS = 'paid'
  RESERVED_STATUS = 'reserved'


  validates :amount, :status, :token, presence: true
  validates :amount, numericality: true

  has_many :products_orders, class_name: 'ProductOrder', inverse_of: :order
  has_many :products, through: :products_orders, inverse_of: :orders
  has_many :payments, inverse_of: :order

  accepts_nested_attributes_for :products_orders

  before_validation :set_status, :set_token, on: :create

  private

  def set_status
    self.status = RESERVED_STATUS
  end

  def set_token
    random_token = SecureRandom.alphanumeric(32)
    while Order.find_by(token: random_token).present? do
      random_token = SecureRandom.alphanumeric(32)
    end
    self.token = random_token
  end
end
