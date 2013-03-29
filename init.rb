require 'bundler'
Bundler.require

set :environment, ENV['RACK_ENV'].to_sym if ENV['RACK_ENV']
disable :run, :reload

AwesomePrint.pry!

Mongoid.load!('config/mongoid.yml')

Oj.default_options = { mode: :compat }

require 'parser'
require 'body_processor'
require 'blueprint'
require 'request'
require 'context'
