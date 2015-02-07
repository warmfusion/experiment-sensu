# Experimental Sensu Client

This project contains a working prototype of Puppet Managed sensu clients where
a client is configured almost exclusivly from hiera, with a simple minor change 
to a common default node.

The Sensu Server used during developement was the [hiroakis/docker-sensu-server](https://github.com/hiroakis/docker-sensu-server)
docker container which provided a very easy bootstrap of rabbitmq, sensu server, and the Uchima dashboard.

    
## Adding A Check

Its very easy to add new Sensu checks to this virtual machine, simply add elements to a hash
in the configuration yaml like so:

    sensu::check:
      nginx:
        command: '/opt/sensu-plugins/sensu-community-plugins-master/plugins/nginx/nginx-metrics.rb'
        handlers: 'default'
        subscribers: 'base'
        type: 'metric'
      check_load:
		    command: '/opt/sensu-plugins/sensu-community-plugins-master/plugins/system/check-load.rb'
		    handlers: 
		      - default
		      - critical
		    subscribers: 'base'

The configuration is loaded by the default.pp using a ```create_resources( 'sensu::check', $config) )``` call

## Adding handlers

Similar to the addition of checks, you can configure new handlers using the configuration section shown below:

> Remember that [Sensu Handlers](http://sensuapp.org/docs/0.11/adding_a_handler) run on the server 
> after reciept of messages from clients

    sensu::handler:
      default:
        command: 'tee -a /var/log/sensu-event.log'
        type: 'pipe'
      critical:
        command: 'mailx -s "Crazy Fail" megafail@example.com'
        type: 'pipe'
        severities: 
	        - critical


## Configuration of Sensu Client

The following configuration shows how the client is configured to connect to a remote RabbitMQ server using
both password authentication, and SSL key pairs for encryption/authentication. The same keypair is used 
on all servers, as per the [recommendations](http://sensuapp.org/docs/0.11/ssl)

    sensu::install_repo: true
    sensu::purge_config: true
    sensu::rabbitmq_host: 192.168.59.103
    sensu::rabbitmq_password: password
    sensu::rabbitmq_port: 5671
    sensu::rabbitmq_vhost: '/sensu'
    sensu::rabbitmq_ssl: true
    sensu::rabbitmq_ssl_private_key: "puppet:///modules/secure/rabbitmq/key.pem"
    sensu::rabbitmq_ssl_cert_chain:  "puppet:///modules/secure/rabbitmq/cert.pem"

    # See https://github.com/sensu/sensu-puppet/issues/298
    sensu::sensu_plugin_version: present

