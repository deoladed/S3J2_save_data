require 'bundler'
# Installation des gem/require presents dans le Gemfile
Bundler.require

$:.unshift File.expand_path('./../lib/', __FILE__)
require 'views/index'
require 'views/done'
require 'app/scrapper'

# Allez, on appelle la classe scrapper sur le val d'oise, on peut changer de departement si on veut, puis on lance le perform
Index.new
