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
        Fluent::Test::Driver::Input.new(Fluent::Plugin::SnmpTrapAlert).configure(conf)
    end

    def test_configure
        driver = create_driver('')
        assert_equal "0.0.0.0", d.instance.host
        assert_equal 162, d.instance.port
        assert_equal 'SNMPTrap.Alert', d.instance.tag
    end

    def run_test_configure
        test 'emit' do
            driver = create_driver(SNMP_CONFIG)
            driver.run(expected_emits: 5)
            driver.events.each do |tag, timestamp, trap_events|
                assert_equal("SNMPTrap.Alert", tag)
                assert_equal(time.is_a?(Fluent::EventTime))
                assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, trap_events)
            end
        end
   end

   def test_run
        driver = create_driver(SNMP_CONFIG)
        driver.run(expect_emits: 4)
        events = driver.events
        traps = driver.events
        puts driver.events
        assert_equal 'SNMPTrap.Alert', events[0][0]
        assert_true events[0][1].is_a?(Fluent::EventTime)
        message = events[0][2].to_s
        message = message.delete('\\"')
        assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, message)
        events[0][2].each {|key, value| assert_match(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13})|(host))/, key.to_s, "Unknown OID format")}
   end
end

