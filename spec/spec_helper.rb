require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/motc_api.rb'

CITY_NAME = 'Hsinchu'.freeze
CORRECT = YAML.safe_load(File.read('spec/fixtures/bs_results.yml'))
RESPONSE = YAML.load(File.read('spec/fixtures/bs_response.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'motc_api'.freeze