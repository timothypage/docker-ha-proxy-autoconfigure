@network_name = "yggdrasil"
@nginx_template = Tilt::ErubisTemplate.new("templates/nginx.erb")

Service = Struct.new(:name, :containers)
Container = Struct.new(:id, :name, :ip, :network, :service)

def process_container(container)
  name = container.info.dig("Name")
  network = container.info.dig("NetworkSettings", "Networks").keys.first
  ip = container.info.dig("NetworkSettings", "Networks", network, "IPAddress")
  service = container.info.dig("Config", "Labels", "sxg.service")

  Container.new(container.id, name, ip, network, service)
end

def update_services
  @services = @containers.group_by(&:service).map do |name, containers|
    Service.new(name, containers)
  end
end

def render_nginx_templates(services)
  services.each do |service|
    File.write(
      "./nginx_confs/#{service.name}.conf",
      @nginx_template.render(service)
    )
  end
end

def listen_and_report
  Docker::Event.stream do |event|
    if event.status == "start"
      container = Docker::Container.get(event.id)
      container = process_container(container)
      @logger.info "#{event.id} start"
      @logger.info "#{container.name} starting on #{container.ip} on network #{container.network}"
      @containers << container
      @containers.uniq!{ |c| c.id }
      update_services
      render_nginx_templates

    elsif event.status == "die"
      @logger.info "removing #{event.id}"
    end

  end
end
