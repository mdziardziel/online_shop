module Payu
  class Payment
    require 'net/http'
    require 'uri'
    require 'json'
    
    PAYU_URI = 'https://secure.snd.payu.com/api/v2_1/orders'.freeze
    METHOD = 'post'.freeze
    AUTHORIZATION_HEADER = 'Bearer d9a4536e-62ba-4f60-8017-6053211d3f47'.freeze
    CONTENT_TYPE_HEADER = 'application/json'.freeze
    NOTIFY_URL = 'https://your.eshop.com/notify'.freeze
    CUSTOMER_IP = '127.0.0.1'.freeze
    MERCHANT_POST_ID = '300746'.freeze
    DESCRIPTION = 'Online shop'.freeze
    CURRENCY_CODE = 'PLN'.freeze
    INVOICE_DISABLED = 'true'.freeze
    PROTOCOL = 'https'
    LANGUAGE = 'pl'
  
    attr_private :payment
  
    def initialize(payment)
      @payment = payment
  
      set_headers
      set_body
    end
  
    def response
      @response ||= Response.new(Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end)
    end
  
    def request
      @request ||= Net::HTTP::Post.new(uri)
    end
  
    private
  
    def set_headers
      request.content_type = CONTENT_TYPE_HEADER
      request['Authorization'] = AUTHORIZATION_HEADER
    end
  
    def set_body
      request.body = JSON.dump({
        'notifyUrl' => NOTIFY_URL,
        'customerIp' => CUSTOMER_IP,
        'merchantPosId' => MERCHANT_POST_ID,
        'description' => DESCRIPTION,
        'currencyCode' => CURRENCY_CODE,
        'totalAmount' => total_amount.to_s,
        'buyer' => buyer,
        'settings' =>{
            'invoiceDisabled' => INVOICE_DISABLED
        },
        'products' => products
      })
    end
  
    def req_options
      {
        use_ssl: uri.scheme == PROTOCOL
      }
    end
  
    def products
      @payment.order.products_orders.map do |product_order|
        {
          'name' => product_order.product.name,
          'unitPrice' => (product_order.product.price * 100).to_i.to_s,
          'quantity' => product_order.quantity.to_s
        }
      end
    end
  
    def buyer
      @buyer ||= {
        "email" => payment.buyer['email'],
        "phone" => payment.buyer['phone_number'],
        "firstName" => payment.buyer['first_name'],
        "lastName" => payment.buyer['last_name'],
        "language" => LANGUAGE
      }
    end
  
    def total_amount
      (payment.amount * 100).to_i
    end
  
    def uri
      @uri ||= URI.parse(PAYU_URI)
    end
  
    class Response
      SUCCESS_STATUS = 'SUCCESS'.freeze
  
      pattr_initialize :response
  
      def body
        JSON.parse(response.body)
      end
  
      def url
        body['redirectUri']
      end
    
      def status
        body['status']
      end
    
      def order_id
        body['orderId']
      end
    
      def ext_order_id
        body['extOrderId']
      end
  
      def success?
        body['status']['statusCode'] == SUCCESS_STATUS
      end
    end
  end
end