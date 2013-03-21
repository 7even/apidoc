require 'bundler'
Bundler.require

AwesomePrint.pry!

Mongoid.load!('config/mongoid.yml')

Oj.default_options = { mode: :compat }

require 'parser'
require 'blueprint'
require 'request'
require 'context'
