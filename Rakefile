require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = []
  t.test_files = FileList['test/**/test*.rb']
end

Rake::TestTask.new do |t|
  t.libs = []
  t.name = "test:repo"
  t.test_files = FileList['test/**/test_repo*.rb']
end

Rake::TestTask.new do |t|
  t.libs = []
  t.name = "test:query"
  t.test_files = FileList['test/**/test_query*.rb']
end
