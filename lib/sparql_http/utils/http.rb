require 'net/http'

require_relative "xsd"

module SparqlRd
  module Utils
    module Http

      def self.request(host, port, req)
        return Net::HTTP.start(host, port) do |http|
          http.read_timeout = 10800
          return http.request(req)
        end
      end

      def self.post(host, port, path, form_data)
        req = Net::HTTP::Post.new(path)
        req.set_form_data(form_data)
        self.request(host, port, req)
      end

      def self.put_file(host, port, path, file_path,mime_type=nil)
        header = { "Content-Length" => FileTest.size(file_path).to_s }
        header["Content-Type"] = mime_type unless mime_type.nil?
        req = Net::HTTP::Put.new(path, header)
        resp = nil
        begin
          f = File.open(file_path,"r")
          req.body_stream = f
          resp = self.request(host, port, req)
        rescue Exception => e
          f.close()
          raise e
        end
        f.close()
        return resp
      end

      def self.camelize(str)
        #no idea why I can't use the string camelize
        str.split('_').map {|w| w.capitalize}.join
      end

      def self.valid_uri?(uri)
        return (uri =~ URI::regexp) == 0
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
