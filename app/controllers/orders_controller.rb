class OrdersController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products/1
  # GET /products/1.json
  def show
  end

  def create
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:products)
    end
end
