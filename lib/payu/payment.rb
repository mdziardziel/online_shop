module Payu
  class Payment
    require 'net/http'
    require 'uri'
    require 'json'
    
    PAYU_URI = 'https://secure.snd.payu.com/api/v2_1/orders'.freeze
    CONTENT_TYPE_HEADER = 'application/json'.freeze
    NOTIFY_PATH = "/payments/provider_notify".freeze
    CUSTOMER_IP = '127.0.0.1'.freeze
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
      request['Authorization'] = "Bearer #{AuthorizationToken.call}"
    end
  
    def set_body
      request.body = JSON.dump({
        'notifyUrl' => "#{ENV['URL']}#{NOTIFY_PATH}",
        'customerIp' => CUSTOMER_IP,
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

    class AuthorizationToken
      OVERLAP_SECS = 10
      PAYU_AUTH_URI = 'https://secure.snd.payu.com/pl/standard/user/oauth/authorize'.freeze

      def self.call
        @@token ||= new
        @@token.call
      end

      def initialize
        request.set_form_data(
          "client_id" => ENV['CLIENT_ID'],
          "client_secret" => ENV['CLIENT_SECRET'],
          "grant_type" => "client_credentials",
        )

        refresh_token!
      end

      def call
        refresh_token! if token_outdated?
        @token
      end

      private

      def token_outdated?
        Time.now >= @created_at + @expires_in - OVERLAP_SECS
      end

      def refresh_token!
        @created_at = Time.now
        json_response = JSON.parse(response.body)
        @expires_in = json_response['expires_in'].to_i
        @token = json_response['access_token']
      end

      def uri
        @uri ||= URI.parse(PAYU_AUTH_URI)
      end

      def request_options
        { use_ssl: uri.scheme == "https" }
      end

      def request
        @request ||= Net::HTTP::Post.new(uri)
      end

      def response
        Net::HTTP.start(uri.hostname, uri.port, request_options) do |http|
          http.request(request)
        end
      end
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