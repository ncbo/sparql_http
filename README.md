# SPARQL_HTTP

SPARQL_HTTP is a SPARQL HTTP Client for Ruby. It is developed together with the Goo library but it hash been designed as an standalone component that can be used separately.

## HOW-TO 

### Instatiate endpoint
    config = { :name => :local_repo , :host => "localhost", :port => 8080 , :options => { } }
    SparqlRd::Repository.configuration(store)
    epr = SparqlRd::Repository.endpoint(store[:local_repo])

### Assert Triples in a Graph
    rdf_document = <<eos
     <a> <b> <c> .
     <c> <x> <d> .
    eos
    test_graph = "https://github.com/ncbo/sparqlrd/"
    epr.append_in_graph(rdf_document, test_graph, SparqlRd::Utils::MimeType.turtle)

### Query Data
    rs = epr.query("SELECT * WHERE { GRAPH <#{test_graph}> { ?s ?p ?o .} }")
    rs.each_solution do |sol|
        s,p,o = sol.get(:s), sol.get(:p), sol.get(:o)
        puts "#{s.value} #{p.value} #{o.value}"
        if o.literal?
            #access to string value
            puts o.value
            #access to parsed value based on XSD types
            puts o.parsed_value
        end
    end

#### Update Data
    update = <<eos
    INSERT DATA { 
        GRAPH <https://github.com/ncbo/sparqlrd/> {
         <https://github.com/ncbo/sparqlrd/subject> <https://github.com/ncbo/sparqlrd/name> "msalvadores"; 
                      <https://github.com/ncbo/sparqlrd/worksAt> "Stanford" .
    }
    }
    eos
    epr.update(update)
