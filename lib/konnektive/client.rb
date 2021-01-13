class KonnektiveError < StandardError; end

module Konnektive
  class Client
    include HTTParty
    base_uri 'https://api.konnektive.com'
    # debug_output $stdout

    def initialize(login_id = nil, password = nil)
      @query = {
          loginId: login_id || ENV['KONNEKTIVE_LOGIN_ID'],
          password: password || ENV['KONNEKTIVE_PASSWORD']
      }

    end

    def request(path, query)
      response = self.class.get(path, {query: @query.merge(query), format: :json}).parsed_response
      raise KonnektiveError.new(response['message']) if 'ERROR' == response['result']
      response['message']
    end

    def order
      Subfolder.new('order', self)
    end

    def purchase
      Subfolder.new('purchase', self)
    end

    def customer
      Subfolder.new('customer', self)
    end

    def transactions
      Subfolder.new('transactions', self)
    end

    def reports
      Subfolder.new('reports', self)
    end


    class Subfolder

      def initialize(path, client)
        @path = path
        @client = client
      end

      def method_missing(method_sym, *arguments, &block)
        @client.request("/#{@path}/#{method_sym}/", arguments[0])
      end
    end
  end
end
