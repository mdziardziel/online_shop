  ##
# payment model
class Payment < ApplicationRecord
  COMPLETED_STATUS = 'completed'
  PENDING_STATUS = 'pending'
  CANCELLED_STATUS = 'cancelled'
  WAITING_STATUS = 'waiting_for_confirmation'
  REQUESTED_STATUS = 'requested'
  # payment allowed statuses
  STATUSES = [COMPLETED_STATUS, PENDING_STATUS, CANCELLED_STATUS, WAITING_STATUS, REQUESTED_STATUS]


  validates :buyer, :status, :amount, presence: true
  validates :amount, numericality: true

  belongs_to :order, inverse_of: :payments

  before_validation :set_status, on: :create
  after_update :update_order_status

  # cancels user payment
  #
  # unblocks user payment button and allows to pay second time
  def cancel
    # TODO call provider api to cancel payments
    self.update!(status: CANCELLED_STATUS)
  end
  
  private 

  # set order status after database record creation as reserved
  #
  # means that payment record has been createn, but payu payemnt didn't start yet
  def set_status
    self.status = REQUESTED_STATUS
  end

  # updates order status to paid when payment is completed
  def update_order_status
    return if previous_changes['status']&.second != COMPLETED_STATUS

    order.update!(status: Order::PAID_STATUS)
  end
end
