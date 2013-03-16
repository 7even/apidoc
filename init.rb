require 'bundler'
Bundler.require

AwesomePrint.pry!

Mongoid.load!('config/mongoid.yml')

require 'parser'
require 'blueprint'
require 'request'
require 'context'
