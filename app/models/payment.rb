class Payment < ApplicationRecord
  STATUSES = %w(accepted pending cancelled)
  ACCEPTED_STATUS = 'accepted'
  ACCEPTED_STATUS = 'pending'

  validates :buyer, :status, :amount, presence: true
  validates :amount, numericality: true

  belongs_to :order, inverse_of: :payments

  before_validation :set_status, on: :create

  private 

  def set_status
    self.status = PENDING_STATUS
  end
end
