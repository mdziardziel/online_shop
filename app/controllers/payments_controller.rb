class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show]

  def new
    @order = Order.find_by(token: params[:order_token])
    @payment = Payment.new
  end

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

  def cancel
    order = Order.find_by(token: params[:order_token])
    order.payments.each(&:cancel)
    
    redirect_back fallback_location: order_path(id: order.token)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(buyer: %i(first_name last_name phone_number email))
    end

    def payu_payment
      @payu_payment ||= PayuPayment.new(@payment)
    end

    def process_payment
      if payu_payment.response.success?
        @redirect_url = payu_payment.response.url
      else
        @payment.cancel
        @redirect_url = order_path(id: @order.token)
      end
    end
end
