require_relative "../exceptions"
require_relative "nodes"

module SparqlRd
  module Resultset

    class Solution

      def initialize(data,vars)
        @data = data
        @vars = vars
      end

      def get_vars
        @data.keys
      end

      def create_binding_value(value,datatype,lang,type)
        if value.nil? #optional
          return nil
        end
        #WARN: this controls fake skolem URIs used in ncbo/goo
        if type == "bnode"
          return BNode.new(value)
        end

        case type
        when "uri"
          return IRI.new(value)
        when "literal"
          return Literal.new(value,datatype,lang)
        when "bnode"
          return BNode.new(value)
        else
          raise UnknownSolutionFieldType
        end
      end

      def get(var)
        raise SparqlVariableNotFoundError,
          "Variable '%s' not found in var list %s"%[var,@vars.to_s] \
            if @vars.index(var) == nil

        return nil if @data[var.to_s] == nil

        var_field = @data[var.to_s]
        type = var_field["type"]
        if type == "uri"
          value = var_field["value"]
          if value and value.index ".well-known/genid"
            type = "bnode"
          end
        end
        create_binding_value(var_field["value"],
                             var_field["datatype"],
                             var_field["lang"],
                             type)
      end

      def to_s
        output = []
        @vars.each do |var|
          output << '[' << self.get(var).to_s << "]\t"
        end
        output.join ' '
      end

    end

  end
end

