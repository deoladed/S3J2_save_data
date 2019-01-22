require 'bundler'
# Installation des gem/require presents dans le Gemfile
Bundler.require

$:.unshift File.expand_path('./../lib/app', __FILE__)
require 'scrapper.rb'

# Allez, on appelle la classe scrapper sur le val d'oise, on peut changer de departement si on veut, puis on lance le perform
Scrapper.new('http://annuaire-des-mairies.com/val-d-oise.html').perform
