require 'test/unit'

require_relative "../lib/sparql_http.rb"


class TestCase < Test::Unit::TestCase
  def store
    { :name => :main , :host => "localhost", :port => 8080 , :options => { } }
  end
  def test_graph
    "https://github.com/ncbo/sparqlrd/"
  end
end
