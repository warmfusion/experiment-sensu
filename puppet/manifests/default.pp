
#	$myvariable = hiera(myvar)
#	notice("My variable is: ${myvariable}")


node basenode {}

node default inherits basenode {

  # Ubuntu gets out of date real quick
  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }

  Exec["apt-update"] -> Package <| |>

  # Create the classes defined by the yaml
  hiera_include( 'classes' )


  package { 'wget':
    ensure => installed,
  }

  file { '/opt/sensu-plugins':
    ensure => directory,
    require => Package['wget']
  }
  
  staging::deploy { 'sensu-community-plugins.tar.gz':
    source => 'https://github.com/sensu/sensu-community-plugins/archive/master.tar.gz',
    target => '/opt/sensu-plugins',
    require => File['/opt/sensu-plugins'],
  }
  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' ops@foo.com',
  }
  sensu::check { 'check_cron':
    command => '/opt/sensu-plugins/sensu-community-plugins-master/plugins/processes/check-procs.rb -p crond -C   1',
    handlers => 'default',
    subscribers => 'base',
    require => Staging::Deploy['sensu-community-plugins.tar.gz'],
  }
  sensu::check { 'check_dns':
    command => '/opt/sensu-plugins/sensu-community-plugins-master/plugins/dns/check-dns.rb -d google-public-dns-a.google.com -s 192.168.1.2 -r 8.8.8.8',
    handlers => 'default',
    subscribers => 'base',
    require => Staging::Deploy['sensu-community-plugins.tar.gz'],
  }
  sensu::check { 'check_disk':
    command => '/opt/sensu-plugins/sensu-community-plugins-master/plugins/system/check-disk.rb',
    handlers => 'default',
    subscribers => 'base',
    require => Staging::Deploy['sensu-community-plugins.tar.gz'],
  }

}
