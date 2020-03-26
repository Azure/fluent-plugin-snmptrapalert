# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


# fluent-plugin-snmptrapalert

[Fluentd](https://www.fluentd.org/)

 snmptrapalert input plugin for fluentd. This plugin is developed specifically to work on all versions of SNMP traps.
 Plugin is specifically designed for snmp traps that are generated by devices. With this plugin installed,
 SNMP traps that are generated by devices can be recieved by fluentd listener. The traps recieved by fluentd are formatted into a json output.

 @type ===> type of input plugin (required) ===> 'snmptrapalert'
 tag ===> tag that needs to be attached in front of each alert recieved ==> default value is "SNMPTrap.Alert"
 host ===> Host from which traps are recieved ===> default value is "0.0.0.0" (listens on all interfaces)
 port ===> Port (optional) ===> default set to 162
 community ===> Trap Community String which is used by the trap receiver to determine which traps are accepted from a device (Optional),
                by default all devices has community string set to "public" by default, also useful to avoid unwanted floods of traps
                from a malicious source ===> default value set is "pubic"
 trap_format ===> format of the output string

## Testing
```
$ docker run -it --rm -v $PWD:/code ubuntu:16.04 bash
$ apt-get update && apt-get install -y --no-install-recommends ruby-dev git gcc make libc6-dev smitools &&
$ cd code &&
$ gem install bundler:1.14 &&
$ bundle install --path vendor/bundle &&
$ bundle exec rake test

## Installation

### RubyGems

```
$ gem install fluent-plugin-snmptrapalert
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-snmptrapalert"
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-config-format input snmptrapalert
```

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2018 - Microsoft Corp
