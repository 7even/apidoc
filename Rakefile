desc 'Launch the app console'
task :console do
  require_relative './init'
  
  # a helper for prettyprinting mongoid objects in the console
  def jp(object)
    Oj.load(object.to_json)
  end
  
  Pry.start
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task default: :spec
