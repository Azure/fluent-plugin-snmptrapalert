$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))
require "test-unit"
require "fluent/test"
require "fluent/test/driver/input"
require "fluent/test/helpers"
require 'fluent/plugin/in_snmptrapalert'
require 'snmp'

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)
