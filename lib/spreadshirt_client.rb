
require "spreadshirt_client/version"
require "rubygems"
require "rest-client"
require "timeout"

module SpreadshirtClient
  class << self
    attr_accessor :api_key, :api_secret

    def timeout=(timeout)
      @timeout = timeout
    end

    def timeout
      @timeout || 30
    end

    def base_url=(base_url)
      @base_url = base_url
    end

    def base_url
      @base_url || "http://api.spreadshirt.net/api/v1"
    end

    def authorize(method, path, session = nil)
      time = Time.now.to_i

      authorization = [
        "apiKey=\"#{api_key}\"",
        "data=\"#{method} #{url_for path} #{time}\"",
        "sig=\"#{Digest::SHA1.hexdigest "#{method} #{url_for path} #{time} #{api_secret}"}\""
      ]

      res = []
      res.push "SprdAuth #{authorization.join ", "}"
      res.push "sessionId=\"#{session}\"" if session

      res.join ", "
    end

    def url_for(path)
      return path if path =~ /\Ahttps?:\/\//

      "#{base_url}#{path}"
    end

    def headers_for(method_symbol, path, options)
      headers = {}

      headers[:authorization] = authorize(method_for(method_symbol), path, options[:session]) if options[:authorization]

      opts = options.dup
      opts.delete :session
      opts.merge headers
    end

    def method_for(method_symbol)
      method_symbol.to_s.upcase
    end

    def put(path, payload, options = {})
      Timeout::timeout(timeout) { RestClient.put url_for(path), payload, headers_for(:put, path, options) }
    end

    def post(path, payload, options = {})
      Timeout::timeout(timeout) { RestClient.post url_for(path), payload, headers_for(:post, path, options) }
    end

    def get(path, options = {})
      Timeout::timeout(timeout) { RestClient.get url_for(path), headers_for(:get, path, options) }
    end

    def delete(path, options = {})
      Timeout::timeout(timeout) { RestClient.delete url_for(path), headers_for(:delete, path, options) }
    end
  end
end

