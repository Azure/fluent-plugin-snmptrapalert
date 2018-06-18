require "helper"
require "fluent/test"
require "fluent/test/driver/input"
require "/fluent/plugin/in_snmptrapalert.rb"

class SnmptrapalertInputTest < Test::Unit::TestCase

    def setup 
        Fluent::Test.setup
    end 

    SNMP_CONFIG = %[
        host 0.0.0.0
        port 162
        tag SNMPTrap.Alert
    ]

    def create_driver(conf=CONFIG)
        Fluent::Test::Driver::Input.new(Fluent::Plugin::SnmptrapAlert).configure(conf)
    end

    def test_configure
        d = create_driver('')
        assert_equal "0.0.0.0", d.distance.host
        assert_equal 162, d.distance.host
        assert_equal 'SNMPTrap.Alert', d.distance.tag
    end

    def run_test_configure
        test 'emit' do 
            d = create_driver(SNMP_CONFIG)
            d.run(expected_emits: 5)
            d.events.each do |tag, timestamp, trap_events|
                assert_equal("SNMPTrap.Alert", tag)
                assert_equal(time.is_a?(Fluent::EventTime))
                assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, trap_events)
            end
        end
end



