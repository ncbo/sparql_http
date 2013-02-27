require 'date'

module SparqlRd
  module Utils
    module Xsd

    class UnsuportedXSDType < StandardError
    end

    def self.XSD_NS
      "http://www.w3.org/2001/XMLSchema#"
    end


    XSD_TYPES = {
      :integer => self.XSD_NS + "integer",
      :int => self.XSD_NS + "integer", #not int for SPARQL
      :double => self.XSD_NS + "double",
      :float => self.XSD_NS + "float",
      :string => self.XSD_NS + "string",
      :date => self.XSD_NS + "dateTime",
      :date_time => self.XSD_NS + "dateTime",
      :xml_literal => self.XSD_NS + "XMLLiteral",
      :boolean =>  self.XSD_NS + "boolean"
    }

    def self.xsd_type_from_value(value)
      if value.kind_of? "".class
        :string
      elsif value.kind_of? Fixnum
        :integer
      elsif value.kind_of? Date or value.kind_of? DateTime
        :date_time
      elsif value.kind_of? Float
        :float
      elsif !!value == value
        :boolean
      else
        nil
      end
    end


    def self.xsd_string_from_value(value, type)
      case type
      when :date, :date_time
        raise ArgumentError, "Value not DateTime object" unless value.kind_of? DateTime
        return value.xmlschema
      when :float, :double, :integer
        return value.to_s
      when :boolean
        return "true" && value || "false"
      else
        return value
      end
    end

    def self.parse_literal_value(value,datatype,lang)
      begin
        case datatype
        when XSD_TYPES[:string], nil, XSD_TYPES[:xml_literal]
          value
        when XSD_TYPES[:integer], XSD_TYPES[:int]
          value.to_i
        when XSD_TYPES[:date_time], XSD_TYPES[:date]
            DateTime.xmlschema(value)
          when XSD_TYPES[:boolean]
            value.eql?("true")
          when XSD_TYPES[:float]
            value.to_f
          when XSD_TYPES[:double]
            value.to_f
          else
            raise UnsuportedXSDType, "#{datatype}"
          end
        rescue ArgumentError => parse_error
          raise ArgumentError,
            "Parse error on '#{value} for datatype #{datatype} \
              message #{parse_error.message}'"
        end
      end

      def self.types
        XSD_TYPES
      end

    end
  end
end
