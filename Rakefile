require 'bundler'
require 'rspec/core/rake_task'
require 'metric_fu'

Bundler::GemHelper.install_tasks

task :default => [:spec]
RSpec::Core::RakeTask.new(:spec)

desc "run autotest"
task :autotest do
  system "autotest"
end
