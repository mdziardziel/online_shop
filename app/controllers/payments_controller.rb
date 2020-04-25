class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show]

  def new
    @order = Order.find_by(token: params[:order_token])
    @payment = Payment.new
  end

  def create
    order = Order.find_by(token: params[:payment][:order_token])
    payment = Payment.new(buyer: payment_params[:buyer], order: order, amount: order.amount)

    if payment.save
      process_payment
      redirect_to order_path(id: order.token)
    else
      flash[:error] = order.errors.full_messages
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(buyer: %i(first_name last_name phone_number email))
    end

    def process_payment

    end
end
