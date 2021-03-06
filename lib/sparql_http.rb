require 'thread'
require 'uri'
require 'open-uri'
require 'cgi'
require 'json'
require 'date'
require 'multi_json'
require 'oj'
require 'rake'
require 'pry'
require 'net/http'

require_relative "sparql_http/repository"
require_relative "sparql_http/resultset/resultset"
require_relative "sparql_http/store/http_store"
require_relative "sparql_http/utils/mime"
require_relative "sparql_http/utils/xsd"
