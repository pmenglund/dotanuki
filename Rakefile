require 'bundler'
require 'rspec/core/rake_task'

task :default => [:spec]

desc "run rspec tests"
task :spec => [:"native:spec", :"pure:spec"]

desc "build gems"
task :build => [:"native:build", :"pure:build"]

desc "release gems"
task :release => [:"native:release", :"pure:release"]

namespace "native" do
  Bundler::GemHelper.install_tasks :name => 'dotanuki'
  RSpec::Core::RakeTask.new(:spec)
end

namespace "pure" do
  Bundler::GemHelper.install_tasks :name => 'dotanuki-ruby'
  RSpec::Core::RakeTask.new(:spec)
end

desc "run autotest"
task :autotest do
  system "autotest"
end
