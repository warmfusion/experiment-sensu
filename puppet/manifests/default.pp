
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

  # Include any sensu checks we've had configured
  create_resources( 'sensu::check', hiera_hash('sensu::check', {}) )
  create_resources( 'sensu::handler', hiera_hash('sensu::handler', {}) )

#  sensu::handler { 'default':
#    command => 'mail -s \'sensu alert\' ops@foo.com',
#  }


  package { 'wget':
    ensure => installed,
  }
  
  # Required for sensu-plugins to install
  package {'ruby-dev':
    ensure => installed,
  }-> Package['sensu-plugin']

  file { '/opt/sensu-plugins':
    ensure => directory,
    require => Package['wget']
  }
  
  staging::deploy { 'sensu-community-plugins.tar.gz':
    source => 'https://github.com/sensu/sensu-community-plugins/archive/master.tar.gz',
    target => '/opt/sensu-plugins',
    require => File['/opt/sensu-plugins'],
  } 

}
