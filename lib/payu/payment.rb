module Payu
    ##
  # wysyła zapytanie do +Payu+ o nowe zamówienie
  #
  # Więcej informacji o +Payu+ API można znaleźć tutaj http://developers.payu.com/pl/restapi.html
  #
  # Kompatybilna wersja +Payu+ API: *2.1*
  class Payment
    require 'net/http'
    require 'uri'
    require 'json'
    
    # Payu  OrderCreateRequest endpoint (sandbox)
    PAYU_URI = 'https://secure.snd.payu.com/api/v2_1/orders'.freeze
    CONTENT_TYPE_HEADER = 'application/json'.freeze
    # endpoint aplikacji który będzie informowany o zmianie statusu zamówienia
    NOTIFY_PATH = "/payments/provider_notify".freeze
    # ścieżka zamówienia
    ORDERS_PATH = "/orders".freeze
    # opis sklepu
    DESCRIPTION = 'Online shop'.freeze
    # waluta użyta w transakcji
    CURRENCY_CODE = 'PLN'.freeze
    # używane w sandboxie do wyłączenia faktur
    INVOICE_DISABLED = 'true'.freeze
    # protokół
    PROTOCOL = 'https'
    # język użytkownika
    LANGUAGE = 'pl'
  
    attr_private :payment
  
    # inicjalizuje ciało i nagłówki zapytania
    def initialize(payment)
      @payment = payment
  
      set_headers
      set_body
    end
  
    # dekoruje odpowiedź
    def response
      @response ||= Response.new(Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end)
    end
  
    # zapytanie o stworzenie zamówienia
    def request
      @request ||= Net::HTTP::Post.new(uri)
    end
  
    private
    
    # ustawia nagłówki wymagane przez OrderCreateRequest
    def set_headers
      request.content_type = CONTENT_TYPE_HEADER
      request['Authorization'] = "Bearer #{AuthorizationToken.call}"
    end
  
    # ustawia ciało wymagane przez OrderCreateRequest
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
  
    # ustawia protokół
    def req_options
      {
        use_ssl: uri.scheme == PROTOCOL
      }
    end
  
    # zwraca hash z zamówionymi produktami
    def products
      @payment.order.products_orders.map do |product_order|
        {
          'name' => product_order.product.name,
          'unitPrice' => (product_order.product.price * 100).to_i.to_s,
          'quantity' => product_order.quantity.to_s
        }
      end
    end
  
    # zwraca informacje o kliencie
    def buyer
      @buyer ||= {
        "email" => payment.buyer['email'],
        "phone" => payment.buyer['phone_number'],
        "firstName" => payment.buyer['first_name'],
        "lastName" => payment.buyer['last_name'],
        "language" => LANGUAGE
      }
    end
  
    # konwertuje cenę do formatu akceptowanego przez payu
    def total_amount
      (payment.amount * 100).to_i
    end
  
    # tworzy obiekt uri
    def uri
      @uri ||= URI.parse(PAYU_URI)
    end

    # zwraca ip klienta
    def customer_ip
      # TODO return real customer's ip
      '127.0.0.1'
    end

          ##
    # pobiera token autoryzacyjny z +Payu+ 
    #
    # autoryzuje przy użyciu CLIENT_ID i CLIENT_SECRET zapisanych w zmiennych środowiskowych
    #
    # Więcej informacji o autoryzacji +Payu+  http://developers.payu.com/pl/restapi.html#references_api_signature
    #
    # Kompatybilne z +Payu+ API w wersji: *2.1*
    class AuthorizationToken
      # liczba sekund, o ile wcześniej pobiermay token
      OVERLAP_SECS = 10
      # link do autoryzacji
      PAYU_AUTH_URI = 'https://secure.snd.payu.com/pl/standard/user/oauth/authorize'.freeze

      # przy pierwszym wywołaniu pobierany jest nowy token
      #
      # tworzy nowy token kiedy stary się przedawni
      def self.call
        @@token ||= new
        @@token.call
      end

      # ustawia ciało zapytania i generuje nowy token
      def initialize
        request.set_form_data(
          "client_id" => ENV['CLIENT_ID'],
          "client_secret" => ENV['CLIENT_SECRET'],
          "grant_type" => "client_credentials",
        )

        refresh_token!
      end

      # generuje nowy token jeśli stary się przedawni
      def call
        refresh_token! if token_outdated?
        @token
      end

      private

      # sprawdza czy token się przedawnił
      def token_outdated?
        Time.now >= @created_at + @expires_in - OVERLAP_SECS
      end

      # pobiera nowy token
      def refresh_token!
        @created_at = Time.now
        json_response = JSON.parse(response.body)
        @expires_in = json_response['expires_in'].to_i
        @token = json_response['access_token']
      end

      # tworzy obiekt uri
      def uri
        @uri ||= URI.parse(PAYU_AUTH_URI)
      end

      # ustawia protokół http
      def request_options
        { use_ssl: uri.scheme == "https" }
      end

      # inicjalizuje obiekt zapytania
      def request
        @request ||= Net::HTTP::Post.new(uri)
      end

      # fpobiera odpowiedź
      def response
        Net::HTTP.start(uri.hostname, uri.port, request_options) do |http|
          http.request(request)
        end
      end
    end
  
          ##
    # dekoruje odpowiedź na zapytanie o zamówienie z payu
    class Response
      # status sukces odpowiedzi
      SUCCESS_STATUS = 'SUCCESS'.freeze
  
      pattr_initialize :response
  
      # ciało w jsonie
      def body
        JSON.parse(response.body)
      end
  
      # url który będzie użyty przez klienta do opłacenia zamówienia
      def url
        body['redirectUri']
      end
    
      # status odpowiedzi
      def status
        body['status']
      end
    
      # id zamówienia
      def order_id
        body['orderId']
      end
    
      def ext_order_id
        body['extOrderId']
      end
  
      # sprawdza status odpoweidzi
      def success?
        body['status']['statusCode'] == SUCCESS_STATUS
      end
    end
  end
end