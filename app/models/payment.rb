  ##
# payment model
class Payment < ApplicationRecord
  COMPLETED_STATUS = 'completed'
  PENDING_STATUS = 'pending'
  CANCELLED_STATUS = 'cancelled'
  WAITING_STATUS = 'waiting_for_confirmation'
  REQUESTED_STATUS = 'requested'
  # statusy płatności
  STATUSES = [COMPLETED_STATUS, PENDING_STATUS, CANCELLED_STATUS, WAITING_STATUS, REQUESTED_STATUS]


  validates :buyer, :status, :amount, presence: true
  validates :amount, numericality: true

  belongs_to :order, inverse_of: :payments

  before_validation :set_status, on: :create
  after_update :update_order_status

  # anuluje płatność
  #
  # pozwala na ponowienie płatności
  def cancel
    # TODO call provider api to cancel payments
    self.update!(status: CANCELLED_STATUS)
  end
  
  private 

  # ustawia status płatności zaraz po stworzeniu rekordu
  #
  # oznacza, że płatność payu jeszcze się nie rozpoczęła
  def set_status
    self.status = REQUESTED_STATUS
  end

  # aktualizuje status zamównia jako paid gdy zamówienie zostanie opłacone
  def update_order_status
    return if previous_changes['status']&.second != COMPLETED_STATUS

    order.update!(status: Order::PAID_STATUS)
  end
end
