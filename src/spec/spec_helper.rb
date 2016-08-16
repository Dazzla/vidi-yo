$:<< '../lib'

require 'factory_girl'
require 'rspec'
require 'simplecov'
require 'vcr'
require 'webmock'

SimpleCov.start do
  add_filter 'spec'
end

require 'aws'
require 'consul'

%w{support factories}.each do |d|
  Dir["./spec/#{d}/**/*.rb"].sort.each { |f| require f}
end
