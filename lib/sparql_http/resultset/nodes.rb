require_relative "../utils/xsd"

module SparqlRd
  module Resultset

    class Node
      attr_accessor :value
      attr_reader :type

      def initialize(value,type)
        self.value= value.to_s
        @type = type
      end
      def iri?
        @type == :iri
      end
      def bnode?
        @type == :bnode
      end
      def literal?
        @type == :literal
      end
      alias == eql?
      def hash
        return self.value.hash
      end
      def eql?(other)
        if other.type == @type
          return other.value == @value
        end
        false
      end
      def ==(other)
        return self.eql? other
      end
    end

    class BNode < Node
      def initialize(value)
        super(value,:bnode)
      end
      def to_s
        ["'",value,"':",self.class.to_s].join
      end
      def to_turtle
        #TODO: this test is not safe
        if @value.start_with? "http"
          "<#{@value}>"
        else
          "_:bNode#{@value}"
        end
      end
      def skolem?
        return ((not self.value.nil?) and self.value.include? ".well-known/genid")
      end
    end

    class IRI < Node
      def initialize(value)
        super(value,:iri)
      end
      def to_s
        ["'",@value,"':",self.class.to_s].join
      end
      def to_turtle
        "<#{@value}>"
      end
    end

    class Literal < Node
      attr_accessor :datatype
      attr_accessor :lang

      def initialize(value,datatype,lang)
        super(value, :literal)
        @value = value
        @datatype = datatype
        @lang = lang #lang not handled now.
        @parsed_value = nil #on demand
      end

      def parsed_value
        return @object_value if @object_value
        @object_value = Utils::Xsd.parse_literal_value(@value,@datatype,@lang)
      end

      def to_s
        v = parsed_value
        ["'",v.to_s,"':",v.class.to_s].join
      end

      def eql?(other)
        if other.type == @type
          return (other.value == @value and
          other.datatype == @datatype and
          other.lang == @lang)
        end
        false
      end

      def hash
        return "#{@value}#{@datatype}#{@lang}".hash
      end
    end

  end
end
