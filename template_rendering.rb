require 'pry'
require 'ostruct'
require 'tilt'
require 'tilt/erubis'

container = OpenStruct.new(
  hostname: "vodit.spectrumxg.com",
  role: "vodit",
  name: "asset_analyzer",
  port: 4567
)

template = Tilt::ErubisTemplate.new("templates/nginx.erb")
template.render(container)


# restart nginx on ubuntu
# nginx_pid = File.read('/var/run/nginx.pid').strip.to_i
# Process.kill("HUP", nginx_pid)
