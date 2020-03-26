require 'helper'

class SnmptrapalertInputTest < Test::Unit::TestCase

    setup do
        Fluent::Test.setup
    end

    SNMP_CONFIG = %[
        host 0.0.0.0
        port 1620
        tag SNMPTrap.Alert
    ]

    def create_driver(conf=CONFIG)
        Fluent::Test::Driver::Input.new(Fluent::Plugin::SnmpTrapAlert).configure(conf)
    end

    def send_trap()
        SNMP::Manager.open(:Host => "127.0.0.1", :Port => 1620, :Version => :SNMPv1) do |snmp|
            snmp.trap_v1(
            "1.3.6.1.4.1.10300.1.1.1.12",
            '172.0.0.1',
            :enterpriseSpecific, #Generic Trap Type
            0,
            1234,
            [SNMP::VarBind.new("1.3.6.1.2.3.4", SNMP::Integer.new(1))])
        end
    end

    def test_configure
        driver = create_driver('')
        assert_equal "0.0.0.0", driver.instance.host
        assert_equal 162, driver.instance.port
        assert_equal 'SNMPTrap.Alert', driver.instance.tag
    end

    test 'emit' do
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 1, timeout: 5) do
            send_trap()
        end

        driver.events.each do |tag, timestamp, trap_events|
            assert_equal("SNMPTrap.Alert", tag)
            assert_true(timestamp.is_a?(Fluent::EventTime))
            assert_equal(trap_events, {"SNMPv2-SMI::mgmt.3.4"=>"1", "host"=>"127.0.0.1"})
        end
    end

    test 'emit_mib' do
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 1, timeout: 5) do
            send_trap()
        end
        driver.events.each do |tag, timestamp, trap_events|
            assert_equal 'SNMPTrap.Alert', tag
            assert_true timestamp.is_a?(Fluent::EventTime)
            message = trap_events.to_s
            message = message.delete('\\"')
            assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, message)

            trap_events.each do |key, value|
                assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13})|(host))/, key.to_s, "Unknown OID format")
            end
        end
    end
end
