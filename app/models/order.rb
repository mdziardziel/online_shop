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

  # sprawdza status wszystkich płatności danego zamówienia i zwraca jeden wspólny status
  #
  # jeśli co najmniej jedna płatność jest zakończona, wtedy zwraca statuc completed
  #
  # jeśli żadna płatność nie jest zakończona i co najmniej jedna oczekująca, wtedy zwraca status pending
  #
  # jeśli żadna płatność nie jest zakończona lub oczekująca i co najmniej jedna jest anulowana, wtedy zwraca status cancelled
  #
  # jeśli żadna płatność nie jest zakończona lub oczekująca lub anulowana wtedy zwraca status not started
  def payment_status
    return Payment::COMPLETED_STATUS if Payment.find_by(order_id: id, status: Payment::COMPLETED_STATUS)
    return Payment::PENDING_STATUS if Payment.find_by(order_id: id, status: Payment::PENDING_STATUS)
    return Payment::CANCELLED_STATUS if Payment.find_by(order_id: id, status: Payment::CANCELLED_STATUS)

    'not started'
  end

  private

  # po stworzeniu zamówienia ustala status jako reserved
  #
  # oznacza, że klient zamówił produkty, ale jeszcze nie dokonał płatności
  def set_status
    self.status = RESERVED_STATUS
  end

  # generuje nowy unikalny token który będzie jednoznacznie identyfikował zamówienie
  def set_token
    random_token = SecureRandom.alphanumeric(32)
    while Order.find_by(token: random_token).present? do
      random_token = SecureRandom.alphanumeric(32)
    end
    self.token = random_token
  end
end
