module Payu
    ##
  # Requests +Payu+ for a new order
  #
  # You can find more informations about +Payu+ API here http://developers.payu.com/pl/restapi.html
  #
  # Compatible +Payu+ API version: *2.1*
  class Payment
    require 'net/http'
    require 'uri'
    require 'json'
    
    # Payu  OrderCreateRequest endpoint (sandbox)
    PAYU_URI = 'https://secure.snd.payu.com/api/v2_1/orders'.freeze
    CONTENT_TYPE_HEADER = 'application/json'.freeze
    # application endpoint which will be notified by Payu about order status change
    NOTIFY_PATH = "/payments/provider_notify".freeze
    # orders path
    ORDERS_PATH = "/orders".freeze
    # shop description
    DESCRIPTION = 'Online shop'.freeze
    # currency used in transaction
    CURRENCY_CODE = 'PLN'.freeze
    # used in sandbox mode to disable invoices creation
    INVOICE_DISABLED = 'true'.freeze
    # order request protocol
    PROTOCOL = 'https'
    # user's language
    LANGUAGE = 'pl'
  
    attr_private :payment
  
    # initializes headers and body of request
    def initialize(payment)
      @payment = payment
  
      set_headers
      set_body
    end
  
    # decorated response
    def response
      @response ||= Response.new(Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end)
    end
  
    # order creation request
    def request
      @request ||= Net::HTTP::Post.new(uri)
    end
  
    private
    
    # sets headers required by OrderCreateRequest
    def set_headers
      request.content_type = CONTENT_TYPE_HEADER
      request['Authorization'] = "Bearer #{AuthorizationToken.call}"
    end
  
    # sets body required by OrderCreateRequest
    def set_body
      request.body = JSON.dump({
        'notifyUrl' => "#{ENV['URL']}#{NOTIFY_PATH}",
        'continueUrl' => "#{ENV['URL']}#{ORDERS_PATH}/#{payment.order.token}",
        'customerIp' => customer_ip,
        'merchantPosId' => ENV['CLIENT_ID'],
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
  
    # sets http protocol
    def req_options
      {
        use_ssl: uri.scheme == PROTOCOL
      }
    end
  
    # returns hash with products ordered by customer
    def products
      @payment.order.products_orders.map do |product_order|
        {
          'name' => product_order.product.name,
          'unitPrice' => (product_order.product.price * 100).to_i.to_s,
          'quantity' => product_order.quantity.to_s
        }
      end
    end
  
    # returns informations about customer
    def buyer
      @buyer ||= {
        "email" => payment.buyer['email'],
        "phone" => payment.buyer['phone_number'],
        "firstName" => payment.buyer['first_name'],
        "lastName" => payment.buyer['last_name'],
        "language" => LANGUAGE
      }
    end
  
    # converts amount to format accepted by payu
    def total_amount
      (payment.amount * 100).to_i
    end
  
    # creates uri object from string uri
    def uri
      @uri ||= URI.parse(PAYU_URI)
    end

    # returns customer ip, currently harcoded 
    def customer_ip
      # TODO return real customer's ip
      '127.0.0.1'
    end

          ##
    # fetches authorization token from +Payu+ 
    #
    # authorizes using CLIENT_ID and CLIENT_SECRET variables from env
    #
    # You can find more informations about +Payu+ authorization here http://developers.payu.com/pl/restapi.html#references_api_signature
    #
    # Compatible +Payu+ API version: *2.1*
    class AuthorizationToken
      # number of seconds margin for generating new authorization token
      OVERLAP_SECS = 10
      # authorization link
      PAYU_AUTH_URI = 'https://secure.snd.payu.com/pl/standard/user/oauth/authorize'.freeze

      # at first use creates new token
      #
      # creates new token when old one expires
      def self.call
        @@token ||= new
        @@token.call
      end

      # set request body and generates new token
      def initialize
        request.set_form_data(
          "client_id" => ENV['CLIENT_ID'],
          "client_secret" => ENV['CLIENT_SECRET'],
          "grant_type" => "client_credentials",
        )

        refresh_token!
      end

      # generates new token if old one expires
      def call
        refresh_token! if token_outdated?
        @token
      end

      private

      # checks if authorization token expired
      def token_outdated?
        Time.now >= @created_at + @expires_in - OVERLAP_SECS
      end

      # fetches new fresh authorization token
      def refresh_token!
        @created_at = Time.now
        json_response = JSON.parse(response.body)
        @expires_in = json_response['expires_in'].to_i
        @token = json_response['access_token']
      end

      # creates uri object from string uri
      def uri
        @uri ||= URI.parse(PAYU_AUTH_URI)
      end

      # sets http protocol
      def request_options
        { use_ssl: uri.scheme == "https" }
      end

      # initializes request object
      def request
        @request ||= Net::HTTP::Post.new(uri)
      end

      # fetches response
      def response
        Net::HTTP.start(uri.hostname, uri.port, request_options) do |http|
          http.request(request)
        end
      end
    end
  
          ##
    # decorates payu order response
    class Response
      # success response status
      SUCCESS_STATUS = 'SUCCESS'.freeze
  
      pattr_initialize :response
  
      # json parsed body
      def body
        JSON.parse(response.body)
      end
  
      # url which will be used by user to pay for order
      def url
        body['redirectUri']
      end
    
      # response status
      def status
        body['status']
      end
    
      # new order id
      def order_id
        body['orderId']
      end
    
      def ext_order_id
        body['extOrderId']
      end
  
      # checks if response has success status
      def success?
        body['status']['statusCode'] == SUCCESS_STATUS
      end
    end
  end
end