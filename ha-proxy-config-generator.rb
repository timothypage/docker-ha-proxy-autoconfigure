require 'docker'
require 'pry'
require 'erubis'

Docker::API_VERSION = '1.22'
# Docker.url  = 'tcp://192.168.33.11:3375'

apps = []
@containers = []

# def listen_and_report
#   Docker::Event.stream do |event|
#     if event.status == "start"
#       container = Docker::Container.get(event.id)
#   	  ip = container.info["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]
#   	  puts "#{container.id} starting on #{ip}"
#     elsif event.status == "die"
#       puts "removing #{event.id}"
#     end
#   end
# end

# begin
#   listen_and_report
# rescue Excon::Errors::SocketError
#   sleep 1
#   listen_and_report
# end

Service = Struct.new(:name, :containers)
Container = Struct.new(:name, :ip, :service)


def get_containers
  containers = Docker::Container.all
  containers.map do |container|
    Container.new(
      container.info["Names"].first,
      container.info["NetworkSettings"]["Networks"]["yggdrasil"]["IPAddress"],
      container.info["Labels"]["sxg.service"]
    )
  end
end

containers = get_containers()
@services = []

[
  "hello_world",
  "nginx"
].each do |name|
  @services << Service.new(
    name,
    containers.select{ |c| c.service == name }
  )
end

template = File.read('templates/haproxy.erb')
eruby = Erubis::Eruby.new(template)
puts eruby.result(services: @services, tld: "dev")