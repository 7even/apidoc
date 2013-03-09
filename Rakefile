desc 'Launch the app console'
task :console do
  require_relative './init'
  Pry.start
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task default: :spec
