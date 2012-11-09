
module SparqlRd
  module Utils
    module String
      def self.camelize(str)
        #no idea why I can't use the string camelize 
        str.split('_').map {|w| w.capitalize}.join
      end
    end
  end
end
