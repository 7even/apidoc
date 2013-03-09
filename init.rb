require 'bundler'
Bundler.require

AwesomePrint.pry!

Mongoid.load!('config/mongoid.yml')

require 'blueprint'
require 'request'
