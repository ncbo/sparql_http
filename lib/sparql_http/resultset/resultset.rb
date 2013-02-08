require_relative "solution"

module SparqlRd
  module Resultset

    class JsonIterableResultset
      def initialize(response,options = {})
        @parsed_response = MultiJson.load(response)
        @solutions = @parsed_response["results"]["bindings"]
        @vars = @parsed_response["head"]["vars"]
        @vars = @vars.map { |v| v.to_sym }
      end

      def each_solution
        cursor = 0
        raise ArgumentError, "No block given" unless block_given?
        vars = nil
        while cursor < @solutions.length
          yield Solution.new(@solutions[cursor],@vars)
          cursor = cursor + 1
        end
      end
    end

    class XMLStreamParseIterableResultset
    end

  end
end
