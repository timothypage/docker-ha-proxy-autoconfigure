require 'docker'
require 'pry'
require 'erubis'
require 'logger'

require 'tilt'
require 'tilt/erubis'

network_name = "yggdrasil"
nginx_template_file = "templates/nginx.erb"

logger = Logger.new($stdout)

Docker::API_VERSION = '1.23'
# Docker.url  = 'tcp://54.67.45.42:3375'

Service = Struct.new(:name, :containers)
Container = Struct.new(:id, :name, :ip, :port, :network, :service, :container)

def process_container(container)
  name = container.info.dig("Name")
  network = container.info.dig("NetworkSettings", "Networks").keys.first
  ip = container.info.dig("NetworkSettings", "Networks", network, "IPAddress")
  service = container.info.dig("Labels", "sxg.service")
  port = container.info.dig("Labels", "sxg.port") || 80

  Container.new(container.id, name, ip, port, network, service, container)
end

containers = Docker::Container.all

app_containers = containers.reject do |c|
  c.info.dig("Labels", "sxg.service").nil?
end.select do |c|
  c.info.dig("NetworkSettings", "Networks", network_name, "IPAddress")
end.map do |c|
  process_container(c)
end

detect_router = Proc.new{ |container| container.service == "router" }

router = app_containers.find( &detect_router )
app_containers.reject!( &detect_router )

services = app_containers.group_by(&:service).map do |name, containers|
  Service.new(name, containers)
end

FileUtils.rm_rf(Dir.glob('nginx_confs/*.conf'))

nginx_template = Tilt::ErubisTemplate.new(nginx_template_file)

services.each do |service|
  File.write(
    "./nginx_confs/#{service.name}.conf",
    nginx_template.render(service)
  )
end

if router
  router.container.exec(['bash', '-c', 'nginx -t && nginx -s reload'])[1].each do |line|
    logger.info line.chomp
  end
else
  logger.error "No router found"
end
