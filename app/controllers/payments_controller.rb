class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show]
  skip_before_action :verify_authenticity_token, only: %i(provider_notify)

  # GET payments?order_token=438778fafjdsfj484h83q 
  def new
    @order = Order.find_by(token: params[:order_token])
    @payment = Payment.new
  end

  # POST /payments
  #
  # creates new payment for order
  def create
    @order = Order.find_by(token: params[:payment][:order_token])
    @payment = Payment.new(buyer: payment_params[:buyer], order: @order, amount: @order.amount)

    if @payment.save
      process_payment
      redirect_to @redirect_url
    else
      flash[:error] = @order.errors.full_messages
    end
  end

  # POST /payments/cancel
  #
  # cancels payment, allows user to start new one
  def cancel
    order = Order.find_by(token: params[:order_token])
    order.payments.each(&:cancel)
    
    redirect_back fallback_location: order_path(id: order.token)
  end

  # POST /payments/provider_notify
  #
  # gets notifications from payment provider about payment status change
  #
  # returns 200 status
  def provider_notify
    # TODO check if request comes from payu by checking x-openpayu-signature header
    payu_status = params[:order][:status]
    order_id = params[:order]['orderId']
    status = ::Payu::PaymentStatus.convert(payu_status)
    payment = Payment.where("provider_data->>'order_id' = ?", order_id).first
    payment.update!(status: status)

    head :ok
  end

  private
    # sets payment by id
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # returns creation permitted params
    def payment_params
      params.require(:payment).permit(buyer: %i(first_name last_name phone_number email))
    end

    # created new payu payment instance
    def payu_payment
      @payu_payment ||= ::Payu::Payment.new(@payment)
    end

    # requests for payu order
    #
    # gets redirect url
    #
    # updates payment with data returned by request
    def process_payment
      if payu_payment.response.success?
        @redirect_url = payu_payment.response.url
        provider_data = { 
          'order_id' => payu_payment.response.order_id
         }
         @payment.update!(provider_data: provider_data)
      else
        @payment.cancel
        @redirect_url = order_path(id: @order.token)
      end
    end
end
