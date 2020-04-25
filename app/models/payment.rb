class Payment < ApplicationRecord
  STATUSES = %w(accepted pending cancelled)
  ACCEPTED_STATUS = 'accepted'
  PENDING_STATUS = 'pending'
  CANCELLED_STATUS = 'cancelled'

  validates :buyer, :status, :amount, presence: true
  validates :amount, numericality: true

  belongs_to :order, inverse_of: :payments

  before_validation :set_status, on: :create

  def cancel
    # TODO call provider api to cancel payments
    self.update!(status: CANCELLED_STATUS)
  end
  
  private 

  def set_status
    self.status = PENDING_STATUS
  end
end
