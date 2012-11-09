module SparqlRd
  class Repository

    @@instances = {}
    @@alias = {}
    @@lock = Mutex.new
    
    @@default_factory_settings = {
      :output => :json,
      :resultset_class => :json_iterable_resultset,
      :profile => true
    }

    def self.configuration(*args)
      if args.length == 1 and args[0].kind_of? Hash
        params = args[0]
        options = params[:options]
        port = params[:port]
        host = params[:host]
        name = params[:name]
      elsif args.length == 4
        options = args.pop
        port = args.pop
        host = args.pop
        name = args.pop
      else
        raise ArgumentError, "Inconsistent input parameters"
      end

      @@lock.synchronize do
        instance_key = "#{host}:#{port}"
        if @@instances.has_key?(instance_key)
          if @@alias.has_key?(name)
            raise ArgumentError, "Error setting up endpoint. Name exists for a different configuration" \
              if @@alias[name] != instance_key
          else
            @@alias[name]=instance_key
          end
          return @@instances[instance_key]
        end

        merged_options_factory = @@default_factory_settings.merge(options)
        @@instances[instance_key]=Store::HttpStore::Client.new(host,port,merged_options_factory)
        @@alias[name]=instance_key
      end
    end
    
    def self.endpoint(name)
      return @@instances[@@alias[name]]
    end

    def self.get_endpoint_instances
      @@instances
    end
  end

end
