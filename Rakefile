require 'bundler'
require 'rspec/core/rake_task'
require 'metric_fu'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end

desc "run autotest"
task :autotest do
  system "autotest"
end
