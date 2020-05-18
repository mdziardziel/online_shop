module Payu
    ##
  # payu payment statuses
  class PaymentStatus
    PENDING = 'PENDING'
    WAITING_FOR_CONFIRMATION = 'WAITING_FOR_CONFIRMATION'
    COMPLETED = 'COMPLETED'
    CANCELED = 'CANCELED'
    STATUSES = [PENDING, WAITING_FOR_CONFIRMATION, COMPLETED, CANCELED]

    # zmapowane statusy płatności Payu na statusy użyte w aplikacji
    STATUS_MAP = {
      PENDING => Payment::PENDING_STATUS,
      WAITING_FOR_CONFIRMATION => Payment::WAITING_STATUS,
      COMPLETED => Payment::COMPLETED_STATUS,
      CANCELED => Payment::CANCELLED_STATUS
    }

    # konwertuje zmapowane statusy płatności Payu na statusy użyte w aplikacji
    def self.convert(status)
      STATUS_MAP[status]
    end
  end
end