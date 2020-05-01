  ##
# order model
class Order < ApplicationRecord
  # order allowed statuses
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

  # checks status of payments associated and returns status
  #
  # if at least one payment has completed status, then returns completed
  #
  # if no one payment has completed and at least one has pending status, then returns pending
  #
  # if no one payment has completed or pending and at least one has cancelled status, then returns cancelled
  #
  # if no one payment has completed or pending or cancelled status, then returns  nt started status
  def payment_status
    return Payment::COMPLETED_STATUS if Payment.find_by(order_id: id, status: Payment::COMPLETED_STATUS)
    return Payment::PENDING_STATUS if Payment.find_by(order_id: id, status: Payment::PENDING_STATUS)
    return Payment::CANCELLED_STATUS if Payment.find_by(order_id: id, status: Payment::CANCELLED_STATUS)

    'not started'
  end

  private

  # set order status after database record creation as reserved
  #
  # means that user didn't pay for items, he just reseverd them
  def set_status
    self.status = RESERVED_STATUS
  end

  # generates new, uniq order token which will be used by user to find order
  def set_token
    random_token = SecureRandom.alphanumeric(32)
    while Order.find_by(token: random_token).present? do
      random_token = SecureRandom.alphanumeric(32)
    end
    self.token = random_token
  end
end
