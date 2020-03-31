# snmptrapalert input plugin for fluentd.
# Plugin is specifically designed snmp traps that are generated by VLI.
# With this plugin installed, SNMP traps that are generated by VLI can be
# recieved by fluentd listener. The traps recieved by fluentd are formatted
# into a json output.
# @type ===> type of input plugin (required) ===> 'snmptrapalert'
# tag ===> tag that needs to be attached in front of each alert
# recieved ==> default value is "SNMPTrap.Alert"
# host ===> Host from which traps are recieved ===> default value is "0.0.0.0"
# port ===> Port (optional) ===> default set to 162
# community ===> Trap Community String which is used by the trap receiver to
# determine which traps are accepted from a device (Optional),                  # by default all devices has community string set to "public" by default, also
# useful to avoid unwanted floods of traps from a malicious source 
# default value set is "pubic"
# trap_format ===> format of the output string
# Formats the trap into Hash oid: <component>

require 'fluent/input'

module Fluent
  module Plugin

            #Create class for snmp trap plugin
            class SnmpTrapAlert < Fluent::Plugin::Input

                #Register the Plugin Name for identification in the configuration file
                Fluent::Plugin.register_input('snmptrapalert', self)

                #define parameters and its default values
                config_param :tag, :string, :default => "SNMPTrap.Alert"
                config_param :host, :string, :default => '0.0.0.0'
                config_param :port, :integer, :default => 162

                # Use these parameters to add extra SMI modules for non-standard SNMP traps
                # Make sure to set the SMIPATH  environment variable so the smidump tool used to read
                # the modules can find them.

                # Path in which the smi files are located, usually "#{ENV['SMIPATH']}": /path/to/files
                config_param :import_path, :string, :default => ""
                # SMI module filenames: ["smi-apliance.smi"]
                config_param :import_modules, :array, :default => [], value_type: :string
                # SMI module names ["SMI-APPLIANCE"]
                config_param :import_module_names, :array, :default => [], value_type: :string

                #define router method
                unless method_defined?(:router)
                    define_method(:router) { Engine }
                end

                #Define initialize and call built in ruby snmp module
                def initialize
                    super
                    require 'snmp'
                end

                # This method is called before starting.
                # 'conf' is a Hash that includes configuration parameters.
                # If the configuration is invalid, raise Fluent::ConfigError.
                def configure(conf)
                    super
                    @conf = conf
                end

                #Start Listening to SNMP Traps
                def start
                    super
                    @manager = SNMP::Manager.new(:host => @host, :port => @port)
                    if SNMP::MIB.import_supported?
                        list = SNMP::MIB.list_imported()

                        if import_modules.size > 0
                            modules=[]
                            @import_modules.each{|module_name| modules = modules + [module_name]}

                            modules.each{|mod|
                                SNMP::MIB.import_module([import_path, mod].join('/'))
                                log.info "Importing MIB definition for: #{mod}."
                            }
                        end

                    else
                        log.warn "Custom MIB not supported"
                    end

                    modules_to_load = SNMP::Options.default_modules + @import_module_names
                    @snmptrap = SNMP::TrapListener.new(:Host => @host, :Port => @port, :mib_modules => modules_to_load) do |manager|
                        manager.on_trap_default do |trap|
                            trap_events = Hash.new
                            tag = @tag
                            timestamp = Engine.now
                            raise("Unknown Trap Format", trap) unless trap.kind_of?(SNMP::SNMPv1_Trap) or trap.kind_of?(SNMP::SNMPv2_Trap)
                            trap.each_varbind do |vb|
                                trap_events[vb.name.to_s] = vb.value.to_s
                            end
                            trap_events['host'] = trap.source_ip
                            if trap.kind_of?(SNMP::SNMPv1_Trap)
                                trap_events['specific_trap'] = trap.specific_trap
                                trap_events['enterprise'] = trap.enterprise
                                trap_events['generic_trap'] = trap.generic_trap
                            end
                            if @trap_format == 'tojson'
                               require 'json'
                               trap_events.to_json
                            end
                            router.emit(tag, timestamp, trap_events)
                        end
                    end
                end

                #To Stop the SNMP Listener and clean up all open connections
                def shutdown
                        @snmptrap.exit
                end
        end 
  end
end   
