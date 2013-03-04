require 'net/http'

require_relative 'test_case'

class TestQuery < TestCase

  def setup
    SparqlRd::Repository.configuration(store)
    @epr = SparqlRd::Repository.endpoint(store[:name])
  end

  def count_test_graph
    q = <<eos
SELECT (count(?s) as ?c) WHERE {
  GRAPH <#{test_graph}> {
    ?s ?p ?o
  }
}
eos
    @epr.query(q).each_solution do |sol|
      return sol.get(:c).parsed_value
    end
    #unreachable
    assert_equal 1, 0
  end

  def test_assert_and_count
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0

    rdf_document = <<eos
<a> <b> <c> .
<c> <x> <d> .
eos

    @epr.append_in_graph(rdf_document, test_graph, SparqlRd::Utils::MimeType.turtle)
    assert_equal count_test_graph, 2
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0
  end

  def test_object_types
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0

    rdf_document = <<eos
<a> <iri> <c12345> .
<c12345> <bnode> [
  <integer> 97412;
  <datetime> "2012-10-04T07:00:00"^^<http://www.w3.org/2001/XMLSchema#dateTime>;
  <string> "hi"^^<http://www.w3.org/2001/XMLSchema#string>;
  <boolean> "true"^^<http://www.w3.org/2001/XMLSchema#boolean>;
  <double> "3.141592653"^^<http://www.w3.org/2001/XMLSchema#double>;
] .
eos
    @epr.append_in_graph(rdf_document, test_graph, SparqlRd::Utils::MimeType.turtle)

    rs = @epr.query("SELECT * WHERE { GRAPH <#{test_graph}> { ?s ?p ?o .} }")
    rs.each_solution do |sol|
      if sol.get(:p).value.end_with? "iri"
        assert_equal sol.get(:o).type, :iri
        assert_equal sol.get(:o).value, "" << test_graph << "c12345"
      elsif sol.get(:p).value.end_with? "bnode"
        assert_equal sol.get(:o).type, :bnode
      elsif sol.get(:p).value.end_with? "integer"
        assert_equal sol.get(:o).type, :literal
        assert_equal sol.get(:o).datatype, SparqlRd::Utils::Xsd.types[:integer]
        assert_equal sol.get(:o).value, "97412"
        assert_equal sol.get(:o).parsed_value, 97412
      elsif sol.get(:p).value.end_with? "datetime"
        assert_equal sol.get(:o).type, :literal
        assert_equal sol.get(:o).datatype, SparqlRd::Utils::Xsd.types[:date_time]
        assert_equal sol.get(:o).value, "2012-10-04T07:00:00"
        assert_equal sol.get(:o).parsed_value, DateTime.xmlschema("2012-10-04T07:00:00")
      elsif sol.get(:p).value.end_with? "string"
        assert_equal sol.get(:o).type, :literal
        assert_equal sol.get(:o).datatype, SparqlRd::Utils::Xsd.types[:string]
        assert_equal sol.get(:o).value, "hi"
      elsif sol.get(:p).value.end_with? "boolean"
        assert_equal sol.get(:o).type, :literal
        assert_equal sol.get(:o).datatype, SparqlRd::Utils::Xsd.types[:boolean]
        assert_equal sol.get(:o).value, "true"
        assert_equal sol.get(:o).parsed_value, true
      elsif sol.get(:p).value.end_with? "double"
        assert_equal sol.get(:o).type, :literal
        assert_equal sol.get(:o).datatype, SparqlRd::Utils::Xsd.types[:double]
        assert_equal sol.get(:o).value, "3.141592653"
        assert_equal sol.get(:o).parsed_value, 3.141592653
      else
        #unreachable
        assert_equal 1, 0
      end
    end
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0
  end

  def test_update
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0

    update = <<eos
    INSERT DATA {
GRAPH <#{test_graph}> {
 <https://github.com/ncbo/sparqlrd/subject> <https://github.com/ncbo/sparqlrd/has> "cccc";
                  <https://github.com/ncbo/sparqlrd/email> "bbbb";
                  <https://github.com/ncbo/sparqlrd/other> [
        <https://github.com/ncbo/sparqlrd/cccc1> <https://github.com/ncbo/sparqlrd/dddd1>;
        <https://github.com/ncbo/sparqlrd/cccc2> <https://github.com/ncbo/sparqlrd/dddd2>;
        <https://github.com/ncbo/sparqlrd/cccc3> <https://github.com/ncbo/sparqlrd/dddd3>;
                 ] . }
}
eos
    @epr.update(update)
    assert_equal count_test_graph, 6

    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0
  end

  def test_update_error
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0

    update = <<eos
    INSERT DATA {
GRAPH <#{test_graph}> {
 <https://github.com/ncbo/sparqlrd/subject> SOME INVALID DATA .
}
eos
    begin
      @epr.update(update)
      #unreachable
      assert_equal 1, 0
    rescue => e
      assert_instance_of Net::HTTPServerException, e
    end

    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0
  end

  def test_query_error

    query = <<eos
SELECT * WHERE { ?s ?p ?o .
eos
    begin
      @epr.update(query)
      #unreachable
      assert_equal 1, 0
    rescue => e
      assert_instance_of Net::HTTPServerException, e
    end

  end

  def test_assert_and_count
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0

    rdf_document = <<eos
<a> <b> <c> .
<c> <x> .
eos
    begin
      @epr.append_in_graph(rdf_document, test_graph, SparqlRd::Utils::MimeType.turtle)
    rescue => e
      assert_instance_of Net::HTTPServerException, e
    end
    @epr.delete_graph(test_graph)
    assert_equal count_test_graph, 0
  end
  def test_literal_cmp
    binding.pry
  end
 end
