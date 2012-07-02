
#require "spreadshirt_client/version"
require "rest-client"

module SpreadshirtClient
  class << self
    attr_accessor :api_key, :api_secret

    def base_url=(base_url)
      @base_url
    end

    def base_url
      @base_url || "http://api.spreadshirt.net/api/v1"
    end

    def authorize(method, path)
      time = Time.now.to_i

      authorization = [
        "apiKey=\"#{api_key}\"",
        "data=\"#{method} #{url_for path} #{time}\"",
        "sig=\"#{Digest::SHA1.hexdigest "#{method} #{url_for path} #{time} #{api_secret}"}\""
      ]

      "SprdAuth #{authorization.join ", "}"
    end

    def url_for(path)
      "#{base_url}#{path}"
    end

    def headers_for(method_symbol, path, options)
      headers = {}

      headers[:authorization] = authorize(method_for(method_symbol), path) if options[:authorization]

      options.merge headers
    end

    def method_for(method_symbol)
      method_symbol.to_s.upcase
    end

    def put(path, payload, options = {})
      RestClient.put url_for(path), payload, headers_for(:put, path, options)
    end

    def post(path, payload, options = {})
      RestClient.post url_for(path), payload, headers_for(:post, path, options)
    end

    def get(path, options = {})
      RestClient.get url_for(path), headers_for(:get, path, options)
    end

    def delete(path, options = {})
      RestClient.delete url_for(path), headers_for(:delete, path, options)
    end
  end
end

