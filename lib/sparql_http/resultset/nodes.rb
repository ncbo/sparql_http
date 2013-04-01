require_relative "../utils/xsd"

module SparqlRd
  module Resultset

    class Node
      include Comparable
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
        return false if other.nil?
        if !other.kind_of? Node
          return self.value == other
        end
        if other.type == @type
          return other.value == @value
        end
        false
      end
      def ==(other)
        return self.eql? other
      end
      def <=>(other)
        if self.value < other.value
          -1
        elsif self.value > other.value
          1
        else
          0
        end
      end
      def to_s
        return value.to_s
      end
      def inspect
        ["'",value,"':",self.class.to_s].join
      end
    end

    class BNode < Node
      def initialize(value)
        super(value,:bnode)
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
      def inspect
        ["'",@value,"':",self.class.to_s].join
      end
      def to_turtle
        "<#{@value}>"
      end
    end

    class Literal < Node
      attr_accessor :datatype
      attr_accessor :lang
      attr_accessor :parsed_value

      def initialize(value,parsed_value,datatype,lang)
        super(value, :literal)
        @value = value
        @datatype = datatype
        @lang = lang #lang not handled now.
        @parsed_value = parsed_value
      end

      def inspect
        v = @parsed_value
        ["'",v.to_s,"':",v.class.to_s].join
      end

      def eql?(other)
        return false if other.nil?
        if !other.kind_of? Literal
          return @parsed_value == other
        end
        if other.type == @type
          return (other.value == @value and
          other.datatype == @datatype and
          other.lang == @lang)
        end
        false
      end
      def ==(other)
        return self.eql? other
      end

      def hash
        return "#{@value}#{@datatype}#{@lang}".hash
      end

      def to_turtle
        return "\"\"\"#{@value}\"\"\"#{@lang}" if !@lang.nil?
        return "\"\"\"#{@value}\"\"\"^^<#{@datatype}>" if !@datatype.nil?
        return "\"\"\"#{@value}\"\"\""
      end
    end

    class IntegerLiteral < Literal
      def initialize(parsed_value)
        super(parsed_value.to_s,parsed_value,Utils::Xsd::XSD_TYPES[:integer],nil)
      end
      def <=>(other)
        other = other.parsed_value if other.instance_of? IntegerLiteral
        if self.parsed_value < other
          -1
        elsif self.parsed_value > other
          1
        else
          0
        end
      end
      def to_i
        return parsed_value
      end
      def -(other)
        other = other.parsed_value if other.instance_of? IntegerLiteral
        return IntegerLiteral.new (self.parsed_value - other)
      end
    end
    class DatetimeLiteral < Literal
      def initialize(value,parsed_value)
        super(value,parsed_value,Utils::Xsd::XSD_TYPES[:date_time],nil)
      end
      def <=>(other)
        other = other.parsed_value if other.instance_of? DatetimeLiteral
        if self.parsed_value < other
          -1
        elsif self.parsed_value > other
          1
        else
          0
        end
      end
    end
    class StringLiteral < Literal
      def initialize(value,lang=nil)
        super(value,value,Utils::Xsd::XSD_TYPES[:string],lang)
      end
      def <=>(other)
        other = other.parsed_value if other.instance_of? StringLiteral
        if self.parsed_value < other
          -1
        elsif self.parsed_value > other
          1
        else
          0
        end
      end
      def +(other)
        other = other.value if other.instance_of? StringLiteral
        return StringLiteral.new (self.value + other)
      end
      def =~(regex)
        return self.value =~ regex
      end
      def gsub(*arg,&block)
        return self.value.gsub(*arg,&block)
      end
      def encoding
        return self.value.encoding
      end
      def force_encoding(encoding)
        return self.value.force_encoding(encoding)
      end
    end
    class BooleanLiteral < Literal
      def initialize(value,parsed_value)
        super(value,parsed_value,Utils::Xsd::XSD_TYPES[:boolean],nil)
      end
      def !
        return !self.parsed_value
      end
      def &(other)
        other = other.value if other.instance_of? BooleanLiteral
        return self.parsed_value & other
      end
      def |(other)
        other = other.value if other.instance_of? BooleanLiteral
        return self.parsed_value | other
      end
      def ^(other)
        other = other.value if other.instance_of? BooleanLiteral
        return self.parsed_value ^ other
      end
      def eql?(other)
        other = other.value if other.instance_of? BooleanLiteral
        return self.parsed_value ^ other
      end
      def ==(other)
        other = other.value if other.instance_of? BooleanLiteral
        return self.parsed_value ^ other
      end
    end

    def self.get_literal_from_object(object_value,lang=nil)
      return object_value if object_value.kind_of? Node
      if (object_value.instance_of? String) or lang
        return StringLiteral.new(object_value, lang)
      end
      if object_value.instance_of? Fixnum
        return IntegerLiteral.new(object_value)
      end
      if object_value.instance_of? DateTime
        return DatetimeLiteral.new(object_value.xmlschema, object_value)
      end
      if (object_value.instance_of? TrueClass) or (object_value.instance_of? FalseClass)
        return BooleanLiteral.new(object_value.to_s, object_value)
      end
      raise ArgumentError,"Unknown datatype #{object_value.class}"
      #return Literal.new(object_value.to_s, object_value, nil, nil)
    end

    def self.get_literal_instance(value,datatype,lang)
      object_value = Utils::Xsd.parse_literal_value(value,datatype,lang)
      if object_value.instance_of? String
        return StringLiteral.new(value, lang)
      end
      if object_value.instance_of? Fixnum
        return IntegerLiteral.new(object_value)
      end
      if object_value.instance_of? DateTime
        return DatetimeLiteral.new(value, object_value)
      end
      if (object_value.instance_of? TrueClass) or (object_value.instance_of? FalseClass)
        return BooleanLiteral.new(value, object_value)
      end
      raise ArgumentError,"Unknown datatype #{datatype}"
      #return Literal.new(value, object_value, datatype, lang)
    end
  end
end
