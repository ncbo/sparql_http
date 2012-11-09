require_relative 'test_case'

class TestRepository < TestCase

  def test_simple_create
    res = SparqlRd::Repository.configuration(store)
    
    #endpoint returns an instance of repository
    epr = SparqlRd::Repository.endpoint(store[:name])
    assert_instance_of SparqlRd::Store::HttpStore::Client, epr

    epr1 = SparqlRd::Repository.endpoint(store[:name])
    assert_equal epr, epr1
    assert_equal epr.host, epr1.host
    assert_equal epr.host, store[:host]
    assert_equal epr.port, store[:port]
  end
  
 end
