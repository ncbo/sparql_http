require_relative "../utils/http"
require_relative "../utils/string"

module SparqlRd
  module Store
    module HttpStore

      class Client

        attr_reader :host
        attr_reader :port
        attr_reader :default_params

        def initialize(host, port, params)
          raise ArgumentError, "Port must be an integer #{port}" \
            unless port.class == Fixnum

          http_loc = Utils::Http.sparql_http_loc(host,port)
          raise ArgumentError,
            "URI cannot be constructed. Parse error for '#{http_loc}'" \
              unless Utils::Http.valid_uri?(http_loc)

          raise ArgumentError,
              "Params must contain the :resultset_class element" \
                unless params[:resultset_class]

          @resultset_class = SparqlRd::Resultset.const_get(Utils::String.camelize(params[:resultset_class].to_s))

          @host = host
          @port = port
          @default_params = params.clone()

          @query_path = Utils::Http.sparql_query_http_loc(host,port)
          @data_path = Utils::Http.sparql_data_http_loc(host,port)
          @update_path = Utils::Http.sparql_update_http_loc(host,port)
        end

        def get_query_string(options)
          merged_options = @default_params.merge(options)
          #something to hook default options by configuration
          query_string = []
          merged_options.each_pair do |name,value|
            query_string << "#{name}=#{CGI.escape(value.to_s)}"
          end
          query_string = query_string.join '&'
        end

        def query(query, options = {})
          options["query"] = query
          query_string = get_query_string(options)
          #uri_query = "#{@query_path}?#{query_string}"
          get = Net::HTTP::Get.new("/sparql/?#{query_string}")
          response = Utils::Http.request(@host,@port,get)
          unless response.kind_of?(Net::HTTPSuccess)
            e = Net::HTTPServerException.new("#{response.code_type} #{response.code} #{response.message}", response.body)
            raise e
          end
          response = response.body
          @resultset_class.new(response,options)
        end

        def update(query, options = {})
          form = { "update" => query }
          res = Utils::Http.post(@host,@port,"/update/",form)
          unless res.kind_of?(Net::HTTPSuccess)
            #TODO: handle this exception without looking the code error.
            e = Net::HTTPServerException.new("#{res.code_type} #{res.code} #{res.message}", res.body)
            raise e
          end
        end

        def delete_graph(graph)
          res = Utils::Http.request(@host,@port,
                        Net::HTTP::Delete.new("/data/" + CGI.escape(graph)))
          unless res.kind_of?(Net::HTTPSuccess)
            #TODO: handle this exception without looking the code error.
            e = Net::HTTPServerException.new("#{res.code_type} #{res.code} #{res.message}", res.body)
            raise e
          end
        end

        def upload_file(file,graph,mime_type)
          #this for files
        end

        def append_in_graph(triples, graph, mime_type=nil)
          form = {}
          form["graph"] = graph
          form["data"] = triples
          if not mime_type.nil?
            form['mime-type'] = mime_type
          end
          res = Utils::Http.post(@host,@port,"/data/",form)
          unless res.kind_of?(Net::HTTPSuccess)
            #TODO: handle this exception without looking the code error.
            e = Net::HTTPServerException.new("#{res.code_type} #{res.code} #{res.message}", res.body)
            raise e
          end
        end
      end

    end
  end
end
