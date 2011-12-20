require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

$:.unshift('./lib')
require 'dotanuki'
