Gem::Specification.new do |s|
  s.name = 'sparql_http'
  s.version = '0.0.1'
  s.date = '2012-11-09'
  s.summary = "SPARQL_HTTP is a SPARQL HTTP Client for Ruby. It is developed together with the Goo library but it hash been designed as an standalone component that can be used separately."
  s.authors = ["Manuel Salvadores", "Paul Alexander"]
  s.email = 'manuelso@stanford.edu'
  s.files = Dir['lib/**/*.rb'] + ["lib/sparql_http.rb"]
  s.homepage = 'http://github.com/ncbo/sparql_http'
  s.add_dependency("multi_json")
  s.add_dependency("rake")
  s.add_dependency("oj")
end
