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

    def create_driver(conf=SNMP_CONFIG)
        Fluent::Test::Driver::Input.new(Fluent::Plugin::SnmpTrapAlert).configure(conf)
    end

    def send_trap_v1()
        SNMP::Manager.open(:Host => "127.0.0.1", :TrapPort => 1620, :Version => :SNMPv1) do |snmp|
            snmp.trap_v1(
            "1.3.6.1.4.1.10300.1.1.1.12",
            '172.0.0.1',
            :enterpriseSpecific, #Generic Trap Type
            0,
            1234,
            [SNMP::VarBind.new("1.3.6.1.2.3.4", SNMP::Integer.new(1))])
        end
    end

    def send_trap_v2()
        SNMP::Manager.open(:Host => "127.0.0.1", :TrapPort => 1620, :Version => :SNMPv2c) do |snmp|
            snmp.trap_v2(
            400, # Fake system up time of 4 seconds
            "1.3.6.1.4.1.10300.1.1.1.12",
            [SNMP::VarBind.new("1.3.6.1.2.3.4", SNMP::Integer.new(1))])
        end
    end

    def test_configure
        driver = create_driver('')
        assert_equal "0.0.0.0", driver.instance.host
        assert_equal 162, driver.instance.port
        assert_equal 'SNMPTrap.Alert', driver.instance.tag
    end

    def test_configure_custom
        driver = create_driver(SNMP_CONFIG)
        assert_equal "0.0.0.0", driver.instance.host
        assert_equal 1620, driver.instance.port
        assert_equal 'SNMPTrap.Alert', driver.instance.tag
    end

    test 'emit_v1' do
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 1, timeout: 5) do
            send_trap_v1()
        end

        assert_equal(driver.events.length(), 1)
        driver.events.each do |tag, timestamp, trap_events|
            assert_equal("SNMPTrap.Alert", tag)
            assert_true(timestamp.is_a?(Fluent::EventTime))
            assert_equal(trap_events, {"SNMPv2-SMI::mgmt.3.4"=>"1", "enterprise"=>[1,3,6,1,4,1,10300,1,1,1,12],"generic_trap"=>:enterpriseSpecific, "host"=>"127.0.0.1", "specific_trap"=>0, "agent_addr"=>"172.0.0.1"})
        end
    end

    test 'emit_mib_v1' do
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 1, timeout: 5) do
            send_trap_v1()
        end

        assert_equal(driver.events.length(), 1)
        driver.events.each do |tag, timestamp, trap_events|
            assert_equal 'SNMPTrap.Alert', tag
            assert_true timestamp.is_a?(Fluent::EventTime)
            message = trap_events.to_s
            message = message.delete('\\"')
            assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, message)

            trap_events.each do |key, value|
                assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13})|(host)|(specific_trap)|(enterprise)|(generic_trap)|(agent_addr))/, key.to_s, "Unknown OID format")
            end
        end
    end

    test 'emit_v2' do
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 1, timeout: 5) do
            send_trap_v2()
        end

        assert_equal(driver.events.length(), 1)
        driver.events.each do |tag, timestamp, trap_events|
            assert_equal("SNMPTrap.Alert", tag)
            assert_true(timestamp.is_a?(Fluent::EventTime))
            assert_equal(trap_events, {"SNMPv2-MIB::snmpTrapOID.0"=>"SNMPv2-SMI::enterprises.10300.1.1.1.12", "SNMPv2-MIB::sysUpTime.0"=>"00:00:04.00","SNMPv2-SMI::mgmt.3.4"=>"1", "host"=>"127.0.0.1"})
        end
    end

    test 'emit_mib_v2' do
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 1, timeout: 5) do
            send_trap_v2()
        end

        assert_equal(driver.events.length(), 1)
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
