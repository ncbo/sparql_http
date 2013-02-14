require 'net/http'

require_relative "xsd"

module SparqlRd
  module Utils
    module Http

      def self.request(host, port, req)
        return Net::HTTP.start(host, port) { |http| http.read_timeout= nil, http.request(req) }
      end

      def self.post(host, port, path, form_data)
        req = Net::HTTP::Post.new(path)
        req.set_form_data(form_data)
        self.request(host, port, req)
      end

      def self.camelize(str)
        #no idea why I can't use the string camelize
        str.split('_').map {|w| w.capitalize}.join
      end

      def self.valid_uri?(uri)
        begin
          parsed = URI.parse(uri)
          return (not parsed.scheme.nil?)
        rescue URI::InvalidURIError => e
          return false
        end
      end

      def self.sparql_http_loc(host, port)
        "http://#{host}:#{port}"
      end
      def self.sparql_query_http_loc(host,port)
        "%s/sparql/"%[sparql_http_loc(host,port)]
    end
    def self.sparql_update_http_loc(host,port)
      "%s/update/"%[sparql_http_loc(host,port)]
    end
    def self.sparql_data_http_loc(host,port)
      "%s/data/"%[sparql_http_loc(host,port)]
    end

    end
  end
end
